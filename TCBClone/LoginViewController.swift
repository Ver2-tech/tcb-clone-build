import UIKit

final class LoginViewController: UIViewController {

    var onAuthenticated: (() -> Void)?

    // MARK: State

    private enum Phase { case credentials, pin }
    private var phase: Phase = .credentials
    private var entered = ""

    // MARK: Views

    private let credentialsView = UIView()
    private let pinView = UIView()

    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = PrimaryButton("Đăng nhập")

    private let dotsStack = UIStackView()
    private var dots: [UIView] = []
    private let pinTitle = UILabel()
    private let pinSubtitle = UILabel()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildCredentials()
        buildPin()
        pinView.isHidden = true
        pinView.alpha = 0
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    // MARK: Credentials

    private func buildCredentials() {
        credentialsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(credentialsView)

        let logo = LogoView(height: 56)
        let wordmark = UILabel()
        wordmark.text = "Techcombank"
        wordmark.font = TCB.font(22, .bold)
        wordmark.textColor = TCB.red
        wordmark.translatesAutoresizingMaskIntoConstraints = false

        let welcome = UILabel()
        welcome.text = "Chào mừng bạn đến với Techcombank"
        welcome.font = TCB.font(17, .semibold)
        welcome.textColor = TCB.ink
        welcome.textAlignment = .center
        welcome.numberOfLines = 2
        welcome.translatesAutoresizingMaskIntoConstraints = false

        let hint = UILabel()
        hint.text = "Đăng nhập để quản lý tài khoản của bạn"
        hint.font = TCB.font(13)
        hint.textColor = TCB.inkSoft
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false

        usernameField.placeholder = "Tên đăng nhập"
        usernameField.text = "nguyenvanan"
        usernameField.font = TCB.font(15)
        usernameField.textColor = TCB.ink
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .default
        usernameField.returnKeyType = .next
        usernameField.clearButtonMode = .whileEditing
        usernameField.delegate = self

        passwordField.placeholder = "Mật khẩu"
        passwordField.text = "••••••••"
        passwordField.font = TCB.font(15)
        passwordField.textColor = TCB.ink
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .go
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(submit), for: .editingDidEndOnExit)

        let fields = UIStackView(arrangedSubviews: [
            fieldBox(usernameField, icon: "person"),
            fieldBox(passwordField, icon: "lock")
        ])
        fields.axis = .vertical
        fields.spacing = 12
        fields.translatesAutoresizingMaskIntoConstraints = false

        loginButton.addTarget(self, action: #selector(submit), for: .touchUpInside)

        let forgot = UIButton(type: .system)
        forgot.setTitle("Quên mật khẩu?", for: .normal)
        forgot.setTitleColor(TCB.red, for: .normal)
        forgot.titleLabel?.font = TCB.font(13, .medium)
        forgot.translatesAutoresizingMaskIntoConstraints = false

        let footer = UILabel()
        footer.text = "Bản quyền © 2024 Techcombank"
        footer.font = TCB.font(11)
        footer.textColor = TCB.inkFaint
        footer.textAlignment = .center
        footer.translatesAutoresizingMaskIntoConstraints = false

        [logo, wordmark, welcome, hint, fields, loginButton, forgot, footer].forEach {
            credentialsView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: credentialsView.centerXAnchor),
            logo.topAnchor.constraint(equalTo: credentialsView.safeAreaLayoutGuide.topAnchor, constant: 54),

            wordmark.centerXAnchor.constraint(equalTo: credentialsView.centerXAnchor),
            wordmark.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 8),

            welcome.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor, constant: 32),
            welcome.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor, constant: -32),
            welcome.topAnchor.constraint(equalTo: wordmark.bottomAnchor, constant: 36),

            hint.leadingAnchor.constraint(equalTo: welcome.leadingAnchor),
            hint.trailingAnchor.constraint(equalTo: welcome.trailingAnchor),
            hint.topAnchor.constraint(equalTo: welcome.bottomAnchor, constant: 6),

            fields.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor, constant: 24),
            fields.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor, constant: -24),
            fields.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 32),

            loginButton.leadingAnchor.constraint(equalTo: fields.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: fields.trailingAnchor),
            loginButton.topAnchor.constraint(equalTo: fields.bottomAnchor, constant: 24),

            forgot.centerXAnchor.constraint(equalTo: credentialsView.centerXAnchor),
            forgot.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),

            footer.leadingAnchor.constraint(equalTo: credentialsView.leadingAnchor, constant: 24),
            footer.trailingAnchor.constraint(equalTo: credentialsView.trailingAnchor, constant: -24),
            footer.bottomAnchor.constraint(equalTo: credentialsView.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            credentialsView.topAnchor.constraint(equalTo: view.topAnchor),
            credentialsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            credentialsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            credentialsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fieldBox(_ field: UITextField, icon: String) -> UIView {
        let box = UIView()
        box.backgroundColor = TCB.canvas
        box.layer.cornerRadius = 12
        box.translatesAutoresizingMaskIntoConstraints = false

        let glyph = UIImageView(image: UIImage(systemName: icon,
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)))
        glyph.tintColor = TCB.inkFaint
        glyph.translatesAutoresizingMaskIntoConstraints = false
        glyph.setContentHuggingPriority(.required, for: .horizontal)

        field.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(glyph)
        box.addSubview(field)

        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: 52),
            glyph.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            glyph.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            field.leadingAnchor.constraint(equalTo: glyph.trailingAnchor, constant: 10),
            field.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            field.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
        return box
    }

    // MARK: PIN

    private func buildPin() {
        pinView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinView)

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left",
                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)),
                      for: .normal)
        back.tintColor = TCB.ink
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addTarget(self, action: #selector(backToCredentials), for: .touchUpInside)

        let logo = LogoView(height: 40)

        pinTitle.text = "Nhập mã PIN"
        pinTitle.font = TCB.font(19, .semibold)
        pinTitle.textColor = TCB.ink
        pinTitle.textAlignment = .center
        pinTitle.translatesAutoresizingMaskIntoConstraints = false

        pinSubtitle.text = "Mã PIN gồm 6 chữ số"
        pinSubtitle.font = TCB.font(13)
        pinSubtitle.textColor = TCB.inkSoft
        pinSubtitle.textAlignment = .center
        pinSubtitle.translatesAutoresizingMaskIntoConstraints = false

        dotsStack.axis = .horizontal
        dotsStack.spacing = 14
        dotsStack.alignment = .center
        dotsStack.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<6 {
            let dot = UIView()
            dot.layer.cornerRadius = 7
            dot.layer.borderWidth = 1.5
            dot.layer.borderColor = TCB.red.cgColor
            dot.backgroundColor = .clear
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 14).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 14).isActive = true
            dots.append(dot)
            dotsStack.addArrangedSubview(dot)
        }

        let keypad = makeKeypad()

        [back, logo, pinTitle, pinSubtitle, dotsStack, keypad].forEach { pinView.addSubview($0) }

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: pinView.leadingAnchor, constant: 16),
            back.topAnchor.constraint(equalTo: pinView.safeAreaLayoutGuide.topAnchor, constant: 8),
            back.widthAnchor.constraint(equalToConstant: 32),
            back.heightAnchor.constraint(equalToConstant: 32),

            logo.centerXAnchor.constraint(equalTo: pinView.centerXAnchor),
            logo.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 26),

            pinTitle.leadingAnchor.constraint(equalTo: pinView.leadingAnchor, constant: 24),
            pinTitle.trailingAnchor.constraint(equalTo: pinView.trailingAnchor, constant: -24),
            pinTitle.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 26),

            pinSubtitle.leadingAnchor.constraint(equalTo: pinTitle.leadingAnchor),
            pinSubtitle.trailingAnchor.constraint(equalTo: pinTitle.trailingAnchor),
            pinSubtitle.topAnchor.constraint(equalTo: pinTitle.bottomAnchor, constant: 6),

            dotsStack.centerXAnchor.constraint(equalTo: pinView.centerXAnchor),
            dotsStack.topAnchor.constraint(equalTo: pinSubtitle.bottomAnchor, constant: 26),

            keypad.centerXAnchor.constraint(equalTo: pinView.centerXAnchor),
            keypad.topAnchor.constraint(equalTo: dotsStack.bottomAnchor, constant: 34),
            keypad.bottomAnchor.constraint(lessThanOrEqualTo: pinView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            pinView.topAnchor.constraint(equalTo: view.topAnchor),
            pinView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pinView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pinView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeKeypad() -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12
        grid.translatesAutoresizingMaskIntoConstraints = false

        let layout: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "⌫"]
        ]

        for row in layout {
            let line = UIStackView()
            line.axis = .horizontal
            line.spacing = 18
            line.distribution = .fillEqually
            line.translatesAutoresizingMaskIntoConstraints = false

            for key in row {
                if key.isEmpty {
                    let spacer = UIView()
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                    spacer.widthAnchor.constraint(equalToConstant: 72).isActive = true
                    spacer.heightAnchor.constraint(equalToConstant: 72).isActive = true
                    line.addArrangedSubview(spacer)
                } else {
                    line.addArrangedSubview(pinKey(key))
                }
            }
            grid.addArrangedSubview(line)
        }
        return grid
    }

    private func pinKey(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(TCB.ink, for: .normal)
        button.titleLabel?.font = TCB.font(title == "⌫" ? 19 : 24, .regular)
        button.backgroundColor = TCB.canvas
        button.layer.cornerRadius = 36
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 72).isActive = true
        button.heightAnchor.constraint(equalToConstant: 72).isActive = true
        button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)

        button.addAction(UIAction { [weak self, weak button] _ in
            UIView.animate(withDuration: 0.08, animations: {
                button?.backgroundColor = TCB.separator
            }, completion: { _ in
                UIView.animate(withDuration: 0.12) {
                    button?.backgroundColor = TCB.canvas
                }
            })
            _ = self
        }, for: .touchDown)

        return button
    }

    // MARK: Actions

    @objc private func submit() {
        guard phase == .credentials else { return }
        view.endEditing(true)

        let user = usernameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !user.isEmpty else {
            alert("Thông báo", "Vui lòng nhập tên đăng nhập.")
            return
        }

        phase = .pin
        entered = ""
        refreshDots()
        pinView.isHidden = false
        UIView.animate(withDuration: 0.28) {
            self.credentialsView.alpha = 0
            self.pinView.alpha = 1
        } completion: { _ in
            self.credentialsView.isHidden = true
        }
    }

    @objc private func backToCredentials() {
        phase = .credentials
        entered = ""
        refreshDots()
        credentialsView.isHidden = false
        UIView.animate(withDuration: 0.24) {
            self.pinView.alpha = 0
            self.credentialsView.alpha = 1
        } completion: { _ in
            self.pinView.isHidden = true
        }
    }

    @objc private func keyTapped(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }

        if key == "⌫" {
            if !entered.isEmpty { entered.removeLast() }
            refreshDots()
            return
        }

        guard entered.count < 6 else { return }
        entered += key
        refreshDots()

        if entered.count == 6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
                self?.finishLogin()
            }
        }
    }

    private func finishLogin() {
        guard BankState.shared.verifyPIN(entered) else {
            alert("Mã PIN không đúng", "Mã PIN mặc định là 123456. Có thể đổi trong Cài đặt → Bảo mật.")
            entered = ""
            refreshDots()
            return
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.18) {
            self.dotsStack.alpha = 0.4
        } completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.dotsStack.alpha = 1
            }
        }
        onAuthenticated?()
    }

    private func refreshDots() {
        for (index, dot) in dots.enumerated() {
            dot.backgroundColor = index < entered.count ? TCB.red : .clear
        }
    }
}

// MARK: - Text field delegate

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            submit()
        }
        return true
    }
}
