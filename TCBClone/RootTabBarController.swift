import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let home     = wrap(HomeViewController(),      title: "Trang chủ",                 icon: nil)
        let accounts = wrap(AccountsViewController(),  title: "Tài khoản\n& Thẻ",           icon: "creditcard")
        let transfer = wrap(TransferViewController(),  title: "Chuyển tiền\n& Thanh toán",  icon: "arrow.left.arrow.right.circle")
        let rewards  = wrap(RewardsViewController(),   title: "Techcombank\nRewards",       icon: "rosette")
        let wealth   = wrap(WealthViewController(),    title: "Tổng quan\ntài sản",         icon: "brain.head.profile")

        viewControllers = [home, accounts, transfer, rewards, wealth]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = TCB.line

        let item = appearance.stackedLayoutAppearance
        item.normal.iconColor = TCB.inkSoft
        item.normal.titleTextAttributes = [
            .foregroundColor: TCB.ink,
            .font: TCB.brandFont(9.5)
        ]
        item.selected.iconColor = TCB.red
        item.selected.titleTextAttributes = [
            .foregroundColor: TCB.red,
            .font: TCB.brandFont(9.5)
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = TCB.red
        tabBar.unselectedItemTintColor = TCB.inkSoft
        tabBar.itemPositioning = .fill
    }

    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }

    private func wrap(_ vc: UIViewController, title: String, icon: String?) -> UINavigationController {
        let nav = TCBNavigationController(rootViewController: vc)
        let image = icon.flatMap { UIImage(systemName: $0) } ?? RootTabBarController.diamondIcon()
        nav.tabBarItem = UITabBarItem(title: title, image: image.withRenderingMode(.alwaysTemplate), selectedImage: image.withRenderingMode(.alwaysTemplate))
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    // MARK: Diamond tab glyph

    static func diamondIcon(size: CGFloat = 26) -> UIImage {
        if let real = UIImage(named: "RealDiamond") {
            return real.withRenderingMode(.alwaysTemplate)
        }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size * 0.78))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: size, height: size * 0.78)
            let h = rect.height
            let w = rect.width

            func diamond(cx: CGFloat, cy: CGFloat, r: CGFloat) {
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: cx, y: cy)
                ctx.cgContext.rotate(by: .pi / 4)
                let side = r * 1.30
                let path = UIBezierPath(roundedRect: CGRect(x: -side / 2,
                                                            y: -side / 2,
                                                            width: side,
                                                            height: side),
                                        cornerRadius: side * 0.24)
                UIColor.black.setFill()
                path.fill()
                ctx.cgContext.restoreGState()
            }

            diamond(cx: w * 0.69, cy: h * 0.50, r: h * 0.44)
            diamond(cx: w * 0.27, cy: h * 0.50, r: h * 0.30)
        }.withRenderingMode(.alwaysTemplate)
    }
}

// MARK: - Nav controller

final class TCBNavigationController: UINavigationController {

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
}
