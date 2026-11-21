import UIKit

final class TransferViewController: UIViewController, QRScannerDelegate {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    private let sourceValue = UILabel()
    private let beneficiaryField = UITextField()
    private let bankField = UITextField()
    private let amountField = UITextField()
    private let noteField = UITextField()

    private let continueButton = PrimaryButton("Tiếp tục")
    private let scanButton = UIButton(type: .system)

    private var presetName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Chuyển tiền")
        build()
        renderBalance()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(renderBalance),
                                               name: .tcbStateChanged,
                                               object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        renderBalance()
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

        sourceValue.font = TCB.mono(13, .medium)
        sourceValue.textColor = TCB.ink
        sourceValue.textAlignment = .right
        sourceValue.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        beneficiaryField.placeholder = "Số tài khoản / Số thẻ"
        bankField.placeholder = "Ngân hàng thụ hưởng"
        amountField.placeholder = "0"
        noteField.placeholder = "Nội dung chuyển tiền"

        for field in [beneficiaryField, bankField, amountField, noteField] {
            field.borderStyle = .none
            field.font = TCB.font(15)
            field.textColor = TCB.ink
            field.textAlignment = .right
        }
        amountField.keyboardType = .numberPad
        beneficiaryField.keyboardType = .numberPad

        content.addArrangedSubview(SectionHeader("Thông tin chuyển tiền"))
        content.addArrangedSubview(CardBox(rows: [
            valueRow("Từ tài khoản", sourceValue),
            Hairline(),
            FormRow(label: "Đến tài khoản", field: beneficiaryField),
            Hairline(),
            FormRow(label: "Ngân hàng", field: bankField),
            Hairline(),
            FormRow(label: "Số tiền", field: amountField),
            Hairline(),
            FormRow(label: "Nội dung", field: noteField)
        ], padding: 0))

        scanButton.setTitle("Quét mã QR để điền thông tin", for: .normal)
        scanButton.setTitleColor(TCB.red, for: .normal)
        scanButton.titleLabel?.font = TCB.font(14, .semibold)
        scanButton.backgroundColor = TCB.redTint
        scanButton.layer.cornerRadius = 12
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        scanButton.addTarget(self, action: #selector(openScanner), for: .touchUpInside)
        content.addArrangedSubview(scanButton)

        if !BankState.shared.beneficiaries.isEmpty {
            content.addArrangedSubview(SectionHeader("Người thụ hưởng gần đây"))
            for person in BankState.shared.beneficiaries.prefix(3) {
                let row = MenuRow(icon: "person.circle", title: person.name, detail: person.account)
                row.tag = BankState.shared.beneficiaries.firstIndex(where: { $0.id == person.id }) ?? 0
                row.addTarget(self, action: #selector(pickBeneficiary(_:)), for: .touchUpInside)
                content.addArrangedSubview(CardBox(rows: [row], padding: 0))
            }
        }

        content.addArrangedSubview(SectionHeader("Phí giao dịch"))
        let fee = UILabel()
        fee.text = "Miễn phí"
        fee.font = TCB.mono(14, .medium)
        fee.textColor = TCB.credit
        fee.textAlignment = .right
        content.addArrangedSubview(CardBox(rows: [valueRow("Phí chuyển khoản", fee)], padding: 0))

        let bar = UIView()
        bar.backgroundColor = TCB.canvas
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(continueButton)
        view.addSubview(bar)

        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: TCB.gutter),
            continueButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -TCB.gutter),
            continueButton.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    // MARK: Data

    @objc private func renderBalance() {
        guard let source = BankState.shared.checking else { return }
        sourceValue.text = "\(source.number) • \(TCB.money(source.balance))"
    }

    func prefill(name: String = "", account: String = "", bank: String = "", amount: Int64 = 0, note: String = "") {
        presetName = name
        beneficiaryField.text = account.isEmpty ? nil : account
        bankField.text = bank.isEmpty ? nil : bank
        amountField.text = amount > 0 ? String(amount) : nil
        noteField.text = note.isEmpty ? nil : note
    }

    // MARK: Actions

    @objc private func openScanner() {
        let scanner = QRScannerViewController()
        scanner.delegate = self
        navigationController?.pushViewController(scanner, animated: true)
    }

    func qrScanner(_ scanner: QRScannerViewController, didRead info: QRPayInfo) {
        prefill(name: info.name,
                account: info.account,
                bank: info.bank,
                amount: info.amount,
                note: info.note)
        navigationController?.popViewController(animated: true)
        alert("Đã đọc mã QR", "Thông tin đã được điền vào form. Kiểm tra lại trước khi xác nhận.")
    }

    @objc private func pickBeneficiary(_ sender: MenuRow) {
        guard let person = BankState.shared.beneficiaries[safe: sender.tag] else { return }
        prefill(name: person.name, account: person.account, bank: person.bank)
    }

    @objc private func continueTapped() {
        view.endEditing(true)

        let account = beneficiaryField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let amount = Int64((amountField.text ?? "").filter { $0.isNumber }) ?? 0
        let name = presetName.isEmpty ? "người thụ hưởng" : presetName
        let bank = bankField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let note = noteField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard account.filter({ $0.isNumber }).count >= 8 else {
            alert("Thông báo", "Vui lòng nhập đúng số tài khoản thụ hưởng.")
            return
        }
        guard amount >= 10_000 else {
            alert("Thông báo", "Số tiền tối thiểu là 10.000 VND.")
            return
        }
        guard (BankState.shared.checking?.balance ?? 0) >= amount else {
            alert("Thông báo", "Số dư tài khoản không đủ để thực hiện giao dịch.")
            return
        }

        let confirm = UIAlertController(
            title: "Xác nhận chuyển tiền",
            message: "Chuyển \(TCB.money(amount)) đến \(name)\nTài khoản \(account)\n\(bank)\nNội dung: \(note)",
            preferredStyle: .alert
        )
        confirm.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Xác nhận", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let result = BankState.shared.transfer(to: name,
                                                   account: account,
                                                   bank: bank,
                                                   amount: amount,
                                                   note: note)
            switch result {
            case .success:
                let receipt = ReceiptViewController(titleText: "Chuyển tiền thành công",
                                                    amount: amount,
                                                    detail: "\(name) • \(note)",
                                                    balance: BankState.shared.checking?.balance ?? 0)
                self.navigationController?.pushViewController(receipt, animated: true)
            case .failure(let error):
                self.alert("Không thể chuyển tiền", error.localizedDescription)
            }
        })
        present(confirm, animated: true)
    }

    // MARK: Helpers

    private func valueRow(_ label: String, _ value: UIView) -> UIView {
        let l = UILabel()
        l.text = label
        l.font = TCB.font(13)
        l.textColor = TCB.inkSoft
        l.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [l, value])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 13, left: TCB.cardPad, bottom: 13, right: TCB.cardPad)
        return row
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
