import UIKit

// MARK: - Gradient surface

final class GradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradient: CAGradientLayer { layer as! CAGradientLayer }

    init(colors: [UIColor],
         start: CGPoint = CGPoint(x: 0.0, y: 0.0),
         end: CGPoint = CGPoint(x: 1.0, y: 1.0)) {
        super.init(frame: .zero)
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = start
        gradient.endPoint = end
        if colors.count == 3 {
            gradient.locations = [0.0, 0.5, 1.0]
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Brand mark
//
// Con dấu Techcombank: hai khối thoi đỏ, khối trái nhỏ, khối phải lớn,
// chồng mép nhau — đúng hình trên logo chính thức.

final class DiamondMark: UIView {

    var color: UIColor = TCB.red {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 34, height: 26)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let h = rect.height
        let w = rect.width

        ctx.saveGState()
        color.setFill()

        func diamond(cx: CGFloat, cy: CGFloat, r: CGFloat) {
            ctx.saveGState()
            ctx.translateBy(x: cx, y: cy)
            ctx.rotate(by: .pi / 4)
            let side = r * 1.34
            let path = UIBezierPath(roundedRect: CGRect(x: -side / 2,
                                                        y: -side / 2,
                                                        width: side,
                                                        height: side),
                                    cornerRadius: side * 0.22)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            ctx.restoreGState()
        }

        let bigR   = h * 0.44
        let smallR = h * 0.30
        diamond(cx: w * 0.68, cy: h * 0.50, r: bigR)
        diamond(cx: w * 0.26, cy: h * 0.50, r: smallR)

        ctx.restoreGState()
    }
}

// MARK: - Wordmark "TECHCOM" đỏ + "BANK" đen + con dấu

final class BrandLockup: UIView {

    init(light: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let word = UILabel()
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "TECHCOM", attributes: [
            .font: TCB.font(19, .heavy),
            .foregroundColor: TCB.red,
            .kern: -0.2
        ]))
        text.append(NSAttributedString(string: "BANK", attributes: [
            .font: TCB.font(19, .heavy),
            .foregroundColor: light ? UIColor.white : TCB.ink,
            .kern: -0.2
        ]))
        word.attributedText = text
        word.translatesAutoresizingMaskIntoConstraints = false

        let mark = DiamondMark()
        mark.color = TCB.red
        mark.translatesAutoresizingMaskIntoConstraints = false

        addSubview(word)
        addSubview(mark)

        NSLayoutConstraint.activate([
            word.leadingAnchor.constraint(equalTo: leadingAnchor),
            word.centerYAnchor.constraint(equalTo: centerYAnchor),

            mark.leadingAnchor.constraint(equalTo: word.trailingAnchor, constant: 9),
            mark.trailingAnchor.constraint(equalTo: trailingAnchor),
            mark.centerYAnchor.constraint(equalTo: centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 38),
            mark.heightAnchor.constraint(equalToConstant: 26),

            heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - App logo (dùng ở màn đăng nhập / PIN)

final class LogoView: UIView {

    init(height: CGFloat = 56) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        if let image = UIImage(named: "Logo") {
            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            NSLayoutConstraint.activate([
                iv.topAnchor.constraint(equalTo: topAnchor),
                iv.bottomAnchor.constraint(equalTo: bottomAnchor),
                iv.centerXAnchor.constraint(equalTo: centerXAnchor),
                iv.widthAnchor.constraint(equalToConstant: height * 1.6),
                heightAnchor.constraint(equalToConstant: height)
            ])
        } else {
            let mark = DiamondMark()
            mark.translatesAutoresizingMaskIntoConstraints = false
            addSubview(mark)
            NSLayoutConstraint.activate([
                mark.centerXAnchor.constraint(equalTo: centerXAnchor),
                mark.centerYAnchor.constraint(equalTo: centerYAnchor),
                mark.widthAnchor.constraint(equalToConstant: height),
                mark.heightAnchor.constraint(equalToConstant: height * 0.72),
                heightAnchor.constraint(equalToConstant: height)
            ])
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Grouped card
//
// Khung trắng chứa các dòng form / menu. Các dòng đã tự có padding riêng
// nên khi truyền padding = 0 thì stack sát mép card.

final class CardBox: UIView {

    init(rows: [UIView], padding: CGFloat = 16) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = TCB.radius
        layer.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false
        tcbShadow(12, opacity: 0.04, dy: 4)

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Hairline

final class Hairline: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = TCB.line
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Capsule card

final class CapsuleCard: UIView {

    init(radius: CGFloat = 16, shadow: Bool = true) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false
        if shadow { tcbShadow() }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Section header

final class SectionHeader: UIView {

    init(_ title: String, action: String? = nil, target: Any? = nil, selector: Selector? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = TCB.font(17, .bold)
        label.textColor = TCB.ink
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if let action = action {
            let button = UIButton(type: .system)
            button.setTitle(action, for: .normal)
            button.setTitleColor(TCB.inkSoft, for: .normal)
            button.titleLabel?.font = TCB.font(13, .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            if let target = target, let selector = selector {
                button.addTarget(target, action: selector, for: .touchUpInside)
            }
            addSubview(button)
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: trailingAnchor),
                button.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - TM badge (góc trái hero)

final class TMBadge: UIControl {

    init(initials: String = TCBUser.initials, tier: String = TCBUser.tier) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let ring = UIView()
        ring.layer.cornerRadius = 24
        ring.layer.borderWidth = 1.2
        ring.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
        ring.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        ring.isUserInteractionEnabled = false
        ring.translatesAutoresizingMaskIntoConstraints = false

        let initialsLabel = UILabel()
        initialsLabel.text = initials
        initialsLabel.font = TCB.font(15, .semibold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        ring.addSubview(initialsLabel)

        let pill = UIView()
        pill.backgroundColor = UIColor(red: 0x33/255.0, green: 0x14/255.0, blue: 0x12/255.0, alpha: 0.78)
        pill.layer.cornerRadius = 9
        pill.translatesAutoresizingMaskIntoConstraints = false

        let tierLabel = UILabel()
        tierLabel.text = tier
        tierLabel.font = TCB.font(9, .semibold)
        tierLabel.textColor = .white
        tierLabel.textAlignment = .center
        tierLabel.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(tierLabel)

        addSubview(ring)
        addSubview(pill)

        NSLayoutConstraint.activate([
            ring.widthAnchor.constraint(equalToConstant: 48),
            ring.heightAnchor.constraint(equalToConstant: 48),
            ring.topAnchor.constraint(equalTo: topAnchor),
            ring.leadingAnchor.constraint(equalTo: leadingAnchor),

            initialsLabel.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: ring.centerYAnchor),

            pill.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: -2),
            pill.leadingAnchor.constraint(equalTo: ring.leadingAnchor, constant: -2),
            pill.trailingAnchor.constraint(equalTo: ring.trailingAnchor, constant: 2),
            pill.heightAnchor.constraint(equalToConstant: 18),
            pill.bottomAnchor.constraint(equalTo: bottomAnchor),

            tierLabel.centerXAnchor.constraint(equalTo: pill.centerXAnchor),
            tierLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Circular action (thanh nổi)

final class CircleAction: UIControl {

    private let circle = UIView()
    private let icon = UIImageView()
    private let caption = UILabel()

    init(title: String, systemImage: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        circle.backgroundColor = .white
        circle.layer.cornerRadius = 24
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.tcbShadow(8, opacity: 0.06, dy: 3)

        icon.image = UIImage(systemName: systemImage,
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .regular))
        icon.tintColor = TCB.ink
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(icon)

        caption.text = title
        caption.font = TCB.font(11, .medium)
        caption.textColor = TCB.ink
        caption.textAlignment = .center
        caption.numberOfLines = 2
        caption.translatesAutoresizingMaskIntoConstraints = false

        addSubview(circle)
        addSubview(caption)

        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 48),
            circle.heightAnchor.constraint(equalToConstant: 48),
            circle.topAnchor.constraint(equalTo: topAnchor),
            circle.centerXAnchor.constraint(equalTo: centerXAnchor),

            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),

            caption.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 7),
            caption.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4),
            caption.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            caption.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.circle.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.92, y: 0.92)
                    : .identity
            }
        }
    }
}

// MARK: - Tier badge (giữ cho màn cũ)

final class TierBadge: UIControl {

    init(tier: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let ring = UIView()
        ring.layer.cornerRadius = 22
        ring.layer.borderWidth = 1.2
        ring.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        ring.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        ring.isUserInteractionEnabled = false
        ring.translatesAutoresizingMaskIntoConstraints = false

        let initials = UILabel()
        initials.text = "TM"
        initials.font = TCB.font(12, .semibold)
        initials.textColor = .white
        initials.textAlignment = .center
        initials.translatesAutoresizingMaskIntoConstraints = false
        ring.addSubview(initials)

        let label = UILabel()
        label.text = tier
        label.font = TCB.font(10, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(ring)
        addSubview(label)

        NSLayoutConstraint.activate([
            ring.widthAnchor.constraint(equalToConstant: 44),
            ring.heightAnchor.constraint(equalToConstant: 44),
            ring.topAnchor.constraint(equalTo: topAnchor),
            ring.centerXAnchor.constraint(equalTo: centerXAnchor),

            initials.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: ring.centerYAnchor),

            label.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Account card

final class AccountCardView: UIView {

    init(name: String, number: String, balance: Int64, currency: String, masked: Bool = true) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = TCB.card
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        tcbShadow(14, opacity: 0.05, dy: 6)

        let title = UILabel()
        title.text = name
        title.font = TCB.font(13)
        title.textColor = TCB.inkSoft
        title.translatesAutoresizingMaskIntoConstraints = false

        let num = UILabel()
        num.text = masked ? Self.mask(number) : number
        num.font = TCB.mono(12)
        num.textColor = TCB.inkFaint
        num.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = TCB.money(balance, currency: currency)
        amount.font = TCB.mono(18, .semibold)
        amount.textColor = TCB.ink
        amount.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right",
                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)))
        chevron.tintColor = TCB.inkFaint
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(title)
        addSubview(num)
        addSubview(amount)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TCB.cardPad),
            title.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            title.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            num.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            num.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),

            amount.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            amount.topAnchor.constraint(equalTo: num.bottomAnchor, constant: 10),
            amount.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TCB.cardPad),
            chevron.centerYAnchor.constraint(equalTo: amount.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    static func mask(_ number: String) -> String {
        guard number.count > 7 else { return number }
        return String(number.prefix(4)) + " •••• " + String(number.suffix(3))
    }
}

// MARK: - Transaction row

final class TransactionRow: UIView {

    init(_ item: TCBAction) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let bubble = UIView()
        bubble.backgroundColor = item.isCredit ? TCB.successBg : TCB.chip
        bubble.layer.cornerRadius = 20
        bubble.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(systemName: item.isCredit ? "arrow.down.left" : "arrow.up.right",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        arrow.tintColor = item.isCredit ? TCB.success : TCB.inkSoft
        arrow.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(arrow)

        let title = UILabel()
        title.text = item.title
        title.font = TCB.font(14, .medium)
        title.textColor = TCB.ink
        title.lineBreakMode = .byTruncatingTail
        title.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "\(item.subtitle) • \(TCB.timeOnly.string(from: item.date))"
        sub.font = TCB.font(11)
        sub.textColor = TCB.inkFaint
        sub.lineBreakMode = .byTruncatingTail
        sub.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = (item.isCredit ? "+" : "-") + TCB.money(item.amount)
        amount.font = TCB.mono(14, .semibold)
        amount.textColor = item.isCredit ? TCB.success : TCB.ink
        amount.textAlignment = .right
        amount.setContentHuggingPriority(.required, for: .horizontal)
        amount.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bubble)
        addSubview(title)
        addSubview(sub)
        addSubview(amount)

        NSLayoutConstraint.activate([
            bubble.widthAnchor.constraint(equalToConstant: 40),
            bubble.heightAnchor.constraint(equalToConstant: 40),
            bubble.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubble.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            arrow.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            arrow.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),

            title.leadingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: 12),
            title.topAnchor.constraint(equalTo: bubble.topAnchor, constant: -1),
            title.trailingAnchor.constraint(lessThanOrEqualTo: amount.leadingAnchor, constant: -8),

            sub.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            sub.trailingAnchor.constraint(lessThanOrEqualTo: amount.leadingAnchor, constant: -8),
            sub.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 1),

            amount.trailingAnchor.constraint(equalTo: trailingAnchor),
            amount.centerYAnchor.constraint(equalTo: centerYAnchor),

            bottomAnchor.constraint(greaterThanOrEqualTo: bubble.bottomAnchor, constant: 12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Form helpers

final class FormRow: UIView {

    init(label: String, field: UITextField) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let l = UILabel()
        l.text = label
        l.font = TCB.font(13)
        l.textColor = TCB.inkSoft
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false

        field.font = TCB.font(15)
        field.textColor = TCB.ink
        field.textAlignment = .right
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)

        addSubview(l)
        addSubview(field)

        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: leadingAnchor),
            l.centerYAnchor.constraint(equalTo: centerYAnchor),
            l.widthAnchor.constraint(greaterThanOrEqualToConstant: 96),

            field.leadingAnchor.constraint(equalTo: l.trailingAnchor, constant: 12),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            field.heightAnchor.constraint(greaterThanOrEqualToConstant: 22)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class PrimaryButton: UIButton {

    enum Style { case red, black, outline }

    init(_ title: String, style: Style = .red) {
        super.init(frame: .zero)
        var cfg = UIButton.Configuration.filled()
        cfg.cornerStyle = .capsule
        cfg.title = title
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 22, bottom: 15, trailing: 22)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = TCB.font(15, .semibold)
            return out
        }

        switch style {
        case .red:
            cfg.baseBackgroundColor = TCB.red
            cfg.baseForegroundColor = .white
        case .black:
            cfg.baseBackgroundColor = TCB.ink
            cfg.baseForegroundColor = .white
        case .outline:
            cfg.baseBackgroundColor = .clear
            cfg.baseForegroundColor = TCB.ink
            cfg.background.strokeColor = TCB.ink
            cfg.background.strokeWidth = 1
        }

        configuration = cfg
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Page dots (carousel)

final class PageDots: UIView {

    private var dots: [UIView] = []

    init(count: Int, index: Int = 0) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 5
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        for i in 0..<count {
            let dot = UIView()
            dot.backgroundColor = i == index ? TCB.ink : TCB.inkFaint.withAlphaComponent(0.35)
            dot.layer.cornerRadius = 2.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            if i == index {
                dot.widthAnchor.constraint(equalToConstant: 18).isActive = true
            } else {
                dot.widthAnchor.constraint(equalToConstant: 5).isActive = true
            }
            dot.heightAnchor.constraint(equalToConstant: 5).isActive = true
            row.addArrangedSubview(dot)
            dots.append(dot)
        }

        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: centerXAnchor),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setIndex(_ index: Int) {
        for (i, dot) in dots.enumerated() {
            UIView.animate(withDuration: 0.2) {
                dot.backgroundColor = i == index ? TCB.ink : TCB.inkFaint.withAlphaComponent(0.35)
            }
        }
    }
}

// MARK: - Sparkline (chart màn Tài sản)

final class SparklineView: UIView {

    var values: [CGFloat] = [0.42, 0.50, 0.46, 0.60, 0.54, 0.72, 0.66, 0.80, 0.74, 0.92, 0.86, 1.0] {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard values.count > 1, let ctx = UIGraphicsGetCurrentContext() else { return }

        let inset: CGFloat = 8
        let w = rect.width - inset * 2
        let h = rect.height - inset * 2
        let step = w / CGFloat(values.count - 1)

        let line = UIBezierPath()
        for (i, v) in values.enumerated() {
            let p = CGPoint(x: inset + CGFloat(i) * step, y: inset + h * (1 - v))
            if i == 0 { line.move(to: p) } else { line.addLine(to: p) }
        }

        // Vùng tô dưới đường.
        let area = line.copy() as! UIBezierPath
        area.addLine(to: CGPoint(x: inset + w, y: rect.height))
        area.addLine(to: CGPoint(x: inset, y: rect.height))
        area.close()

        ctx.saveGState()
        ctx.addPath(area.cgPath)
        ctx.clip()
        let colors = [TCB.success.withAlphaComponent(0.35).cgColor,
                      TCB.success.withAlphaComponent(0.02).cgColor] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors,
                                     locations: [0.0, 1.0]) {
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: inset),
                                   end: CGPoint(x: 0, y: rect.height),
                                   options: [])
        }
        ctx.restoreGState()

        // Đường.
        TCB.success.setStroke()
        line.lineWidth = 2
        line.lineJoinStyle = .round
        line.stroke()

        // Điểm cuối.
        if let last = values.last {
            let p = CGPoint(x: inset + w, y: inset + h * (1 - last))
            ctx.setFillColor(TCB.success.cgColor)
            ctx.fillEllipse(in: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8))
        }
    }
}

// MARK: - Nav bar styling

extension UIViewController {

    func applyTCBNavigationBar(_ title: String) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: TCB.ink,
            .font: TCB.font(17, .semibold)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.title = title
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = TCB.ink
    }

    func alert(_ title: String, _ message: String = "") {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
