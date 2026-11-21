import UIKit

// MARK: - Lock-screen style notification preview
//
// Dựng lại đúng cái card iOS vẽ ra trên màn hình khoá:
// blur nền, icon app 38pt, tên app IN HOA, giờ "now", title đậm, body 3 dòng.
//
final class NotificationPreview: UIView {

    private let blur    = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialLight))
    private let icon    = UIImageView()
    private let appName = UILabel()
    private let time    = UILabel()
    private let title   = UILabel()
    private let body    = UILabel()
    private let stack   = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        clipsToBounds = true
        backgroundColor = .clear

        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.layer.cornerRadius = 9
        icon.layer.cornerCurve = .continuous
        icon.clipsToBounds = true
        icon.backgroundColor = .white
        icon.image = UIImage(named: "Logo")

        appName.text = "TECHCOMBANK"
        appName.font = .systemFont(ofSize: 12, weight: .semibold)
        appName.textColor = UIColor(white: 0.35, alpha: 1)
        appName.setContentHuggingPriority(.defaultLow, for: .horizontal)

        time.text = "now"
        time.font = .systemFont(ofSize: 12, weight: .regular)
        time.textColor = UIColor(white: 0.55, alpha: 1)
        time.setContentHuggingPriority(.required, for: .horizontal)

        title.font = .systemFont(ofSize: 15, weight: .semibold)
        title.textColor = .black
        title.numberOfLines = 1

        body.font = .systemFont(ofSize: 15, weight: .regular)
        body.textColor = UIColor(white: 0.15, alpha: 1)
        body.numberOfLines = 3

        let head = UIStackView(arrangedSubviews: [appName, time])
        head.axis = .horizontal
        head.alignment = .center
        head.spacing = 8

        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(head)
        stack.addArrangedSubview(title)
        stack.setCustomSpacing(2, after: head)
        stack.setCustomSpacing(6, after: title)
        stack.addArrangedSubview(body)

        addSubview(icon)
        addSubview(stack)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),

            icon.widthAnchor.constraint(equalToConstant: 38),
            icon.heightAnchor.constraint(equalToConstant: 38),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            stack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    func apply(_ model: BankNotification) {
        title.text = model.title
        body.text  = model.body
    }
}
