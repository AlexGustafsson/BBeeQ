# IOS_VERSION=$(shell xcrun --sdk iphoneos --show-sdk-version)
# IOS_SDK=$(shell xcrun --sdk iphoneos --show-sdk-path)
# IOS_TARGET=arm64-apple-ios${IOS_VERSION}
IOS_VERSION=$(shell xcrun --sdk iphoneos --show-sdk-version)
IOS_SDK=$(shell xcrun --sdk iphonesimulator --show-sdk-path)
IOS_TARGET=x86_64-apple-ios17-simulator
IOS_SIMULATOR_NAME=booted

.PHONY: all
all: app installer

.PHONY: build
# Build BBeeQ
build:
	swift build --configuration release --product BBeeQ

.PHONY: build-ios
# Build for iOS
build-ios:
	swift build --configuration release --scratch-path .build/ios -Xswiftc -sdk -Xswiftc ${IOS_SDK} -Xswiftc -target -Xswiftc ${IOS_TARGET} -Xcc -isysroot -Xcc ${IOS_SDK} -Xcc --target=${IOS_TARGET} --product BBeeQ
	swift build --configuration release --scratch-path .build/ios -Xswiftc -sdk -Xswiftc ${IOS_SDK} -Xswiftc -target -Xswiftc ${IOS_TARGET} -Xcc -isysroot -Xcc ${IOS_SDK} -Xcc --target=${IOS_TARGET} --product BBeeQWidget

.PHONY: run
# Run the program
run:
	swift run BBeeQ

.PHONY: run-ios
# Run the program on iOS
run-ios: app-ios
	xcrun simctl install ${IOS_SIMULATOR_NAME} .build/ios/BBeeQ.app
	xcrun simctl launch --console ${IOS_SIMULATOR_NAME} se.axgn.BBeeQ

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
	cp Sources/BBeeQ/Resources/Info.plist .build/BBeeQ.app/Contents
	mkdir -p .build/BBeeQ.app/Contents/Resources
	cp .build/AppIcon.icns .build/BBeeQ.app/Contents/Resources/AppIcon.icns
ifdef CODESIGN_IDENTITY
	plutil -convert xml1 Sources/BBeeQ/Resources/Entitlements.plist
	codesign --force --verbose=4 --entitlements Sources/BBeeQ/Resources/Entitlements.plist --sign "$(CODESIGN_IDENTITY)" .build/BBeeQ.app
endif

.PHONY: app-ios
app-ios: build-ios .build/AppIcon.icns
	mkdir -p .build/ios/BBeeQWidget.appex
	cp .build/ios/release/BBeeQWidget .build/ios/BBeeQWidget.appex
	cp Sources/BBeeQWidget/Resources/Info.plist .build/ios/BBeeQWidget.appex

	mkdir -p .build/ios/BBeeQ.app/PlugIns
	cp .build/ios/release/BBeeQ .build/ios/BBeeQ.app
	cp Sources/BBeeQ/Resources/Info.plist .build/ios/BBeeQ.app
	cp Sources/BBeeQ/Resources/Entitlements.plist .build/ios/BBeeQ.app
	cp -r .build/ios/BBeeQWidget.appex .build/ios/BBeeQ.app/PlugIns

.PHONY: installer
installer:
# create-dmg exits with 2 if everything worked but it wasn't code signed
# due to no identity being defined
	npx create-dmg --overwrite --identity="$(CODESIGN_IDENTITY)" .build/BBeeQ.app .build || [[ $$? -eq 2 ]] || exit 1

# Tail logs produced by BBeeQ
logs:
	log stream --info --debug --predicate 'subsystem BEGINSWITH "se.axgn.BBeeQ" || (eventMessage CONTAINS "BBeeQ" && messageType IN {16, 17})'
