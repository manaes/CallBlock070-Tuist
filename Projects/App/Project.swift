import ConfigurationPlugin
import DependencyPlugin
import EnvironmentPlugin
import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// swiftlint:disable line_length
let configurations: [Configuration] = .default

let settings: Settings = .settings(
    base: env.baseSetting,
    configurations: configurations,
    defaultSettings: .recommended
)

let scripts: [TargetScript] = generateEnvironment.scripts

var extensionDependencies: [TargetDependency] {
    (1 ... 50).map { idx in
        let productName = "CallBlocker\(String(format: "%02d", idx))"
        return TargetDependency.target(name: productName)
    }
}

let targets: [Target] = [
    .target(
        name: env.name,
        destinations: env.destinations,
        product: .app,
        bundleId: "\(env.organizationName).\(env.name)",
        deploymentTargets: env.deploymentTargets,
        infoPlist: .file(path: "Support/Info.plist"),
        sources: ["Sources/**"],
        resources: ["Resources/**"],
        entitlements: .file(path: .relativeToCurrentFile("Support/app.entitlements")), scripts: scripts,
        dependencies: [
            .shared(target: .GlobalThirdPartyLibrary),
            .shared(target: .Log),
            .shared(target: .Config),
        ] + extensionDependencies
    ),
]

var extensionTargets: [Target] {
    (1 ... 50).map { idx in
        let productName = "CallBlocker\(String(format: "%02d", idx))"
        let identifier = "\(env.organizationName).Block070.\(productName)"

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
            sources: ["../AppExtension/CallDirectory/Sources/**"],
            entitlements: .file(path: .relativeToAppExtension("CallDirectory/Sources/Support/CallBlocker.entitlements")),
            dependencies: [
                .shared(target: .Log),
                .shared(target: .Config),
            ]
        )

        return .appExtension(spec: spec)
    }
}

let schemes: [Scheme] = [
    .scheme(
        name: "\(env.name)-DEV",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .dev),
        archiveAction: .archiveAction(configuration: .dev),
        profileAction: .profileAction(configuration: .dev),
        analyzeAction: .analyzeAction(configuration: .dev)
    ),
    .scheme(
        name: "\(env.name)-STAGE",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .stage),
        archiveAction: .archiveAction(configuration: .stage),
        profileAction: .profileAction(configuration: .stage),
        analyzeAction: .analyzeAction(configuration: .stage)
    ),
    .scheme(
        name: "\(env.name)-PROD",
        shared: true,
        buildAction: .buildAction(targets: ["\(env.name)"]),
        runAction: .runAction(configuration: .prod),
        archiveAction: .archiveAction(configuration: .prod),
        profileAction: .profileAction(configuration: .prod),
        analyzeAction: .analyzeAction(configuration: .prod)
    ),
]

let project = Project(
    name: env.name,
    organizationName: env.organizationName,
    settings: settings,
    targets: targets + extensionTargets,
    schemes: schemes
)
// swiftlint:enable line_length
