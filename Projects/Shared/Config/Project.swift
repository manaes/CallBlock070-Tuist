import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.Config.rawValue,
    targets: [
        .implements(module: .shared(.Config)),
    ]
)
