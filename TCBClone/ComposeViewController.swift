import UIKit

final class ComposeViewController: UIViewController {

    private var model = BankNotification()

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private let preview = NotificationPreview()
    private let fireButton = PrimaryButton("Bắn thông báo")

    private let accountField = UITextField()
    private let amountField = UITextField()
    private let balanceField = UITextField()
    private let contentField = UITextField()

    private let directionSeg = UISegmentedControl(items: ["Tiền vào", "Tiền ra"])
    private let presetSeg = UISegmentedControl(items: TemplatePreset.allCases.map { $0.label })
    private let maskSeg = UISegmentedControl(items: ["Đầy đủ", "•••• 4567", "1903****"])

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Thông báo giao dịch")
        build()
        syncModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: Build

    private func build() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .interactive
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
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -110)
        ])

        configureFields()
        configureSegments()

        content.addArrangedSubview(fieldCard())
        content.addArrangedSubview(optionCard())

        let caption = SectionHeader("Xem trước")
        content.addArrangedSubview(caption)

        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
        content.addArrangedSubview(preview)

        let note = UILabel()
        note.text = "Thông báo sẽ xuất hiện sau 1 giây, hiển thị như thông báo thật của ứng dụng."
        note.font = TCB.font(11)
        note.textColor = TCB.inkFaint
        note.numberOfLines = 0
        content.addArrangedSubview(note)

        buildBottomBar()
    }

    private func configureFields() {
        accountField.text = model.account
        amountField.text = TCB.grouped(model.amount)
        balanceField.text = TCB.grouped(model.balance)
        contentField.text = model.content

        for field in [accountField, amountField, balanceField, contentField] {
            field.borderStyle = .none
            field.addTarget(self, action: #selector(syncModel), for: .editingChanged)
        }
        accountField.keyboardType = .numberPad
        amountField.keyboardType = .numberPad
        balanceField.keyboardType = .numberPad
        contentField.keyboardType = .default
        contentField.returnKeyType = .done
    }

    private func configureSegments() {
        for seg in [directionSeg, presetSeg, maskSeg] {
            seg.selectedSegmentTintColor = TCB.red
            seg.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                        .font: TCB.font(12, .semibold)], for: .selected)
            seg.setTitleTextAttributes([.foregroundColor: TCB.inkSoft,
                                        .font: TCB.font(12)], for: .normal)
            seg.addTarget(self, action: #selector(syncModel), for: .valueChanged)
            seg.translatesAutoresizingMaskIntoConstraints = false
            seg.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }
        directionSeg.selectedSegmentIndex = 0
        presetSeg.selectedSegmentIndex = 0
        maskSeg.selectedSegmentIndex = 0
    }

    private func fieldCard() -> UIView {
        CardBox(rows: [
            FormRow(label: "Số tài khoản", field: accountField),
            Hairline(),
            FormRow(label: "Số tiền", field: amountField),
            Hairline(),
            FormRow(label: "Số dư", field: balanceField),
            Hairline(),
            FormRow(label: "Nội dung", field: contentField)
        ], padding: 0)
    }

    private func optionCard() -> UIView {
        let stack = UIStackView(arrangedSubviews: [
            labelled("Loại giao dịch", directionSeg),
            labelled("Mẫu thông báo", presetSeg),
            labelled("Hiển thị số TK", maskSeg)
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 14, left: TCB.cardPad, bottom: 14, right: TCB.cardPad)
        return CardBox(rows: [stack], padding: 0)
    }

    private func labelled(_ text: String, _ control: UIView) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = TCB.font(12)
        label.textColor = TCB.inkSoft

        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 7
        return stack
    }

    private func buildBottomBar() {
        let bar = UIView()
        bar.backgroundColor = TCB.canvas
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(fireButton)
        view.addSubview(bar)

        fireButton.addTarget(self, action: #selector(fireTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            fireButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: TCB.gutter),
            fireButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -TCB.gutter),
            fireButton.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            fireButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    // MARK: Model

    @objc private func syncModel() {
        model.account = accountField.text ?? ""
        model.amount = digits(amountField.text)
        model.balance = digits(balanceField.text)
        model.content = contentField.text ?? ""
        model.direction = directionSeg.selectedSegmentIndex == 0 ? .credit : .debit
        model.preset = TemplatePreset.allCases[max(0, min(presetSeg.selectedSegmentIndex,
                                                          TemplatePreset.allCases.count - 1))]
        switch maskSeg.selectedSegmentIndex {
        case 1: model.mask = .bullet
        case 2: model.mask = .keepFirst4
        default: model.mask = .full
        }

        var shown = model
        shown.date = Date()
        preview.apply(shown)
    }

    private func digits(_ text: String?) -> Int64 {
        let clean = (text ?? "").filter { $0.isNumber }
        return Int64(clean) ?? 0
    }

    // MARK: Fire

    @objc private func fireTapped() {
        view.endEditing(true)
        syncModel()

        guard !model.account.isEmpty else {
            alert("Thông báo", "Vui lòng nhập số tài khoản.")
            return
        }

        var shown = model
        shown.date = Date()

        fireButton.isEnabled = false
        NotificationEngine.shared.fire(shown, after: 1.0) { [weak self] error in
            guard let self = self else { return }
            self.fireButton.isEnabled = true
            if let error = error {
                self.alert("Không thể gửi", error.localizedDescription)
            }
        }
    }
}
