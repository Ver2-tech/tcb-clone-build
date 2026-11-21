import UIKit

final class AccountsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Tài khoản & Thẻ")
        build()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadFromState),
                                               name: .tcbStateChanged,
                                               object: nil)
    }

    @objc private func reloadFromState() { populate() }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func build() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        content.axis = .vertical
        content.spacing = 16
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

        populate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populate()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func populate() {
        content.arrangedSubviews.forEach {
            content.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        content.addArrangedSubview(totalCard())
        content.addArrangedSubview(SectionHeader("Tài khoản thanh toán"))

        for account in BankState.shared.accounts {
            content.addArrangedSubview(AccountCardView(name: account.name,
                                                       number: account.number,
                                                       balance: account.balance,
                                                       currency: account.kind,
                                                       masked: false))
        }

        content.addArrangedSubview(SectionHeader("Thẻ của bạn"))
        content.addArrangedSubview(AccountCreditCardView(number: "5123 4567 8901 4567",
                                                  holder: TCBUser.fullName,
                                                  expiry: "12/28",
                                                  tier: "PLATINUM"))
        content.addArrangedSubview(AccountCreditCardView(number: "5123 4567 8901 8899",
                                                  holder: "TRAN THI BICH",
                                                  expiry: "06/27",
                                                  tier: "CLASSIC"))

        content.addArrangedSubview(SectionHeader("Sao kê gần nhất"))

        let box = UIView()
        box.backgroundColor = .white
        box.layer.cornerRadius = 18
        box.layer.cornerCurve = .continuous
        box.tcbShadow(14, opacity: 0.05, dy: 6)
        box.translatesAutoresizingMaskIntoConstraints = false

        let rows = UIStackView()
        rows.axis = .vertical
        rows.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(rows)

        let items = BankState.shared.transactions
        for (index, item) in items.enumerated() {
            rows.addArrangedSubview(TransactionRow(item))
            if index < items.count - 1 { rows.addArrangedSubview(Hairline()) }
        }

        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo: box.topAnchor, constant: 2),
            rows.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -2),
            rows.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: TCB.cardPad),
            rows.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -TCB.cardPad)
        ])

        content.addArrangedSubview(box)
    }

    private func totalCard() -> UIView {
        let card = GradientView(colors: [TCB.red, TCB.redDeep],
                                start: CGPoint(x: 0.0, y: 0.0),
                                end: CGPoint(x: 1.0, y: 1.0))
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false

        let caption = UILabel()
        caption.text = "Tổng số dư"
        caption.font = TCB.font(12)
        caption.textColor = UIColor.white.withAlphaComponent(0.85)
        caption.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = TCB.money(BankState.shared.totalVND)
        amount.font = TCB.mono(26, .bold)
        amount.textColor = .white
        amount.translatesAutoresizingMaskIntoConstraints = false

        let note = UILabel()
        note.text = "3 tài khoản • cập nhật vừa xong"
        note.font = TCB.font(11)
        note.textColor = UIColor.white.withAlphaComponent(0.7)
        note.translatesAutoresizingMaskIntoConstraints = false

        [caption, amount, note].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 124),

            caption.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            caption.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),

            amount.leadingAnchor.constraint(equalTo: caption.leadingAnchor),
            amount.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 6),

            note.leadingAnchor.constraint(equalTo: caption.leadingAnchor),
            note.topAnchor.constraint(equalTo: amount.bottomAnchor, constant: 8)
        ])

        return card
    }
}

// MARK: - Card visual

final class AccountCreditCardView: UIView {

    init(number: String, holder: String, expiry: String, tier: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let gradient = GradientView(colors: [TCB.red, TCB.redDeep],
                                    start: CGPoint(x: 0.0, y: 0.0),
                                    end: CGPoint(x: 1.0, y: 1.0))
        gradient.layer.cornerRadius = 18
        gradient.layer.cornerCurve = .continuous
        gradient.clipsToBounds = true
        gradient.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradient)

        let brand = UILabel()
        brand.attributedText = NSAttributedString(string: "TECHCOMBANK", attributes: [
            .font: TCB.font(12, .heavy),
            .foregroundColor: UIColor.white,
            .kern: 1.2
        ])
        brand.translatesAutoresizingMaskIntoConstraints = false

        let tierLabel = UILabel()
        tierLabel.text = tier
        tierLabel.font = TCB.font(9, .semibold)
        tierLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        tierLabel.translatesAutoresizingMaskIntoConstraints = false

        let contactless = UIImageView(image: UIImage(systemName: "wave.3.right",
                                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)))
        contactless.tintColor = UIColor.white.withAlphaComponent(0.9)
        contactless.translatesAutoresizingMaskIntoConstraints = false

        let chip = UIView()
        chip.backgroundColor = UIColor(red: 0xD8/255.0, green: 0xC0/255.0, blue: 0x7A/255.0, alpha: 1.0)
        chip.layer.cornerRadius = 5
        chip.translatesAutoresizingMaskIntoConstraints = false

        let chipLine = UIView()
        chipLine.backgroundColor = UIColor(red: 0xB8/255.0, green: 0x9F/255.0, blue: 0x5A/255.0, alpha: 1.0)
        chipLine.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(chipLine)

        let numberLabel = UILabel()
        numberLabel.attributedText = NSAttributedString(string: number, attributes: [
            .font: TCB.mono(18, .semibold),
            .foregroundColor: UIColor.white,
            .kern: 1.4
        ])
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        let holderCaption = UILabel()
        holderCaption.text = "CHỦ THẺ"
        holderCaption.font = TCB.font(8, .medium)
        holderCaption.textColor = UIColor.white.withAlphaComponent(0.65)

        let holderLabel = UILabel()
        holderLabel.text = holder
        holderLabel.font = TCB.font(11, .semibold)
        holderLabel.textColor = .white

        let expiryCaption = UILabel()
        expiryCaption.text = "HIỆU LỰC"
        expiryCaption.font = TCB.font(8, .medium)
        expiryCaption.textColor = UIColor.white.withAlphaComponent(0.65)
        expiryCaption.textAlignment = .right

        let expiryLabel = UILabel()
        expiryLabel.text = expiry
        expiryLabel.font = TCB.mono(11, .semibold)
        expiryLabel.textColor = .white
        expiryLabel.textAlignment = .right

        let holderStack = UIStackView(arrangedSubviews: [holderCaption, holderLabel])
        holderStack.axis = .vertical
        holderStack.spacing = 2
        holderStack.translatesAutoresizingMaskIntoConstraints = false

        let expiryStack = UIStackView(arrangedSubviews: [expiryCaption, expiryLabel])
        expiryStack.axis = .vertical
        expiryStack.spacing = 2
        expiryStack.translatesAutoresizingMaskIntoConstraints = false

        [brand, tierLabel, contactless, chip, numberLabel, holderStack, expiryStack].forEach {
            gradient.addSubview($0)
        }

        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: topAnchor),
            gradient.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradient.heightAnchor.constraint(equalToConstant: 192),

            brand.topAnchor.constraint(equalTo: gradient.topAnchor, constant: 18),
            brand.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 18),

            tierLabel.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 3),
            tierLabel.leadingAnchor.constraint(equalTo: brand.leadingAnchor),

            contactless.trailingAnchor.constraint(equalTo: gradient.trailingAnchor, constant: -18),
            contactless.centerYAnchor.constraint(equalTo: brand.centerYAnchor, constant: 6),

            chip.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 18),
            chip.topAnchor.constraint(equalTo: tierLabel.bottomAnchor, constant: 18),
            chip.widthAnchor.constraint(equalToConstant: 36),
            chip.heightAnchor.constraint(equalToConstant: 26),

            chipLine.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 8),
            chipLine.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -8),
            chipLine.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            chipLine.heightAnchor.constraint(equalToConstant: 1),

            numberLabel.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 18),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: gradient.trailingAnchor, constant: -18),
            numberLabel.topAnchor.constraint(equalTo: chip.bottomAnchor, constant: 14),

            holderStack.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 18),
            holderStack.bottomAnchor.constraint(equalTo: gradient.bottomAnchor, constant: -16),

            expiryStack.trailingAnchor.constraint(equalTo: gradient.trailingAnchor, constant: -18),
            expiryStack.bottomAnchor.constraint(equalTo: holderStack.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
