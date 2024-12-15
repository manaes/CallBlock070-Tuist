import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: ModulePaths.Shared.Log.rawValue,
    targets: [
        .implements(module: .shared(.Log)),
    ]
)
