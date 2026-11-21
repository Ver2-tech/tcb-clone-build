import UIKit

final class CardsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Thẻ")
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
        content.spacing = 14
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

        content.addArrangedSubview(CreditCardView(number: "5123 4567 8901 4567",
                                                  holder: TCBUser.fullName,
                                                  expiry: "12/28",
                                                  tier: "PLATINUM"))

        content.addArrangedSubview(SectionHeader("Quản lý thẻ"))

        content.addArrangedSubview(CardBox(rows: [
            infoRow("Hạn mức tín dụng", "200.000.000 VND"),
            Hairline(),
            infoRow("Dư nợ hiện tại", "12.450.000 VND"),
            Hairline(),
            infoRow("Ngày sao kê", "05 hàng tháng"),
            Hairline(),
            infoRow("Ngày đến hạn", "25 hàng tháng")
        ], padding: 0))

        content.addArrangedSubview(SectionHeader("Thẻ phụ"))

        content.addArrangedSubview(CreditCardView(number: "5123 4567 8901 8899",
                                                  holder: "TRAN THI BICH",
                                                  expiry: "06/27",
                                                  tier: "CLASSIC"))
    }

    private func infoRow(_ label: String, _ value: String) -> UIView {
        let l = UILabel()
        l.text = label
        l.font = TCB.font(13)
        l.textColor = TCB.inkSoft

        let v = UILabel()
        v.text = value
        v.font = TCB.mono(14, .medium)
        v.textColor = TCB.ink
        v.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [l, v])
        row.axis = .horizontal
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 13, left: TCB.cardPad, bottom: 13, right: TCB.cardPad)
        return row
    }
}

// MARK: - Card visual

final class CreditCardView: UIView {

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
        brand.text = "TECHCOMBANK"
        brand.font = TCB.font(13, .bold)
        brand.textColor = .white
        brand.attributedText = NSAttributedString(string: "TECHCOMBANK", attributes: [
            .font: TCB.font(13, .bold),
            .foregroundColor: UIColor.white,
            .kern: 1.4
        ])
        brand.translatesAutoresizingMaskIntoConstraints = false

        let tierLabel = UILabel()
        tierLabel.text = tier
        tierLabel.font = TCB.font(10, .semibold)
        tierLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        tierLabel.translatesAutoresizingMaskIntoConstraints = false

        let contactless = UIImageView(image: UIImage(systemName: "wave.3.right",
                                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)))
        contactless.tintColor = UIColor.white.withAlphaComponent(0.9)
        contactless.translatesAutoresizingMaskIntoConstraints = false

        let chip = UIView()
        chip.backgroundColor = UIColor(red: 0xD8/255.0, green: 0xC0/255.0, blue: 0x7A/255.0, alpha: 1.0)
        chip.layer.cornerRadius = 5
        chip.translatesAutoresizingMaskIntoConstraints = false

        let chipLines = UIView()
        chipLines.backgroundColor = UIColor(red: 0xB8/255.0, green: 0x9F/255.0, blue: 0x5A/255.0, alpha: 1.0)
        chipLines.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(chipLines)

        let numberLabel = UILabel()
        numberLabel.attributedText = NSAttributedString(string: number, attributes: [
            .font: TCB.mono(19, .semibold),
            .foregroundColor: UIColor.white,
            .kern: 1.6
        ])
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        let holderCaption = UILabel()
        holderCaption.text = "CHỦ THẺ"
        holderCaption.font = TCB.font(9, .medium)
        holderCaption.textColor = UIColor.white.withAlphaComponent(0.65)

        let holderLabel = UILabel()
        holderLabel.text = holder
        holderLabel.font = TCB.font(12, .semibold)
        holderLabel.textColor = .white

        let expiryCaption = UILabel()
        expiryCaption.text = "HIỆU LỰC"
        expiryCaption.font = TCB.font(9, .medium)
        expiryCaption.textColor = UIColor.white.withAlphaComponent(0.65)
        expiryCaption.textAlignment = .right

        let expiryLabel = UILabel()
        expiryLabel.text = expiry
        expiryLabel.font = TCB.mono(12, .semibold)
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
            gradient.heightAnchor.constraint(equalToConstant: 200),

            brand.topAnchor.constraint(equalTo: gradient.topAnchor, constant: 20),
            brand.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 20),

            tierLabel.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 3),
            tierLabel.leadingAnchor.constraint(equalTo: brand.leadingAnchor),

            contactless.trailingAnchor.constraint(equalTo: gradient.trailingAnchor, constant: -20),
            contactless.centerYAnchor.constraint(equalTo: brand.centerYAnchor, constant: 6),

            chip.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 20),
            chip.topAnchor.constraint(equalTo: tierLabel.bottomAnchor, constant: 20),
            chip.widthAnchor.constraint(equalToConstant: 38),
            chip.heightAnchor.constraint(equalToConstant: 28),

            chipLines.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 9),
            chipLines.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -9),
            chipLines.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            chipLines.heightAnchor.constraint(equalToConstant: 1),

            numberLabel.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 20),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: gradient.trailingAnchor, constant: -20),
            numberLabel.topAnchor.constraint(equalTo: chip.bottomAnchor, constant: 16),

            holderStack.leadingAnchor.constraint(equalTo: gradient.leadingAnchor, constant: 20),
            holderStack.bottomAnchor.constraint(equalTo: gradient.bottomAnchor, constant: -18),

            expiryStack.trailingAnchor.constraint(equalTo: gradient.trailingAnchor, constant: -20),
            expiryStack.bottomAnchor.constraint(equalTo: holderStack.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
