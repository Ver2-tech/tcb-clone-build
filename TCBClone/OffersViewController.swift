import UIKit

final class OffersViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    private struct Offer {
        let title: String
        let detail: String
        let expiry: String
        let symbol: String
        let tint: UIColor
    }

    private let offers: [Offer] = [
        Offer(title: "Hoàn 10% khi thanh toán online",
              detail: "Áp dụng cho thẻ tín dụng Techcombank, tối đa 200.000 VND",
              expiry: "31/12/2024", symbol: "percent", tint: TCB.red),
        Offer(title: "Giảm 50.000 VND tại Highlands Coffee",
              detail: "Thanh toán bằng QR Pay Techcombank",
              expiry: "30/11/2024", symbol: "cup.and.saucer.fill", tint: UIColor(red: 0xC0/255.0, green: 0x6A/255.0, blue: 0x2B/255.0, alpha: 1)),
        Offer(title: "Ưu đãi lãi suất tiết kiệm 6,2%/năm",
              detail: "Kỳ hạn 12 tháng, gửi online",
              expiry: "15/12/2024", symbol: "chart.line.uptrend.xyaxis", tint: UIColor(red: 0x12/255.0, green: 0xA5/255.0, blue: 0x5C/255.0, alpha: 1)),
        Offer(title: "Miễn phí chuyển khoản 24/7",
              detail: "Toàn bộ giao dịch trong nước",
              expiry: "Không thời hạn", symbol: "arrow.left.arrow.right", tint: UIColor(red: 0x2E/255.0, green: 0x5E/255.0, blue: 0xC9/255.0, alpha: 1))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Ưu đãi")
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func build() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: TCB.gutter),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -TCB.gutter),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -32)
        ])

        let hero = GradientView(colors: [TCB.red, TCB.redDeep])
        hero.layer.cornerRadius = TCB.radius
        hero.layer.cornerCurve = .continuous
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.heightAnchor.constraint(equalToConstant: 128).isActive = true

        let heroTitle = UILabel()
        heroTitle.text = "Ưu đãi dành riêng cho bạn"
        heroTitle.font = TCB.font(18, .bold)
        heroTitle.textColor = .white
        heroTitle.translatesAutoresizingMaskIntoConstraints = false

        let heroSub = UILabel()
        heroSub.text = "4 ưu đãi đang hiệu lực"
        heroSub.font = TCB.font(13)
        heroSub.textColor = UIColor.white.withAlphaComponent(0.85)
        heroSub.translatesAutoresizingMaskIntoConstraints = false

        hero.addSubview(heroTitle)
        hero.addSubview(heroSub)
        NSLayoutConstraint.activate([
            heroTitle.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 18),
            heroTitle.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -18),
            heroTitle.bottomAnchor.constraint(equalTo: heroSub.topAnchor, constant: -6),
            heroSub.leadingAnchor.constraint(equalTo: heroTitle.leadingAnchor),
            heroSub.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -18)
        ])

        content.addArrangedSubview(hero)

        for offer in offers {
            content.addArrangedSubview(card(offer))
        }
    }

    private func card(_ offer: Offer) -> UIView {
        let bubble = UIView()
        bubble.backgroundColor = offer.tint.withAlphaComponent(0.10)
        bubble.layer.cornerRadius = 12
        bubble.translatesAutoresizingMaskIntoConstraints = false

        let glyph = UIImageView(image: UIImage(systemName: offer.symbol,
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)))
        glyph.tintColor = offer.tint
        glyph.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(glyph)

        let title = UILabel()
        title.text = offer.title
        title.font = TCB.font(14, .semibold)
        title.textColor = TCB.ink
        title.numberOfLines = 2
        title.translatesAutoresizingMaskIntoConstraints = false

        let detail = UILabel()
        detail.text = offer.detail
        detail.font = TCB.font(12)
        detail.textColor = TCB.inkSoft
        detail.numberOfLines = 2
        detail.translatesAutoresizingMaskIntoConstraints = false

        let expiry = UILabel()
        expiry.text = "HSD: " + offer.expiry
        expiry.font = TCB.font(11)
        expiry.textColor = TCB.inkFaint
        expiry.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [title, detail, expiry])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setCustomSpacing(6, after: detail)
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let box = UIView()
        box.backgroundColor = TCB.card
        box.layer.cornerRadius = TCB.radius
        box.layer.cornerCurve = .continuous
        box.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(bubble)
        box.addSubview(textStack)

        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: 96),

            bubble.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: TCB.cardPad),
            bubble.topAnchor.constraint(equalTo: box.topAnchor, constant: TCB.cardPad),
            bubble.widthAnchor.constraint(equalToConstant: 44),
            bubble.heightAnchor.constraint(equalToConstant: 44),

            glyph.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -TCB.cardPad),
            textStack.topAnchor.constraint(equalTo: box.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: box.bottomAnchor, constant: -14)
        ])

        return box
    }
}
