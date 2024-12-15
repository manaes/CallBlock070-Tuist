import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
              session.configuration.name == "Default"
        else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        let block070VC = Block070ViewController(viewModel: Block070ViewModel())
        window?.rootViewController = UINavigationController(rootViewController: block070VC)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
}
