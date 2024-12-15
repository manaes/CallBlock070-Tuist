import EnvironmentPlugin
import ProjectDescription

let workspace = Workspace(
    name: env.name,
    projects: [
        "Projects/App",
    ]
)
