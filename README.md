# BBeeQ

## Building
<!-- markdownlint-disable MD029 -->

1. Generate the XCode project using `xcodegen`

```shell
xcodegen
```

2. Open the project.

```shell
open BBeeQ.xcodeproj
```

3. Select a team and change the bundle id of the `BBeeQ` and `BBQProbeE` targets.
4. Then build for the desired target (macOS / iOS)

<!-- markdownlint-enable -->

## Development

Format code

```shell
swift-format format --in-place --recursive .
```
