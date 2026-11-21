import UIKit

final class HomeViewController: UIViewController, QRScannerDelegate {

    // MARK: Views

    private let scroll = UIScrollView()
    private let hero = GradientView(colors: [TCB.heroStart, TCB.heroMid, TCB.heroEnd],
                                    start: CGPoint(x: 0.0, y: 0.0),
                                    end: CGPoint(x: 1.0, y: 1.0))
    private let scene = HeroSceneView()
    private let sheet = UIView()
    private let strip = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))

    private let balanceCard = CapsuleCard(radius: 12, shadow: true)
    private let balanceLabel = UILabel()

    private var heroHeight: NSLayoutConstraint!
    private var badgeTop: NSLayoutConstraint!
    private var balanceTop: NSLayoutConstraint!
    private var sheetTop: NSLayoutConstraint!

    private var balanceHidden = false

    private var total: Int64 { BankState.shared.totalVND }

    private let promos: [(kicker: String, title: String, cta: String, tint: [UIColor])] = [
        ("TECHCOMBANK REWARDS",
         "Voucher Shopee luôn có sẵn quanh năm với đủ mệnh giá tới 500K",
         "Đổi voucher ngay",
         [UIColor(red: 0xFF/255.0, green: 0xD9/255.0, blue: 0xC8/255.0, alpha: 1.0),
          UIColor(red: 0xFF/255.0, green: 0xBE/255.0, blue: 0xB4/255.0, alpha: 1.0)]),
        ("SINH LỜI TỰ ĐỘNG",
         "Tiền nhàn rỗi vẫn sinh lời mỗi ngày, rút bất cứ lúc nào",
         "Tìm hiểu ngay",
         [UIColor(red: 0xFF/255.0, green: 0xE9/255.0, blue: 0xC2/255.0, alpha: 1.0),
          UIColor(red: 0xFF/255.0, green: 0xD3/255.0, blue: 0x9C/255.0, alpha: 1.0)]),
        ("TECHCOMBANK PRIORITY",
         "Đặc quyền tài chính và dịch vụ riêng cho hội viên Priority",
         "Khám phá",
         [UIColor(red: 0xEC/255.0, green: 0xE2/255.0, blue: 0xD6/255.0, alpha: 1.0),
          UIColor(red: 0xD6/255.0, green: 0xC6/255.0, blue: 0xB4/255.0, alpha: 1.0)])
    ]

    private let dots = PageDots(count: 3, index: 0)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildScroll()
        buildHero()
        buildSheet()
        buildStrip()
        buildBody()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stateChanged),
                                               name: .tcbStateChanged,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func stateChanged() {
        if !balanceHidden { setBalanceText() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard heroHeight != nil else { return }
        let top = view.safeAreaInsets.top
        heroHeight.constant = 300 + top
        badgeTop.constant = top + 10
        balanceTop.constant = top + 96
        sheetTop.constant = -6
    }

    // MARK: Scroll

    private func buildScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Hero

    private func buildHero() {
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.clipsToBounds = true
        scroll.addSubview(hero)

        scene.translatesAutoresizingMaskIntoConstraints = false
        hero.addSubview(scene)

        let badge = TMBadge()
        badge.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        hero.addSubview(badge)

        // Chuông + badge 19
        let bellCircle = UIView()
        bellCircle.backgroundColor = UIColor.white.withAlphaComponent(0.28)
        bellCircle.layer.cornerRadius = 20
        bellCircle.translatesAutoresizingMaskIntoConstraints = false

        let bell = UIImageView(image: UIImage(systemName: "bell",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)))
        bell.tintColor = .white
        bell.translatesAutoresizingMaskIntoConstraints = false
        bellCircle.addSubview(bell)

        let dot = UILabel()
        dot.text = "19"
        dot.font = TCB.font(9, .bold)
        dot.textColor = .white
        dot.textAlignment = .center
        dot.backgroundColor = TCB.red
        dot.layer.cornerRadius = 8
        dot.layer.borderWidth = 1.5
        dot.layer.borderColor = UIColor.white.cgColor
        dot.clipsToBounds = true
        dot.translatesAutoresizingMaskIntoConstraints = false

        let bellButton = UIButton(type: .custom)
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.addTarget(self, action: #selector(openRewards), for: .touchUpInside)

        hero.addSubview(bellCircle)
        hero.addSubview(dot)
        hero.addSubview(bellButton)

        // Thẻ số dư
        balanceCard.translatesAutoresizingMaskIntoConstraints = false
        hero.addSubview(balanceCard)

        let caption = UILabel()
        caption.text = "Số dư hiện có"
        caption.font = TCB.font(12)
        caption.textColor = TCB.inkSoft
        caption.translatesAutoresizingMaskIntoConstraints = false

        let caret = UIImageView(image: UIImage(systemName: "chevron.down",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)))
        caret.tintColor = TCB.inkSoft
        caret.translatesAutoresizingMaskIntoConstraints = false

        setBalanceText()

        let eye = UIButton(type: .system)
        eye.setImage(UIImage(systemName: "eye",
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)),
                     for: .normal)
        eye.tintColor = TCB.inkSoft
        eye.translatesAutoresizingMaskIntoConstraints = false
        eye.addTarget(self, action: #selector(toggleBalance), for: .touchUpInside)

        [caption, caret, balanceLabel, eye].forEach { balanceCard.addSubview($0) }

        heroHeight = hero.heightAnchor.constraint(equalToConstant: 360)
        badgeTop = badge.topAnchor.constraint(equalTo: hero.topAnchor, constant: 54)
        balanceTop = balanceCard.topAnchor.constraint(equalTo: hero.topAnchor, constant: 140)

        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            hero.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            hero.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            hero.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            heroHeight,

            scene.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            scene.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            scene.bottomAnchor.constraint(equalTo: hero.bottomAnchor),
            scene.heightAnchor.constraint(equalTo: hero.heightAnchor, multiplier: 0.62),

            badge.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            badgeTop,

            bellCircle.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -20),
            bellCircle.centerYAnchor.constraint(equalTo: badge.topAnchor, constant: 24),
            bellCircle.widthAnchor.constraint(equalToConstant: 40),
            bellCircle.heightAnchor.constraint(equalToConstant: 40),

            bell.centerXAnchor.constraint(equalTo: bellCircle.centerXAnchor),
            bell.centerYAnchor.constraint(equalTo: bellCircle.centerYAnchor),

            dot.widthAnchor.constraint(equalToConstant: 18),
            dot.heightAnchor.constraint(equalToConstant: 16),
            dot.centerXAnchor.constraint(equalTo: bellCircle.trailingAnchor, constant: -2),
            dot.centerYAnchor.constraint(equalTo: bellCircle.topAnchor, constant: 1),

            bellButton.trailingAnchor.constraint(equalTo: bellCircle.trailingAnchor, constant: 4),
            bellButton.leadingAnchor.constraint(equalTo: bellCircle.leadingAnchor, constant: -4),
            bellButton.topAnchor.constraint(equalTo: bellCircle.topAnchor, constant: -4),
            bellButton.bottomAnchor.constraint(equalTo: bellCircle.bottomAnchor, constant: 4),

            balanceCard.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 24),
            balanceCard.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -24),
            balanceTop,
            balanceCard.heightAnchor.constraint(equalToConstant: 70),

            caption.leadingAnchor.constraint(equalTo: balanceCard.leadingAnchor, constant: 16),
            caption.topAnchor.constraint(equalTo: balanceCard.topAnchor, constant: 13),

            caret.leadingAnchor.constraint(equalTo: caption.trailingAnchor, constant: 6),
            caret.centerYAnchor.constraint(equalTo: caption.centerYAnchor),

            balanceLabel.leadingAnchor.constraint(equalTo: caption.leadingAnchor),
            balanceLabel.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 4),

            eye.trailingAnchor.constraint(equalTo: balanceCard.trailingAnchor, constant: -16),
            eye.centerYAnchor.constraint(equalTo: balanceCard.centerYAnchor, constant: 6)
        ])
    }

    private func setBalanceText() {
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "VND ", attributes: [
            .font: TCB.font(17, .regular),
            .foregroundColor: TCB.ink
        ]))
        text.append(NSAttributedString(string: TCB.grouped(total), attributes: [
            .font: TCB.mono(19, .semibold),
            .foregroundColor: TCB.ink
        ]))
        balanceLabel.attributedText = text
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: Sheet

    private func buildSheet() {
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 20
        sheet.layer.cornerCurve = .continuous
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(sheet)

        sheetTop = sheet.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: -6)

        NSLayoutConstraint.activate([
            sheetTop,
            sheet.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            sheet.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: Action strip

    private func buildStrip() {
        strip.translatesAutoresizingMaskIntoConstraints = false
        strip.clipsToBounds = true
        scroll.addSubview(strip)

        let tint = UIView()
        tint.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        tint.translatesAutoresizingMaskIntoConstraints = false
        strip.contentView.addSubview(tint)

        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false
        strip.contentView.addSubview(row)

        let items: [(String, String)] = [
            ("Gửi\ntiết kiệm", "banknote"),
            ("Thanh toán\nhoá đơn", "doc.text"),
            ("Quét\nmã QR", "qrcode.viewfinder"),
            ("Sinh lời\ntự động", "arrow.triangle.2.circlepath"),
            ("Tính năng\nkhác", "arrow.right")
        ]

        for (index, item) in items.enumerated() {
            let action = CircleAction(title: item.0, systemImage: item.1)
            action.tag = index
            action.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            row.addArrangedSubview(action)
        }

        NSLayoutConstraint.activate([
            strip.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: -52),
            strip.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            strip.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            strip.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            strip.heightAnchor.constraint(equalToConstant: 104),

            tint.topAnchor.constraint(equalTo: strip.contentView.topAnchor),
            tint.bottomAnchor.constraint(equalTo: strip.contentView.bottomAnchor),
            tint.leadingAnchor.constraint(equalTo: strip.contentView.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: strip.contentView.trailingAnchor),

            row.topAnchor.constraint(equalTo: strip.contentView.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: strip.contentView.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: strip.contentView.trailingAnchor, constant: -12)
        ])
    }

    // MARK: Body

    private func buildBody() {
        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 16
        body.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(body)

        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 64),
            body.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: TCB.gutter),
            body.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -TCB.gutter),
            body.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            sheet.bottomAnchor.constraint(equalTo: body.bottomAnchor, constant: 24)
        ])

        body.addArrangedSubview(SectionHeader("Dành cho bạn"))
        body.addArrangedSubview(carousel())
        body.addArrangedSubview(dots)

        body.addArrangedSubview(SectionHeader("Tài khoản của bạn",
                                              action: "Xem tất cả",
                                              target: self,
                                              selector: #selector(openAccounts)))

        for account in TCBStore.accounts.prefix(2) {
            let card = AccountCardView(name: account.name,
                                       number: account.number,
                                       balance: account.balance,
                                       currency: account.kind)
            card.isUserInteractionEnabled = true
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAccounts)))
            body.addArrangedSubview(card)
        }

        body.addArrangedSubview(SectionHeader("Giao dịch gần đây",
                                              action: "Lịch sử",
                                              target: self,
                                              selector: #selector(openAccounts)))
        body.addArrangedSubview(transactionCard())
    }

    // MARK: Carousel

    private func carousel() -> UIView {
        let holder = UIView()
        holder.translatesAutoresizingMaskIntoConstraints = false

        let carouselScroll = UIScrollView()
        carouselScroll.showsHorizontalScrollIndicator = false
        carouselScroll.clipsToBounds = false
        carouselScroll.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(carouselScroll)

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        carouselScroll.addSubview(row)

        for promo in promos {
            row.addArrangedSubview(promoCard(kicker: promo.kicker,
                                             title: promo.title,
                                             cta: promo.cta,
                                             tint: promo.tint))
        }

        NSLayoutConstraint.activate([
            holder.heightAnchor.constraint(equalToConstant: 152),

            carouselScroll.topAnchor.constraint(equalTo: holder.topAnchor),
            carouselScroll.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
            carouselScroll.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
            carouselScroll.bottomAnchor.constraint(equalTo: holder.bottomAnchor),

            row.topAnchor.constraint(equalTo: carouselScroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: carouselScroll.contentLayoutGuide.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: carouselScroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: carouselScroll.contentLayoutGuide.trailingAnchor),
            row.heightAnchor.constraint(equalTo: carouselScroll.frameLayoutGuide.heightAnchor)
        ])

        return holder
    }

    private func promoCard(kicker: String, title: String, cta: String, tint: [UIColor]) -> UIView {
        let card = GradientView(colors: tint, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 1.0, y: 1.0))
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 330).isActive = true

        let art = GradientView(colors: [UIColor(red: 0xFF/255.0, green: 0x8A/255.0, blue: 0x6B/255.0, alpha: 1.0),
                                        UIColor(red: 0xF3/255.0, green: 0x6C/255.0, blue: 0x55/255.0, alpha: 1.0)],
                               start: CGPoint(x: 0.0, y: 0.0),
                               end: CGPoint(x: 1.0, y: 1.0))
        art.layer.cornerRadius = 12
        art.layer.cornerCurve = .continuous
        art.clipsToBounds = true
        art.translatesAutoresizingMaskIntoConstraints = false

        let bagBack = UIImageView(image: UIImage(systemName: "bag.fill",
                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)))
        bagBack.tintColor = UIColor(red: 0xC9/255.0, green: 0x3B/255.0, blue: 0x2C/255.0, alpha: 1.0)
        bagBack.transform = CGAffineTransform(rotationAngle: -0.12)
        bagBack.translatesAutoresizingMaskIntoConstraints = false

        let bagFront = UIImageView(image: UIImage(systemName: "bag.fill",
                                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)))
        bagFront.tintColor = UIColor(red: 0xF6/255.0, green: 0xB4/255.0, blue: 0x4C/255.0, alpha: 1.0)
        bagFront.transform = CGAffineTransform(rotationAngle: 0.10)
        bagFront.translatesAutoresizingMaskIntoConstraints = false

        let spark = UIImageView(image: UIImage(systemName: "sparkle",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)))
        spark.tintColor = .white
        spark.translatesAutoresizingMaskIntoConstraints = false

        art.addSubview(bagBack)
        art.addSubview(bagFront)
        art.addSubview(spark)

        let kickerLabel = UILabel()
        kickerLabel.attributedText = NSAttributedString(string: kicker, attributes: [
            .font: TCB.font(9, .semibold),
            .foregroundColor: UIColor(red: 0x9C/255.0, green: 0x40/255.0, blue: 0x30/255.0, alpha: 1.0),
            .kern: 0.6
        ])
        kickerLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TCB.font(14, .semibold)
        titleLabel.textColor = TCB.ink
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let ctaButton = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = TCB.ink
        cfg.baseForegroundColor = .white
        cfg.cornerStyle = .capsule
        cfg.title = cta
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = TCB.font(12, .semibold)
            return out
        }
        ctaButton.configuration = cfg
        ctaButton.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(art)
        card.addSubview(kickerLabel)
        card.addSubview(titleLabel)
        card.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            art.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            art.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            art.widthAnchor.constraint(equalToConstant: 104),
            art.heightAnchor.constraint(equalToConstant: 130),

            bagBack.leadingAnchor.constraint(equalTo: art.leadingAnchor, constant: 16),
            bagBack.bottomAnchor.constraint(equalTo: art.bottomAnchor, constant: -22),
            bagFront.trailingAnchor.constraint(equalTo: art.trailingAnchor, constant: -16),
            bagFront.bottomAnchor.constraint(equalTo: art.bottomAnchor, constant: -14),
            spark.trailingAnchor.constraint(equalTo: art.trailingAnchor, constant: -12),
            spark.topAnchor.constraint(equalTo: art.topAnchor, constant: 16),

            kickerLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            kickerLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            kickerLabel.trailingAnchor.constraint(lessThanOrEqualTo: art.leadingAnchor, constant: -8),

            titleLabel.leadingAnchor.constraint(equalTo: kickerLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: kickerLabel.bottomAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: art.leadingAnchor, constant: -10),

            ctaButton.leadingAnchor.constraint(equalTo: kickerLabel.leadingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    private func transactionCard() -> UIView {
        let box = UIView()
        box.backgroundColor = TCB.card
        box.layer.cornerRadius = 16
        box.layer.cornerCurve = .continuous
        box.tcbShadow(14, opacity: 0.05, dy: 6)
        box.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(stack)

        let items = Array(TCBStore.transactions.prefix(4))
        for (index, item) in items.enumerated() {
            stack.addArrangedSubview(TransactionRow(item))
            if index < items.count - 1 { stack.addArrangedSubview(Hairline()) }
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 2),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -2),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: TCB.cardPad),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -TCB.cardPad)
        ])

        return box
    }

    // MARK: Actions

    @objc private func toggleBalance() {
        balanceHidden.toggle()
        UIView.transition(with: balanceLabel, duration: 0.18, options: .transitionCrossDissolve) {
            if self.balanceHidden {
                self.balanceLabel.text = "VND ••••••••"
            } else {
                self.setBalanceText()
            }
        }
    }

    @objc private func actionTapped(_ sender: CircleAction) {
        switch sender.tag {
        case 0:
            navigationController?.pushViewController(SavingsViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(BillsViewController(), animated: true)
        case 2:
            let scanner = QRScannerViewController()
            scanner.delegate = self
            navigationController?.pushViewController(scanner, animated: true)
        case 3:
            navigationController?.pushViewController(AutoEarnViewController(), animated: true)
        default:
            navigationController?.pushViewController(MoreViewController(), animated: true)
        }
    }

    func qrScanner(_ scanner: QRScannerViewController, didRead info: QRPayInfo) {
        let transfer = TransferViewController()
        transfer.prefill(name: info.name,
                         account: info.account,
                         bank: info.bank,
                         amount: info.amount,
                         note: info.note)
        navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(transfer, animated: true)
    }

    @objc private func openAccounts() { tabBarController?.selectedIndex = 1 }
    @objc private func openRewards()  { tabBarController?.selectedIndex = 3 }

    @objc private func openSettings() {
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
}
