import UIKit

final class SettingsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Cài đặt")
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

        content.addArrangedSubview(profileCard())

        content.addArrangedSubview(SectionHeader("Tài khoản & bảo mật"))
        let security = MenuRow(icon: "bell.badge", title: "Thông báo giao dịch")
        security.addTarget(self, action: #selector(openCompose), for: .touchUpInside)
        let privacy = MenuRow(icon: "lock.shield", title: "Bảo mật & đăng nhập")
        privacy.addTarget(self, action: #selector(openSecurity), for: .touchUpInside)

        let limit = MenuRow(icon: "gauge", title: "Quản lý hạn mức", detail: "50 Tr/ngày")
        limit.addTarget(self, action: #selector(manageLimit), for: .touchUpInside)

        content.addArrangedSubview(CardBox(rows: [
            security,
            Hairline(),
            privacy,
            Hairline(),
            limit
        ], padding: 0))

        let language = MenuRow(icon: "globe", title: "Ngôn ngữ", detail: "Tiếng Việt")
        language.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)

        let support = MenuRow(icon: "questionmark.circle", title: "Trung tâm hỗ trợ")
        support.addTarget(self, action: #selector(openSupport), for: .touchUpInside)

        let about = MenuRow(icon: "info.circle", title: "Về ứng dụng", detail: "6.3.6")
        about.addTarget(self, action: #selector(openAbout), for: .touchUpInside)

        content.addArrangedSubview(SectionHeader("Tiện ích"))
        content.addArrangedSubview(CardBox(rows: [
            language,
            Hairline(),
            support,
            Hairline(),
            about
        ], padding: 0))

        let logout = UIButton(type: .system)
        logout.setTitle("Đăng xuất", for: .normal)
        logout.setTitleColor(TCB.red, for: .normal)
        logout.titleLabel?.font = TCB.font(15, .semibold)
        logout.backgroundColor = TCB.card
        logout.layer.cornerRadius = TCB.radius
        logout.layer.cornerCurve = .continuous
        logout.translatesAutoresizingMaskIntoConstraints = false
        logout.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logout.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        content.addArrangedSubview(logout)
    }

    private func profileCard() -> UIView {
        let avatar = UILabel()
        avatar.text = "NA"
        avatar.font = TCB.font(18, .bold)
        avatar.textColor = .white
        avatar.textAlignment = .center
        avatar.backgroundColor = TCB.red
        avatar.layer.cornerRadius = 26
        avatar.clipsToBounds = true
        avatar.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel()
        name.text = TCBUser.fullName
        name.font = TCB.font(16, .semibold)
        name.textColor = TCB.ink
        name.translatesAutoresizingMaskIntoConstraints = false

        let cid = UILabel()
        cid.text = "Mã khách hàng: " + TCBUser.customerID
        cid.font = TCB.font(12)
        cid.textColor = TCB.inkSoft
        cid.translatesAutoresizingMaskIntoConstraints = false

        let text = UIStackView(arrangedSubviews: [name, cid])
        text.axis = .vertical
        text.spacing = 3
        text.translatesAutoresizingMaskIntoConstraints = false

        let box = UIView()
        box.backgroundColor = TCB.card
        box.layer.cornerRadius = TCB.radius
        box.layer.cornerCurve = .continuous
        box.translatesAutoresizingMaskIntoConstraints = false

        box.addSubview(avatar)
        box.addSubview(text)

        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: 84),

            avatar.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: TCB.cardPad),
            avatar.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 52),
            avatar.heightAnchor.constraint(equalToConstant: 52),

            text.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            text.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -TCB.cardPad),
            text.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])

        return box
    }

    @objc private func openCompose() {
        navigationController?.pushViewController(ComposeViewController(), animated: true)
    }

    @objc private func openSecurity() {
        let vc = MoreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func manageLimit() {
        let alert = UIAlertController(title: "Quản lý hạn mức",
                                      message: "Hạn mức chuyển tiền mỗi ngày",
                                      preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "50000000"
            field.text = "50000000"
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { _ in
            let value = Int64((alert.textFields?.first?.text ?? "").filter { $0.isNumber }) ?? 0
            guard value >= 1_000_000 else {
                self.alert("Hạn mức không hợp lệ", "Hạn mức tối thiểu là 1.000.000 VND.")
                return
            }
            UserDefaults.standard.set(Int(value), forKey: "tcb.limit.daily")
            self.alert("Đã lưu", "Hạn mức mới: \(TCB.money(value))/ngày.")
        })
        present(alert, animated: true)
    }

    @objc private func changeLanguage() {
        let sheet = UIAlertController(title: "Ngôn ngữ",
                                      message: "Chọn ngôn ngữ hiển thị",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Tiếng Việt", style: .default) { _ in
            self.alert("Đã chọn", "Ngôn ngữ: Tiếng Việt")
        })
        sheet.addAction(UIAlertAction(title: "English", style: .default) { _ in
            self.alert("Chưa hỗ trợ", "Bản mô phỏng này hiện chỉ có tiếng Việt.")
        })
        sheet.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func openSupport() {
        let sheet = UIAlertController(title: "Trung tâm hỗ trợ",
                                      message: "Hotline: 1900 65 65\nEmail: support@techcombank.com.vn\nỨng dụng mô phỏng — không kết nối ngân hàng thật.",
                                      preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Gọi hotline", style: .default) { _ in
            guard let url = URL(string: "tel://19006565"), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
        sheet.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func openAbout() {
        alert("Techcombank Mobile", "Phiên bản mô phỏng 6.3.6\nDựng theo giao diện App Store.\nKhông phải ứng dụng chính thức.")
    }

    @objc private func logoutTapped() {
        let sheet = UIAlertController(title: "Đăng xuất",
                                      message: "Bạn có chắc muốn đăng xuất khỏi ứng dụng?",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive) { _ in
            Session.isLoggedIn = false
            if let delegate = UIApplication.shared.connectedScenes
                .compactMap({ $0.delegate as? SceneDelegate })
                .first {
                delegate.showLoginAnimated()
            }
        })
        sheet.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(sheet, animated: true)
    }
}

// MARK: - Menu row

final class MenuRow: UIControl {

    private let glyph = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView()

    init(icon: String, title: String, detail: String? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glyph.image = UIImage(systemName: icon,
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        glyph.tintColor = TCB.red
        glyph.contentMode = .scaleAspectFit
        glyph.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = TCB.font(14)
        titleLabel.textColor = TCB.ink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.text = detail
        detailLabel.font = TCB.font(12)
        detailLabel.textColor = TCB.inkFaint
        detailLabel.textAlignment = .right
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        chevron.image = UIImage(systemName: "chevron.right",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        chevron.tintColor = TCB.inkFaint
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(glyph)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),

            glyph.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TCB.cardPad),
            glyph.centerYAnchor.constraint(equalTo: centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: glyph.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            detailLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            detailLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TCB.cardPad),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? TCB.canvas : .clear
        }
    }
}
