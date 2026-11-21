import UIKit

final class WealthViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private let chartView = SparklineView()
    private var rangeButtons: [UIButton] = []
    private var selectedRange = 3
    private var hidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Tổng quan tài sản")
        build()
    }

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

        content.addArrangedSubview(summaryCard())
        content.addArrangedSubview(chartCard())
        content.addArrangedSubview(SectionHeader("Phân bổ theo kênh"))
        content.addArrangedSubview(allocationCard())
    }

    // MARK: Summary

    private func summaryCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let caption = UILabel()
        caption.text = "Tổng giá trị đầu tư"
        caption.font = TCB.font(14)
        caption.textColor = TCB.inkSoft
        caption.translatesAutoresizingMaskIntoConstraints = false

        let eye = UIButton(type: .system)
        eye.setImage(UIImage(systemName: "eye",
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)),
                     for: .normal)
        eye.tintColor = TCB.inkSoft
        eye.translatesAutoresizingMaskIntoConstraints = false
        eye.addTarget(self, action: #selector(toggle), for: .touchUpInside)

        let total = UILabel()
        total.text = TCB.money(TCBUser.investValue)
        total.font = TCB.mono(27, .bold)
        total.textColor = TCB.ink
        total.translatesAutoresizingMaskIntoConstraints = false
        total.tag = 101

        let gain = UILabel()
        gain.text = "+" + TCB.grouped(TCBUser.investGain)
        gain.font = TCB.mono(14, .semibold)
        gain.textColor = TCB.success
        gain.translatesAutoresizingMaskIntoConstraints = false
        gain.tag = 102

        let pct = UILabel()
        pct.text = TCBUser.investGainPct
        pct.font = TCB.font(13, .semibold)
        pct.textColor = TCB.success
        pct.textAlignment = .center
        pct.backgroundColor = TCB.successBg
        pct.layer.cornerRadius = 6
        pct.clipsToBounds = true
        pct.translatesAutoresizingMaskIntoConstraints = false
        pct.tag = 103

        [caption, eye, total, gain, pct].forEach { card.addSubview($0) }

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 14
        rows.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rows)

        for item in TCBStore.portfolio {
            rows.addArrangedSubview(assetRow(name: item.name, value: item.value, color: item.color))
        }

        let updated = UILabel()
        updated.text = "Cập nhật hôm nay lúc 14:30"
        updated.font = TCB.font(12)
        updated.textColor = TCB.inkFaint
        updated.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(updated)

        NSLayoutConstraint.activate([
            caption.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            caption.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            eye.leadingAnchor.constraint(equalTo: caption.trailingAnchor, constant: 6),
            eye.centerYAnchor.constraint(equalTo: caption.centerYAnchor),

            total.leadingAnchor.constraint(equalTo: caption.leadingAnchor),
            total.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 6),

            gain.leadingAnchor.constraint(equalTo: total.leadingAnchor),
            gain.topAnchor.constraint(equalTo: total.bottomAnchor, constant: 6),

            pct.leadingAnchor.constraint(equalTo: gain.trailingAnchor, constant: 10),
            pct.centerYAnchor.constraint(equalTo: gain.centerYAnchor),
            pct.heightAnchor.constraint(equalToConstant: 22),
            pct.widthAnchor.constraint(greaterThanOrEqualToConstant: 58),

            rows.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rows.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rows.topAnchor.constraint(equalTo: gain.bottomAnchor, constant: 18),

            updated.leadingAnchor.constraint(equalTo: caption.leadingAnchor),
            updated.topAnchor.constraint(equalTo: rows.bottomAnchor, constant: 18),
            updated.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func assetRow(name: String, value: Double, color: UIColor) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = color
        bar.layer.cornerRadius = 2
        bar.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = name
        label.font = TCB.font(15)
        label.textColor = TCB.ink
        label.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = "VND " + TCB.compact(value)
        amount.font = TCB.mono(14, .medium)
        amount.textColor = TCB.inkSoft
        amount.textAlignment = .right
        amount.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right",
                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)))
        chevron.tintColor = TCB.inkFaint
        chevron.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(bar)
        row.addSubview(label)
        row.addSubview(amount)
        row.addSubview(chevron)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 24),

            bar.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            bar.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.heightAnchor.constraint(equalToConstant: 18),

            label.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            amount.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            amount.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        return row
    }

    // MARK: Chart

    private func chartCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = TCB.line.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let chart = chartView
        card.addSubview(chart)

        let tooltip = UIView()
        tooltip.backgroundColor = UIColor(red: 0x14/255.0, green: 0x14/255.0, blue: 0x14/255.0, alpha: 1.0)
        tooltip.layer.cornerRadius = 8
        tooltip.translatesAutoresizingMaskIntoConstraints = false

        let tipValue = UILabel()
        tipValue.text = TCB.money(TCBUser.investValue)
        tipValue.font = TCB.mono(12, .semibold)
        tipValue.textColor = .white
        tipValue.translatesAutoresizingMaskIntoConstraints = false

        let tipGain = UILabel()
        tipGain.text = "+" + TCB.grouped(TCBUser.investGain) + "  " + TCBUser.investGainPct
        tipGain.font = TCB.mono(10, .medium)
        tipGain.textColor = TCB.success
        tipGain.translatesAutoresizingMaskIntoConstraints = false

        tooltip.addSubview(tipValue)
        tooltip.addSubview(tipGain)
        card.addSubview(tooltip)

        let from = UILabel()
        from.text = "Thg 3 2025"
        from.font = TCB.font(11)
        from.textColor = TCB.inkFaint
        from.translatesAutoresizingMaskIntoConstraints = false

        let to = UILabel()
        to.text = "Thg 3 2026"
        to.font = TCB.font(11)
        to.textColor = TCB.inkFaint
        to.textAlignment = .right
        to.translatesAutoresizingMaskIntoConstraints = false

        let range = UIStackView()
        range.axis = .horizontal
        range.distribution = .fillEqually
        range.translatesAutoresizingMaskIntoConstraints = false

        for (i, title) in ["1 tháng", "3 tháng", "6 tháng", "1 năm"].enumerated() {
            let button = UIButton(type: .system)
            button.tag = i
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = TCB.font(12, .medium)
            button.addTarget(self, action: #selector(selectRange(_:)), for: .touchUpInside)
            rangeButtons.append(button)
            if i == 3 {
                button.setTitleColor(TCB.ink, for: .normal)
                button.backgroundColor = .white
                button.layer.cornerRadius = 14
                button.layer.borderWidth = 1
                button.layer.borderColor = TCB.ink.cgColor
            } else {
                button.setTitleColor(TCB.inkSoft, for: .normal)
            }
            range.addArrangedSubview(button)
        }

        card.addSubview(from)
        card.addSubview(to)
        card.addSubview(range)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 340),

            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            chart.heightAnchor.constraint(equalToConstant: 220),

            tooltip.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            tooltip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            tooltip.widthAnchor.constraint(equalToConstant: 200),

            tipValue.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 7),
            tipValue.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 10),

            tipGain.topAnchor.constraint(equalTo: tipValue.bottomAnchor, constant: 2),
            tipGain.leadingAnchor.constraint(equalTo: tipValue.leadingAnchor),
            tipGain.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -7),

            from.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            from.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 4),

            to.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            to.centerYAnchor.constraint(equalTo: from.centerYAnchor),

            range.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            range.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            range.topAnchor.constraint(equalTo: from.bottomAnchor, constant: 12),
            range.heightAnchor.constraint(equalToConstant: 30),
            range.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    // MARK: Allocation

    private func allocationCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        let total = TCBStore.portfolio.reduce(0.0) { $0 + $1.value }

        for item in TCBStore.portfolio {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let bar = UIView()
            bar.backgroundColor = item.color
            bar.layer.cornerRadius = 3
            bar.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = item.name
            label.font = TCB.font(14, .medium)
            label.textColor = TCB.ink
            label.translatesAutoresizingMaskIntoConstraints = false

            let pct = UILabel()
            pct.text = String(format: "%.1f%%", item.value / total * 100)
            pct.font = TCB.mono(13, .medium)
            pct.textColor = TCB.inkSoft
            pct.textAlignment = .right
            pct.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(bar)
            row.addSubview(label)
            row.addSubview(pct)

            NSLayoutConstraint.activate([
                row.heightAnchor.constraint(equalToConstant: 24),

                bar.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                bar.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                bar.widthAnchor.constraint(equalToConstant: 8),
                bar.heightAnchor.constraint(equalToConstant: 8),
                bar.layer.cornerRadius = 4,

                label.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 10),
                label.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                pct.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                pct.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])

            stack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    @objc private func selectRange(_ sender: UIButton) {
        selectedRange = sender.tag

        for button in rangeButtons {
            if button.tag == selectedRange {
                button.setTitleColor(TCB.ink, for: .normal)
                button.backgroundColor = .white
                button.layer.cornerRadius = 14
                button.layer.borderWidth = 1
                button.layer.borderColor = TCB.ink.cgColor
            } else {
                button.setTitleColor(TCB.inkSoft, for: .normal)
                button.backgroundColor = .clear
                button.layer.borderWidth = 0
            }
        }

        switch selectedRange {
        case 0:
            chartView.values = [0.52, 0.60, 0.48, 0.66, 0.58, 0.74, 0.69, 0.88, 0.80, 1.0]
        case 1:
            chartView.values = [0.44, 0.58, 0.50, 0.68, 0.60, 0.78, 0.71, 0.86, 0.83, 1.0]
        case 2:
            chartView.values = [0.40, 0.52, 0.46, 0.62, 0.55, 0.72, 0.66, 0.82, 0.78, 0.94, 0.88, 1.0]
        default:
            chartView.values = [0.42, 0.50, 0.46, 0.60, 0.54, 0.72, 0.66, 0.80, 0.74, 0.92, 0.86, 1.0]
        }
    }

    @objc private func toggle() {
        hidden.toggle()
        guard let total = view.viewWithTag(101) as? UILabel else { return }
        total.text = hidden ? "VND ••••••••••" : TCB.money(TCBUser.investValue)
    }
}
