import Foundation

// MARK: - Direction
enum MoneyDirection: String, Codable {
    case credit   // tiền vào  -> "+"
    case debit    // tiền ra   -> "-"
}

// MARK: - Account masking
enum MaskStyle: String, Codable {
    case full          // 19031234567
    case keepLast4     // 1903****567
    case keepFirst4    // 1903*******
    case bullet        // •••• 4567
}

// MARK: - Template presets
//
// Mỗi preset là ĐÚNG chuỗi mà app ngân hàng in ra.
// Token: {account} {amount} {balance} {content} {time} {date} {sign} {currency}
//
enum TemplatePreset: String, CaseIterable {
    case techcombankApp
    case techcombankSMS
    case custom

    var label: String {
        switch self {
        case .techcombankApp: return "TCB App"
        case .techcombankSMS: return "TCB SMS"
        case .custom:         return "Custom"
        }
    }

    var body: String {
        switch self {
        case .techcombankApp:
            return "TK {account}: {sign}{amount} {currency}. Số dư: {balance} {currency}. ND: {content}. {time}"
        case .techcombankSMS:
            return "TK {account} {sign}{amount}{currency}. So du: {balance}{currency}. {time}. ND: {content}"
        case .custom:
            return "{sign}{amount} {currency}"
        }
    }

    var title: String {
        switch self {
        case .techcombankSMS: return "Techcombank"
        default:              return "Techcombank"
        }
    }

    var subtitle: String? { nil }
}

// MARK: - Model
struct BankNotification {

    var direction: MoneyDirection = .credit
    var account: String = "19031234567"
    var amount: Int64 = 50_000
    var balance: Int64 = 1_234_567
    var content: String = "Chuyen tien"
    var currency: String = "VND"
    var date: Date = Date()

    var preset: TemplatePreset = .techcombankApp
    var customBody: String = ""

    var mask: MaskStyle = .full
    var groupAsThread: Bool = true
    var timeSensitive: Bool = true
    var playSound: Bool = true
    var bumpBadge: Bool = true

    // MARK: Formatting

    private static let grouping: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.groupingSize = 3
        f.usesGroupingSeparator = true
        f.maximumFractionDigits = 0
        return f
    }()

    var formattedAmount: String {
        Self.grouping.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    var formattedBalance: String {
        Self.grouping.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }
    var sign: String { direction == .credit ? "+" : "-" }

    var maskedAccount: String {
        let digits = account.filter { $0.isNumber }
        guard digits.count >= 6 else { return account }
        switch mask {
        case .full:
            return account
        case .keepLast4:
            let head = String(digits.prefix(4))
            let tail = String(digits.suffix(4))
            return "\(head)****\(tail)"
        case .keepFirst4:
            let head = String(digits.prefix(4))
            return head + String(repeating: "*", count: max(0, digits.count - 4))
        case .bullet:
            return "•••• " + String(digits.suffix(4))
        }
    }

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm dd/MM/yyyy"
        return f
    }()

    var timeString: String { Self.timeFmt.string(from: date) }

    // MARK: Rendering

    var template: String {
        preset == .custom && !customBody.isEmpty ? customBody : preset.body
    }

    func render(_ raw: String) -> String {
        var s = raw
        let pairs: [(String, String)] = [
            ("{account}", maskedAccount),
            ("{amount}",  formattedAmount),
            ("{balance}", formattedBalance),
            ("{content}", content),
            ("{time}",    timeString),
            ("{date}",    timeString),
            ("{sign}",    sign),
            ("{currency}", currency)
        ]
        for (k, v) in pairs { s = s.replacingOccurrences(of: k, with: v) }
        return s
    }

    var title: String    { preset == .custom ? "Techcombank" : preset.title }
    var subtitle: String? { preset == .custom ? nil : preset.subtitle }
    var body: String     { render(template) }
}
