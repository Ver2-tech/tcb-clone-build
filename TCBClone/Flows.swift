import UIKit

// MARK: - Shared small helpers (file-private)

private func flowTitle(_ text: String) -> UILabel {
    let l = UILabel()
    l.text = text
    l.font = TCB.font(17, .bold)
    l.textColor = TCB.ink
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
}

private func flowLabel(_ text: String, size: CGFloat = 14, color: UIColor = TCB.ink) -> UILabel {
    let l = UILabel()
    l.text = text
    l.font = TCB.font(size)
    l.textColor = color
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
}

private func flowField(_ placeholder: String, numeric: Bool = false) -> UITextField {
    let f = UITextField()
    f.placeholder = placeholder
    f.borderStyle = .roundedRect
    f.font = TCB.font(15)
    f.textColor = TCB.ink
    f.backgroundColor = TCB.chip
    f.translatesAutoresizingMaskIntoConstraints = false
    if numeric { f.keyboardType = .numberPad }
    return f
}

private func flowStack(_ views: [UIView]) -> UIStackView {
    let s = UIStackView(arrangedSubviews: views)
    s.axis = .vertical
    s.spacing = 12
    s.translatesAutoresizingMaskIntoConstraints = false
    return s
}

// MARK: - Savings

final class SavingsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Gửi tiết kiệm")
        build()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .tcbStateChanged, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

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

        let add = PrimaryButton("Gửi tiết kiệm mới")
        add.addTarget(self, action: #selector(openForm), for: .touchUpInside)
        content.addArrangedSubview(add)
        content.addArrangedSubview(flowTitle("Sổ tiết kiệm của bạn"))
        render()
    }

    @objc private func refresh() { render() }

    private func render() {
        Array(content.arrangedSubviews)
            .filter { $0.accessibilityIdentifier == "saving-row" }
            .forEach {
                content.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

        for saving in BankState.shared.savings {
            let card = UIView()
            card.accessibilityIdentifier = "saving-row"
            card.backgroundColor = .white
            card.layer.cornerRadius = 16
            card.layer.cornerCurve = .continuous
            card.tcbShadow(12, opacity: 0.04, dy: 4)
            card.translatesAutoresizingMaskIntoConstraints = false

            let name = flowLabel(saving.name, size: 15)
            let principal = flowLabel(TCB.money(saving.principal), size: 19, color: TCB.ink)
            principal.font = TCB.mono(19, .semibold)

            let detail = flowLabel("\(String(format: "%.1f", saving.rate))%/năm • \(saving.termMonths) tháng • dự kiến \(TCB.money(saving.maturity))",
                                   size: 11, color: TCB.inkSoft)
            detail.numberOfLines = 2

            let stack = flowStack([name, principal, detail])
            card.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            ])
            content.addArrangedSubview(card)
        }
    }

    @objc private func openForm() {
        let vc = SavingsFormViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class SavingsFormViewController: UIViewController {

    private let nameField = flowField("Tên sổ tiết kiệm")
    private let amountField = flowField("Số tiền gửi (tối thiểu 100.000)", numeric: true)
    private let termField = flowField("Kỳ hạn (tháng)", numeric: true)
    private let rateField = flowField("Lãi suất %/năm", numeric: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Gửi tiết kiệm mới")
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func build() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let name = flowLabel("Tên sổ")
        let amount = flowLabel("Số tiền")
        let term = flowLabel("Kỳ hạn")
        let rate = flowLabel("Lãi suất")
        let note = flowLabel("Tiền sẽ được trừ từ tài khoản thanh toán.", size: 12, color: TCB.inkSoft)
        note.numberOfLines = 0

        let submit = PrimaryButton("Xác nhận gửi")
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        let stack = flowStack([name, nameField, amount, amountField, term, termField, rate, rateField, note, submit])
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: TCB.gutter),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -TCB.gutter),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        nameField.text = "Tiết kiệm 6 tháng"
        termField.text = "6"
        rateField.text = "6.2"
    }

    @objc private func submitTapped() {
        view.endEditing(true)
        let amount = Int64((amountField.text ?? "").filter { $0.isNumber }) ?? 0
        let term = Int((termField.text ?? "").filter { $0.isNumber }) ?? 0
        let rate = Double((rateField.text ?? "").replacingOccurrences(of: ",", with: ".")) ?? 6.2

        let result = BankState.shared.openSavings(name: nameField.text?.isEmpty == true ? "Tiết kiệm" : nameField.text!,
                                                  amount: amount,
                                                  rate: rate,
                                                  termMonths: max(1, term))
        switch result {
        case .success:
            let receipt = ReceiptViewController(titleText: "Gửi tiết kiệm thành công",
                                                amount: amount,
                                                detail: "\(nameField.text ?? "Tiết kiệm") • \(term) tháng • \(String(format: "%.1f", rate))%/năm",
                                                balance: BankState.shared.checking?.balance ?? 0)
            navigationController?.pushViewController(receipt, animated: true)
        case .failure(let error):
            alert("Không thể gửi", error.localizedDescription)
        }
    }
}

// MARK: - Bills

final class BillsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    private let billers: [(String, String)] = [
        ("Tiền điện EVN", "bolt.fill"),
        ("Tiền nước", "drop.fill"),
        ("Internet / Wifi", "wifi"),
        ("Thuê bao điện thoại", "phone.fill"),
        ("Học phí", "book.fill"),
        ("Phí quản lý", "building.2.fill")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Thanh toán hóa đơn")
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

        content.addArrangedSubview(flowTitle("Chọn dịch vụ"))
        for biller in billers {
            let row = MenuRow(icon: biller.1, title: biller.0)
            row.tag = billers.firstIndex(where: { $0.0 == biller.0 }) ?? 0
            row.addTarget(self, action: #selector(billerTapped(_:)), for: .touchUpInside)
            content.addArrangedSubview(CardBox(rows: [row], padding: 0))
        }
    }

    @objc private func billerTapped(_ sender: MenuRow) {
        let biller = billers[sender.tag].0
        let alert = UIAlertController(title: biller, message: "Nhập số tiền cần thanh toán", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "500000"; $0.keyboardType = .numberPad }
        alert.addTextField { $0.placeholder = "Nội dung (không bắt buộc)" }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Thanh toán", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let amount = Int64((alert.textFields?[0].text ?? "").filter { $0.isNumber }) ?? 0
            let note = alert.textFields?[1].text ?? ""
            let result = BankState.shared.payBill(provider: biller, amount: amount, note: note)
            switch result {
            case .success:
                let receipt = ReceiptViewController(titleText: "Thanh toán thành công",
                                                    amount: amount,
                                                    detail: biller,
                                                    balance: BankState.shared.checking?.balance ?? 0)
                self.navigationController?.pushViewController(receipt, animated: true)
            case .failure(let error):
                self.alert("Không thể thanh toán", error.localizedDescription)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - Auto earn

final class AutoEarnViewController: UIViewController {

    private let toggle = UISwitch()
    private let thresholdField = flowField("Ngưỡng giữ lại (VND)", numeric: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Sinh lời tự động")
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func build() {
        let intro = flowLabel("Tự động chuyển phần số dư vượt ngưỡng vào sổ tiết kiệm sinh lời 5.5%/năm. Có thể rút bất cứ lúc nào.",
                              size: 13, color: TCB.inkSoft)
        intro.numberOfLines = 0

        let toggleRow = UIView()
        toggleRow.backgroundColor = .white
        toggleRow.layer.cornerRadius = 16
        toggleRow.translatesAutoresizingMaskIntoConstraints = false
        let toggleTitle = flowLabel("Bật sinh lời tự động")
        toggle.isOn = BankState.shared.autoEarnEnabled
        toggleRow.addSubview(toggleTitle)
        toggleRow.addSubview(toggle)

        let thresholdTitle = flowLabel("Số dư giữ lại trong tài khoản thanh toán")
        thresholdField.text = String(BankState.shared.autoEarnThreshold)

        let save = PrimaryButton("Lưu cài đặt")
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = flowStack([intro, toggleRow, thresholdTitle, thresholdField, save])
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            toggleRow.heightAnchor.constraint(equalToConstant: 56),
            toggleTitle.leadingAnchor.constraint(equalTo: toggleRow.leadingAnchor, constant: 16),
            toggleTitle.centerYAnchor.constraint(equalTo: toggleRow.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: toggleRow.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: toggleRow.centerYAnchor),

            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TCB.gutter),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TCB.gutter)
        ])
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        let threshold = Int64((thresholdField.text ?? "").filter { $0.isNumber }) ?? 0
        BankState.shared.setAutoEarn(toggle.isOn, threshold: threshold)
        alert("Đã lưu", toggle.isOn
              ? "Sinh lời tự động đã bật. Ngưỡng giữ lại \(TCB.money(threshold))."
              : "Sinh lời tự động đã tắt.")
    }
}

// MARK: - Receipt

final class ReceiptViewController: UIViewController {

    private let titleText: String
    private let amount: Int64
    private let detail: String
    private let balance: Int64

    init(titleText: String, amount: Int64, detail: String, balance: Int64) {
        self.titleText = titleText
        self.amount = amount
        self.detail = detail
        self.balance = balance
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Kết quả giao dịch")
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func build() {
        let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 54, weight: .light)))
        check.tintColor = TCB.success
        check.translatesAutoresizingMaskIntoConstraints = false

        let heading = flowLabel(titleText, size: 17, color: TCB.ink)
        heading.textAlignment = .center

        let value = flowLabel("-" + TCB.money(amount), size: 26, color: TCB.ink)
        value.font = TCB.mono(26, .bold)
        value.textAlignment = .center

        let info = CardBox(rows: [
            FormRow(label: "Nội dung", field: {
                let f = UITextField(); f.text = detail; f.isEnabled = false; return f
            }()),
            Hairline(),
            FormRow(label: "Thời gian", field: {
                let f = UITextField(); f.text = TCB.dateTime.string(from: Date()); f.isEnabled = false; return f
            }()),
            Hairline(),
            FormRow(label: "Số dư còn lại", field: {
                let f = UITextField(); f.text = TCB.money(balance); f.isEnabled = false; return f
            }())
        ], padding: 4)

        let done = PrimaryButton("Hoàn tất")
        done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        let stack = flowStack([check, heading, value, info, done])
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            check.heightAnchor.constraint(equalToConstant: 60),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TCB.gutter),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TCB.gutter)
        ])
    }

    @objc private func doneTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - More (beneficiaries, PIN, history, reset)

final class MoreViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Tính năng khác")
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

        let history = MenuRow(icon: "clock.arrow.circlepath", title: "Lịch sử giao dịch")
        history.addTarget(self, action: #selector(openHistory), for: .touchUpInside)

        let people = MenuRow(icon: "person.2", title: "Người thụ hưởng")
        people.addTarget(self, action: #selector(openBeneficiaries), for: .touchUpInside)

        let pin = MenuRow(icon: "lock.rotation", title: "Đổi mã PIN")
        pin.addTarget(self, action: #selector(changePIN), for: .touchUpInside)

        let reset = MenuRow(icon: "arrow.counterclockwise", title: "Khôi phục dữ liệu mẫu")
        reset.addTarget(self, action: #selector(resetDemo), for: .touchUpInside)

        content.addArrangedSubview(CardBox(rows: [history, Hairline(), people, Hairline(), pin], padding: 0))
        content.addArrangedSubview(CardBox(rows: [reset], padding: 0))

        let note = flowLabel("Mọi giao dịch được lưu trên thiết bị. Không có kết nối tới hệ thống ngân hàng thật.",
                             size: 12, color: TCB.inkFaint)
        note.numberOfLines = 0
        content.addArrangedSubview(note)
    }

    @objc private func openHistory() {
        navigationController?.pushViewController(HistoryViewController(), animated: true)
    }

    @objc private func openBeneficiaries() {
        navigationController?.pushViewController(BeneficiariesViewController(), animated: true)
    }

    @objc private func changePIN() {
        let alert = UIAlertController(title: "Đổi mã PIN", message: "Nhập mã PIN mới (6 chữ số)", preferredStyle: .alert)
        alert.addTextField { $0.keyboardType = .numberPad; $0.isSecureTextEntry = true }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { _ in
            let pin = alert.textFields?.first?.text ?? ""
            guard pin.count == 6, pin.allSatisfy({ $0.isNumber }) else {
                self.alert("PIN không hợp lệ", "Mã PIN phải đúng 6 chữ số.")
                return
            }
            BankState.shared.changePIN(pin)
            self.alert("Đã đổi PIN", "Mã PIN mới đã được lưu.")
        })
        present(alert, animated: true)
    }

    @objc private func resetDemo() {
        let alert = UIAlertController(title: "Khôi phục dữ liệu mẫu",
                                      message: "Số dư, lịch sử và sổ tiết kiệm sẽ trở lại ban đầu.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Khôi phục", style: .destructive) { _ in
            BankState.shared.resetDemo()
            self.alert("Đã khôi phục", "Dữ liệu mẫu đã được đặt lại.")
        })
        present(alert, animated: true)
    }
}

final class HistoryViewController: UIViewController {

    private let table = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Lịch sử giao dịch")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .clear
        table.tableFooterView = UIView()
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        table.reloadData()
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        BankState.shared.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = BankState.shared.transactions[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.font = TCB.font(14, .medium)
        cell.detailTextLabel?.text = "\(TCB.dateTime.string(from: item.date)) • \(item.subtitle)"
        cell.detailTextLabel?.font = TCB.font(11)
        cell.detailTextLabel?.textColor = TCB.inkFaint
        cell.accessoryView = {
            let l = UILabel()
            l.text = (item.isCredit ? "+" : "-") + TCB.money(item.amount)
            l.font = TCB.mono(13, .semibold)
            l.textColor = item.isCredit ? TCB.success : TCB.ink
            l.sizeToFit()
            return l
        }()
        return cell
    }
}

final class BeneficiariesViewController: UIViewController {

    private let table = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Người thụ hưởng")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .clear
        table.tableFooterView = UIView()
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        table.reloadData()
    }
}

extension BeneficiariesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        BankState.shared.beneficiaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = BankState.shared.beneficiaries[indexPath.row]
        cell.textLabel?.text = person.name
        cell.textLabel?.font = TCB.font(14, .medium)
        cell.detailTextLabel?.text = "\(person.bank) • \(person.account)"
        cell.detailTextLabel?.font = TCB.font(11)
        cell.detailTextLabel?.textColor = TCB.inkFaint
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let person = BankState.shared.beneficiaries[indexPath.row]
        let vc = TransferViewController()
        vc.prefill(name: person.name, account: person.account, bank: person.bank)
        navigationController?.pushViewController(vc, animated: true)
    }
}
