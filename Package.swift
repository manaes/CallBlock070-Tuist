// swift-tools-version:5.7
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSetting = PackageSettings(
        baseSettings: .settings(
            configurations: [
                .debug(name: .dev),
                .debug(name: .stage),
                .release(name: .prod),
            ]
        )
    )
#endif

let package = Package(
    name: "Package",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.8.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.8.0"),
    ]
)
