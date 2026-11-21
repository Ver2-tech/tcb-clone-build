import UIKit

// MARK: - Design tokens
//
// Bám theo bản Techcombank Mobile 4.0.36 trên App Store
// (vn.com.techcombank.bb.app). Màu lấy trực tiếp từ ảnh chụp store:
// hero đỏ #C93833 -> cam #F2744C, icon #ED1C24, sheet trắng, tab trắng.
//
enum TCB {

    // Brand
    static let red        = UIColor(red: 0xED/255.0, green: 0x1C/255.0, blue: 0x24/255.0, alpha: 1.0)
    static let redDeep    = UIColor(red: 0xB0/255.0, green: 0x17/255.0, blue: 0x1E/255.0, alpha: 1.0)
    static let heroStart  = UIColor(red: 0xC9/255.0, green: 0x38/255.0, blue: 0x33/255.0, alpha: 1.0)
    static let heroMid    = UIColor(red: 0xE3/255.0, green: 0x5D/255.0, blue: 0x42/255.0, alpha: 1.0)
    static let heroEnd    = UIColor(red: 0xF7/255.0, green: 0x7B/255.0, blue: 0x4F/255.0, alpha: 1.0)
    static let sun        = UIColor(red: 0xFB/255.0, green: 0xD7/255.0, blue: 0x9A/255.0, alpha: 1.0)
    static let road       = UIColor(red: 0xF2/255.0, green: 0xA7/255.0, blue: 0x8F/255.0, alpha: 1.0)
    static let amber      = UIColor(red: 0xF5/255.0, green: 0x9E/255.0, blue: 0x0B/255.0, alpha: 1.0)
    static let redTint    = UIColor(red: 0xED/255.0, green: 0x1C/255.0, blue: 0x24/255.0, alpha: 0.08)

    // Surfaces
    static let canvas     = UIColor(red: 0xF4/255.0, green: 0xF5/255.0, blue: 0xF7/255.0, alpha: 1.0)
    static let cream      = UIColor(red: 0xFB/255.0, green: 0xF6/255.0, blue: 0xEC/255.0, alpha: 1.0)
    static let card       = UIColor.white
    static let chip       = UIColor(red: 0xF2/255.0, green: 0xF3/255.0, blue: 0xF5/255.0, alpha: 1.0)
    static let line       = UIColor(red: 0xEC/255.0, green: 0xED/255.0, blue: 0xF0/255.0, alpha: 1.0)

    // Text
    static let ink        = UIColor(red: 0x1A/255.0, green: 0x1D/255.0, blue: 0x1F/255.0, alpha: 1.0)
    static let inkSoft    = UIColor(red: 0x6E/255.0, green: 0x72/255.0, blue: 0x78/255.0, alpha: 1.0)
    static let inkFaint   = UIColor(red: 0x9C/255.0, green: 0xA1/255.0, blue: 0xA8/255.0, alpha: 1.0)

    // Money
    static let success    = UIColor(red: 0x12/255.0, green: 0xB7/255.0, blue: 0x6A/255.0, alpha: 1.0)
    static let successBg  = UIColor(red: 0xE3/255.0, green: 0xF7/255.0, blue: 0xEC/255.0, alpha: 1.0)
    static let credit     = success
    static let danger     = red
    static let separator  = line

    // Type
    static func font(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
    static func mono(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
    }
    /// Font thật trích từ TCBRetail.app 4.0.11.
    static func brandFont(_ size: CGFloat) -> UIFont {
        UIFont(name: "Archivo-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    // Metrics
    static let radius: CGFloat  = 20
    static let gutter: CGFloat  = 16
    static let cardPad: CGFloat = 16

    // MARK: Formatters

    static func money(_ value: Int64, currency: String = "VND") -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        f.groupingSize = 3
        f.maximumFractionDigits = 0
        return currency + " " + (f.string(from: NSNumber(value: value)) ?? "\(value)")
    }

    static func grouped(_ value: Int64) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        f.groupingSize = 3
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func compact(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        f.groupingSize = 3
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return (f.string(from: NSNumber(value: value)) ?? "\(value)") + " Tr"
    }

    static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm dd/MM/yyyy"
        return f
    }()

    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm"
        return f
    }()
}

// MARK: - Shared user

enum TCBUser {
    static let fullName   = "NGUYEN VAN AN"
    static let shortName  = "An"
    static let initials   = "TM"
    static let customerID = "10428866"
    static let tier       = "Inspire"
    static let totalBalance: Int64 = 200_130_050
    static let uPoint: Int64 = 500_089
    static let cashback: Int64 = 3_120_000
    static let investValue: Int64 = 2_212_000_000
    static let investGain: Int64 = 424_704_000
    static let investGainPct = "+19.2%"
}

// MARK: - Account book (in-memory only)

struct TCBAction: Equatable, Codable {
    var title: String
    var subtitle: String
    var amount: Int64
    var date: Date
    var isCredit: Bool
}

enum TCBStore {

    static let accounts: [(name: String, number: String, balance: Int64, kind: String)] = [
        ("Tài khoản thanh toán", "19036728491507", 48_215_670, "VND"),
        ("Tài khoản tiết kiệm",  "19036728491566", 120_000_000, "VND"),
        ("Tài khoản USD",        "19036728491573", 2_340, "USD")
    ]

    static let transactions: [TCBAction] = {
        let now = Date()
        func ago(_ minutes: Double) -> Date { now.addingTimeInterval(-minutes * 60) }
        return [
            TCBAction(title: "Nhận tiền từ NGUYEN THI LAN",
                      subtitle: "Chuyển khoản nhanh 24/7",
                      amount: 5_000_000, date: ago(24), isCredit: true),
            TCBAction(title: "Thanh toán GRAB",
                      subtitle: "Ví điện tử",
                      amount: 68_000, date: ago(190), isCredit: false),
            TCBAction(title: "Nhận tiền từ CONG TY TNHH ABC",
                      subtitle: "Lương tháng 11",
                      amount: 22_400_000, date: ago(1_510), isCredit: true),
            TCBAction(title: "Chuyển tiền TRAN MINH DUC",
                      subtitle: "Chuyển khoản thường",
                      amount: 1_250_000, date: ago(2_760), isCredit: false),
            TCBAction(title: "Thanh toán SHOPEE",
                      subtitle: "Thẻ ghi nợ",
                      amount: 349_000, date: ago(4_100), isCredit: false)
        ]
    }()

    static let portfolio: [(name: String, value: Double, color: UIColor)] = [
        ("Cổ phiếu",  890.80, UIColor(red: 0x8B/255.0, green: 0x2B/255.0, blue: 0xF0/255.0, alpha: 1.0)),
        ("Vàng",      825.02, UIColor(red: 0xF5/255.0, green: 0xB5/255.0, blue: 0x1B/255.0, alpha: 1.0)),
        ("Trái phiếu", 372.75, UIColor(red: 0x2E/255.0, green: 0x8B/255.0, blue: 0xF5/255.0, alpha: 1.0)),
        ("Quỹ",       123.25, UIColor(red: 0x16/255.0, green: 0xC8/255.0, blue: 0xD4/255.0, alpha: 1.0))
    ]
}

// MARK: - Shadow

extension UIView {
    func tcbShadow(_ radius: CGFloat = 16, opacity: Float = 0.08, dy: CGFloat = 8) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: dy)
    }
}
