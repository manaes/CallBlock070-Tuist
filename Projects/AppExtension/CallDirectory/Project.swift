import DependencyPlugin
import EnvironmentPlugin
@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

var targets: [Target] {
    (1 ... 50).map { idx in
        let productName = "CallBlocker\(String(format: "%02d", idx))"
        let identifier = "\(env.organizationName).Block070.\(productName)"

        var spec2 = TargetSpec(name: productName, dependencies: [
        ])

        var spec = TargetSpec(
            name: productName,
            bundleId: identifier,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(PRODUCT_NAME)",
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.callkit.call-directory",
                    "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).CallDirectoryHandler",
                ],
            ]),
            entitlements: .file(path: .relativeToCurrentFile("Sources/Support/CallBlocker.entitlements")),
            dependencies: [
                .shared(target: .Log),
                .shared(target: .Config),
            ]
        )

        return .appExtension(spec: spec)
    }
}

let project = Project.module(
    name: ModulePaths.AppExtension.CallDirectory.rawValue,
    targets: [.implements(module: .appExtension(.CallDirectory))] + targets
)
