import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        window.backgroundColor = .white
        self.window = window

        if Session.isLoggedIn {
            showApp()
        } else {
            showLogin()
        }

        window.makeKeyAndVisible()
    }

    func showLogin() {
        let vc = LoginViewController()
        vc.onAuthenticated = { [weak self] in
            Session.isLoggedIn = true
            self?.showApp()
        }
        swapRoot(vc)
    }

    func showApp() {
        swapRoot(RootTabBarController())
    }

    func showLoginAnimated() {
        guard let window = window else { return }
        Session.isLoggedIn = false
        let vc = LoginViewController()
        vc.onAuthenticated = { [weak self] in
            Session.isLoggedIn = true
            self?.showApp()
        }
        UIView.transition(with: window, duration: 0.30, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
    }

    private func swapRoot(_ vc: UIViewController) {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.30, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
    }
}

// MARK: - Session flag

enum Session {

    private static let key = "tcb.session.loggedIn"

    static var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
