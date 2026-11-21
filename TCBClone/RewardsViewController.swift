import UIKit

final class RewardsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    private var chips: [UILabel] = []
    private var secondsLeft = 109
    private var timer: Timer?
    private var dealsMap: [Int: (id: String, title: String, price: Int64)] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TCB.canvas
        applyTCBNavigationBar("Techcombank Rewards")
        build()
        startTimer()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPoints),
                                               name: .tcbStateChanged,
                                               object: nil)
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func refreshPoints() {
        if let left = view.viewWithTag(201) as? UILabel {
            left.text = TCB.grouped(BankState.shared.uPoint)
        }
        if let right = view.viewWithTag(202) as? UILabel {
            right.text = TCB.grouped(BankState.shared.cashback)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: Build

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

        content.addArrangedSubview(uBanner())
        content.addArrangedSubview(pointsCard())
        content.addArrangedSubview(dealsCard())
    }

    // MARK: U banner

    private func uBanner() -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false

        let circle = UIView()
        circle.backgroundColor = TCB.red
        circle.layer.cornerRadius = 22
        circle.translatesAutoresizingMaskIntoConstraints = false

        let u = UILabel()
        u.text = "U"
        u.font = TCB.font(22, .heavy)
        u.textColor = .white
        u.textAlignment = .center
        u.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(u)

        let pill = UIView()
        pill.backgroundColor = TCB.cream
        pill.layer.cornerRadius = 20
        pill.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Dùng điểm đổi ưu đãi"
        label.font = TCB.font(15, .semibold)
        label.textColor = TCB.ink
        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        wrap.addSubview(circle)
        wrap.addSubview(pill)

        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 44),

            circle.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 24),
            circle.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 44),
            circle.heightAnchor.constraint(equalToConstant: 44),

            u.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            u.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1),

            pill.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: -4),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: wrap.trailingAnchor, constant: -24),
            pill.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            pill.heightAnchor.constraint(equalToConstant: 40),

            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        return wrap
    }

    // MARK: Points card

    private func pointsCard() -> UIView {
        let card = GradientView(colors: [UIColor(red: 0xE9/255.0, green: 0x5A/255.0, blue: 0x3F/255.0, alpha: 1.0),
                                         UIColor(red: 0xDE/255.0, green: 0x4B/255.0, blue: 0x33/255.0, alpha: 1.0)],
                                start: CGPoint(x: 0.0, y: 0.0),
                                end: CGPoint(x: 1.0, y: 1.0))
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false

        // Sóng trang trí
        let wave = UIView()
        wave.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        wave.layer.cornerRadius = 60
        wave.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(wave)

        let vouchers = UIButton(type: .system)
        var vcfg = UIButton.Configuration.filled()
        vcfg.baseBackgroundColor = .white
        vcfg.baseForegroundColor = TCB.ink
        vcfg.cornerStyle = .capsule
        vcfg.title = "Voucher của tôi   4"
        vcfg.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        vcfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = TCB.font(13, .medium)
            return out
        }
        vouchers.configuration = vcfg
        vouchers.translatesAutoresizingMaskIntoConstraints = false

        let panel = UIView()
        panel.backgroundColor = .white
        panel.layer.cornerRadius = 12
        panel.layer.cornerCurve = .continuous
        panel.translatesAutoresizingMaskIntoConstraints = false

        let divider = UIView()
        divider.backgroundColor = TCB.line
        divider.translatesAutoresizingMaskIntoConstraints = false

        let leftCaption = UILabel()
        leftCaption.text = "Số dư U-Point"
        leftCaption.font = TCB.font(12)
        leftCaption.textColor = TCB.inkSoft
        leftCaption.translatesAutoresizingMaskIntoConstraints = false

        let leftIcon = UILabel()
        leftIcon.text = "U"
        leftIcon.font = TCB.font(13, .heavy)
        leftIcon.textColor = .white
        leftIcon.textAlignment = .center
        leftIcon.backgroundColor = TCB.red
        leftIcon.layer.cornerRadius = 10
        leftIcon.clipsToBounds = true
        leftIcon.translatesAutoresizingMaskIntoConstraints = false

        let leftValue = UILabel()
        leftValue.text = TCB.grouped(BankState.shared.uPoint)
        leftValue.tag = 201
        leftValue.font = TCB.mono(20, .bold)
        leftValue.textColor = TCB.ink
        leftValue.translatesAutoresizingMaskIntoConstraints = false

        let rightCaption = UILabel()
        rightCaption.text = "Số dư điểm hoàn tiền"
        rightCaption.font = TCB.font(12)
        rightCaption.textColor = TCB.inkSoft
        rightCaption.translatesAutoresizingMaskIntoConstraints = false

        let rightIcon = UIImageView(image: UIImage(systemName: "circle.hexagongrid.fill",
                                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)))
        rightIcon.tintColor = TCB.ink
        rightIcon.translatesAutoresizingMaskIntoConstraints = false

        let rightValue = UILabel()
        rightValue.text = TCB.grouped(BankState.shared.cashback)
        rightValue.tag = 202
        rightValue.font = TCB.mono(20, .bold)
        rightValue.textColor = TCB.ink
        rightValue.translatesAutoresizingMaskIntoConstraints = false

        [vouchers, wave, panel].forEach { card.addSubview($0) }
        [divider, leftCaption, leftIcon, leftValue, rightCaption, rightIcon, rightValue].forEach { panel.addSubview($0) }

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 176),

            wave.widthAnchor.constraint(equalToConstant: 180),
            wave.heightAnchor.constraint(equalToConstant: 180),
            wave.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            wave.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -40),

            vouchers.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            vouchers.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),

            panel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            panel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            panel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            panel.heightAnchor.constraint(equalToConstant: 100),

            divider.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            divider.topAnchor.constraint(equalTo: panel.topAnchor, constant: 18),
            divider.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -18),
            divider.widthAnchor.constraint(equalToConstant: 1),

            leftCaption.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            leftCaption.topAnchor.constraint(equalTo: panel.topAnchor, constant: 22),

            leftIcon.leadingAnchor.constraint(equalTo: leftCaption.leadingAnchor),
            leftIcon.topAnchor.constraint(equalTo: leftCaption.bottomAnchor, constant: 8),
            leftIcon.widthAnchor.constraint(equalToConstant: 20),
            leftIcon.heightAnchor.constraint(equalToConstant: 20),

            leftValue.leadingAnchor.constraint(equalTo: leftIcon.trailingAnchor, constant: 8),
            leftValue.centerYAnchor.constraint(equalTo: leftIcon.centerYAnchor),

            rightCaption.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 16),
            rightCaption.topAnchor.constraint(equalTo: leftCaption.topAnchor),

            rightIcon.leadingAnchor.constraint(equalTo: rightCaption.leadingAnchor),
            rightIcon.centerYAnchor.constraint(equalTo: leftIcon.centerYAnchor),
            rightIcon.widthAnchor.constraint(equalToConstant: 20),
            rightIcon.heightAnchor.constraint(equalToConstant: 20),

            rightValue.leadingAnchor.constraint(equalTo: rightIcon.trailingAnchor, constant: 6),
            rightValue.centerYAnchor.constraint(equalTo: leftIcon.centerYAnchor),
            rightValue.trailingAnchor.constraint(lessThanOrEqualTo: panel.trailingAnchor, constant: -8)
        ])

        return card
    }

    // MARK: Deals

    private func dealsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Flash Deals"
        title.font = TCB.font(19, .bold)
        title.textColor = TCB.ink
        title.translatesAutoresizingMaskIntoConstraints = false

        let timerRow = UIStackView()
        timerRow.axis = .horizontal
        timerRow.spacing = 4
        timerRow.translatesAutoresizingMaskIntoConstraints = false

        for i in 0..<5 {
            if i % 2 == 1 {
                let colon = UILabel()
                colon.text = ":"
                colon.font = TCB.font(15, .bold)
                colon.textColor = TCB.ink
                colon.textAlignment = .center
                colon.translatesAutoresizingMaskIntoConstraints = false
                timerRow.addArrangedSubview(colon)
            } else {
                let chip = UILabel()
                chip.text = "00"
                chip.font = TCB.mono(14, .bold)
                chip.textColor = TCB.ink
                chip.textAlignment = .center
                chip.backgroundColor = TCB.cream
                chip.layer.cornerRadius = 6
                chip.clipsToBounds = true
                chip.translatesAutoresizingMaskIntoConstraints = false
                chip.widthAnchor.constraint(equalToConstant: 30).isActive = true
                chip.heightAnchor.constraint(equalToConstant: 26).isActive = true
                chips.append(chip)
                timerRow.addArrangedSubview(chip)
            }
        }

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 14
        grid.translatesAutoresizingMaskIntoConstraints = false

        let deals: [(id: String, title: String, claimed: String, price: Int64, fill: CGFloat, tint: [UIColor])] = [
            ("starbucks", "Giảm VND 100,000 Starbucks", "146", 100_000, 0.62,
             [UIColor(red: 0x2E/255.0, green: 0x5A/255.0, blue: 0x45/255.0, alpha: 1.0),
              UIColor(red: 0x18/255.0, green: 0x33/255.0, blue: 0x27/255.0, alpha: 1.0)]),
            ("pizza", "Giảm VND 300,000 Pizza 4P's", "228", 300_000, 0.78,
             [UIColor(red: 0xC9/255.0, green: 0x9B/255.0, blue: 0x6A/255.0, alpha: 1.0),
              UIColor(red: 0x8C/255.0, green: 0x63/255.0, blue: 0x3D/255.0, alpha: 1.0)]),
            ("highlands", "Giảm VND 50,000 Highlands", "84", 50_000, 0.40,
             [UIColor(red: 0x2F/255.0, green: 0x2C/255.0, blue: 0x2A/255.0, alpha: 1.0),
              UIColor(red: 0x18/255.0, green: 0x16/255.0, blue: 0x15/255.0, alpha: 1.0)]),
            ("cgv", "Giảm VND 200,000 CGV", "162", 200_000, 0.66,
             [UIColor(red: 0xE0/255.0, green: 0x53/255.0, blue: 0x3C/255.0, alpha: 1.0),
              UIColor(red: 0xB6/255.0, green: 0x2F/255.0, blue: 0x22/255.0, alpha: 1.0)])
        ]

        for deal in deals {
            dealsMap[deal.id.hash] = (deal.id, deal.title, deal.price)
        }

        var currentRow: UIStackView?
        for (index, deal) in deals.enumerated() {
            if index % 2 == 0 {
                let line = UIStackView()
                line.axis = .horizontal
                line.spacing = 12
                line.distribution = .fillEqually
                line.alignment = .top
                grid.addArrangedSubview(line)
                currentRow = line
            }
            currentRow?.addArrangedSubview(dealCard(id: deal.id,
                                                    title: deal.title,
                                                    claimed: deal.claimed,
                                                    price: deal.price,
                                                    fill: deal.fill,
                                                    tint: deal.tint))
        }

        card.addSubview(title)
        card.addSubview(timerRow)
        card.addSubview(grid)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            timerRow.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 10),
            timerRow.centerYAnchor.constraint(equalTo: title.centerYAnchor),

            grid.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            grid.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            grid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func dealCard(id: String, title: String, claimed: String, price: Int64, fill: CGFloat, tint: [UIColor]) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true
        card.tag = id.hash
        let tap = UITapGestureRecognizer(target: self, action: #selector(redeemTapped(_:)))
        card.addGestureRecognizer(tap)

        let art = GradientView(colors: tint, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 1.0, y: 1.0))
        art.layer.cornerRadius = 10
        art.layer.cornerCurve = .continuous
        art.clipsToBounds = true
        art.translatesAutoresizingMaskIntoConstraints = false

        let glyph = UIImageView(image: UIImage(systemName: "cup.and.saucer.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)))
        glyph.tintColor = UIColor.white.withAlphaComponent(0.85)
        glyph.translatesAutoresizingMaskIntoConstraints = false
        art.addSubview(glyph)

        let bar = UIView()
        bar.backgroundColor = TCB.chip
        bar.layer.cornerRadius = 6
        bar.clipsToBounds = true
        bar.translatesAutoresizingMaskIntoConstraints = false

        let progress = UIView()
        progress.backgroundColor = TCB.amber
        progress.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(progress)

        let claimedLabel = UILabel()
        claimedLabel.text = claimed
        claimedLabel.font = TCB.mono(9, .bold)
        claimedLabel.textColor = .white
        claimedLabel.textAlignment = .center
        claimedLabel.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(claimedLabel)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = TCB.font(13, .semibold)
        titleLabel.textColor = TCB.ink
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let oldPrice = UILabel()
        oldPrice.attributedText = NSAttributedString(string: "U " + TCB.grouped(price), attributes: [
            .font: TCB.font(12),
            .foregroundColor: TCB.inkFaint,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: TCB.inkFaint
        ])
        oldPrice.translatesAutoresizingMaskIntoConstraints = false

        let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)))
        check.tintColor = TCB.success
        check.translatesAutoresizingMaskIntoConstraints = false

        [art, bar, titleLabel, oldPrice, check].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: card.topAnchor),
            art.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            art.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            art.heightAnchor.constraint(equalToConstant: 104),

            glyph.centerXAnchor.constraint(equalTo: art.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: art.centerYAnchor),

            bar.topAnchor.constraint(equalTo: art.bottomAnchor, constant: 8),
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: 13),

            progress.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            progress.topAnchor.constraint(equalTo: bar.topAnchor),
            progress.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
            progress.widthAnchor.constraint(equalTo: bar.widthAnchor, multiplier: fill),

            claimedLabel.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 7),
            claimedLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor),

            oldPrice.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            oldPrice.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            oldPrice.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            check.leadingAnchor.constraint(equalTo: oldPrice.trailingAnchor, constant: 4),
            check.centerYAnchor.constraint(equalTo: oldPrice.centerYAnchor)
        ])

        return card
    }

    // MARK: Redeem

    @objc private func redeemTapped(_ gesture: UITapGestureRecognizer) {
        guard let deal = dealsMap[gesture.view?.tag ?? 0] else { return }

        if BankState.shared.isVoucherClaimed(deal.id) {
            alert("Đã đổi", "Voucher \"\(deal.title)\" đã có trong Voucher của tôi.")
            return
        }

        let confirm = UIAlertController(title: "Đổi voucher",
                                        message: "Đổi \(deal.title) bằng \(TCB.grouped(deal.price)) U-Point?\nSố dư hiện có: \(TCB.grouped(BankState.shared.uPoint))",
                                        preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Đổi ngay", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let result = BankState.shared.redeemVoucher(id: deal.id, cost: deal.price)
            switch result {
            case .success:
                let a = UIAlertController(title: "Đổi thành công",
                                          message: "Voucher \(deal.title) đã được thêm vào Voucher của tôi.",
                                          preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(a, animated: true)
            case .failure(let error):
                self.alert("Không thể đổi", error.localizedDescription)
            }
        })
        present(confirm, animated: true)
    }

    // MARK: Timer

    private func startTimer() {
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsLeft = max(0, self.secondsLeft - 1)
            self.tick()
        }
    }

    private func tick() {
        guard chips.count == 3 else { return }
        let h = secondsLeft / 3600
        let m = (secondsLeft % 3600) / 60
        let s = secondsLeft % 60
        chips[0].text = String(format: "%02d", h)
        chips[1].text = String(format: "%02d", m)
        chips[2].text = String(format: "%02d", s)
    }
}
