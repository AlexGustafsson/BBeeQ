.PHONY: all
all: app installer

.PHONY: build
# Build BBeeQ
build:
	swift build --configuration release

.PHONY: run
# Run the program
run:
	swift run BBeeQ

.PHONY: debug
# Run the program in debug mode
debug:
	swift run --debugger BBeeQ

.PHONY: lint
# Lint all Swift code
# Requires swift-format: brew install swift-format
lint:
	swift-format lint --parallel --recursive Sources Package.swift

.PHONY: format
# Format all Swift code
# Requires swift-format: brew install swift-format
format:
	swift-format format --in-place --recursive --parallel Sources Package.swift

.PHONY: test
# Test all Swift code
test:
	swift test

.build/AppIcon.icns: SupportingFiles/BBeeQ/icon.png
	rm -r .build/AppIcon.iconset .build/AppIcon.icns &>/dev/null || true
	mkdir -p .build/AppIcon.iconset
# Create icons for different sizes
	sips -z 16 16 $< --out ".build/AppIcon.iconset/icon_16x16.png"
	sips -z 32 32 $< --out ".build/AppIcon.iconset/icon_16x16@2x.png"
	sips -z 32 32 $< --out ".build/AppIcon.iconset/icon_32x32.png"
	sips -z 64 64 $< --out ".build/AppIcon.iconset/icon_32x32@2x.png"
	sips -z 128 128 $< --out ".build/AppIcon.iconset/icon_128x128.png"
	sips -z 256 256 $< --out ".build/AppIcon.iconset/icon_128x128@2x.png"
	sips -z 256 256 $< --out ".build/AppIcon.iconset/icon_256x256.png"
	sips -z 512 512 $< --out ".build/AppIcon.iconset/icon_256x256@2x.png"
	sips -z 512 512 $< --out ".build/AppIcon.iconset/icon_512x512.png"
	sips -z 1024 1024 $< --out ".build/AppIcon.iconset/icon_512x512@2x.png"
	sips -z 1024 1024 $< --out ".build/AppIcon.iconset/icon_1024x1024.png"
# Compile icons
	iconutil --convert icns --output .build/AppIcon.icns .build/AppIcon.iconset

.PHONY: app
app: build .build/AppIcon.icns
	mkdir -p .build/BBeeQ.app/Contents/MacOS
	cp .build/release/BBeeQ .build/BBeeQ.app/Contents/MacOS
	mkdir -p .build/BBeeQ.app/Contents/Resources
	cp .build/AppIcon.icns .build/BBeeQ.app/Contents/Resources/AppIcon.icns
ifdef CODESIGN_IDENTITY
	plutil -convert xml1 Sources/BBeeQ/Resources/Entitlements.plist
	codesign --force --verbose --entitlements Sources/BBeeQ/Resources/Entitlements.plist --sign "$(CODESIGN_IDENTITY)" .build/BBeeQ.app
endif

.PHONY: installer
installer:
# create-dmg exits with 2 if everything worked but it wasn't code signed
# due to no identity being defined
	npx create-dmg --overwrite --identity="$(CODESIGN_IDENTITY)" .build/BBeeQ.app .build || [[ $$? -eq 2 ]] || exit 1

# Tail logs produced by BBeeQ
logs:
	log stream --info --debug --predicate 'subsystem BEGINSWITH "se.axgn.BBeeQ" || (eventMessage CONTAINS "BBeeQ" && messageType IN {16, 17})'
