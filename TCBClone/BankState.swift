import Foundation
import UIKit
import UserNotifications

// MARK: - Persistent models

struct TCBAccount: Codable, Equatable {
    var id: String
    var name: String
    var number: String
    var balance: Int64
    var currency: String
    var kind: String
}

struct TCBSaving: Codable, Equatable {
    var id: String
    var name: String
    var principal: Int64
    var rate: Double
    var termMonths: Int
    var created: Date

    var interest: Int64 {
        Int64(Double(principal) * rate / 100.0 * Double(termMonths) / 12.0)
    }
    var maturity: Int64 { principal + interest }
}

struct TCBBeneficiary: Codable, Equatable {
    var id: String
    var name: String
    var account: String
    var bank: String
}

enum BankError: LocalizedError {
    case invalidAmount
    case insufficient
    case invalidAccount
    case notEnoughPoints
    case limitExceeded
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidAmount:    return "Số tiền không hợp lệ."
        case .insufficient:     return "Số dư tài khoản không đủ để thực hiện giao dịch."
        case .invalidAccount:   return "Vui lòng nhập đúng số tài khoản thụ hưởng."
        case .notEnoughPoints:  return "Điểm U-Point không đủ để đổi voucher này."
        case .limitExceeded:    return "Số tiền vượt hạn mức chuyển tiền mỗi ngày."
        case .notFound:         return "Không tìm thấy dữ liệu."
        }
    }
}

extension Notification.Name {
    static let tcbStateChanged = Notification.Name("tcb.state.changed")
}

// MARK: - Bank engine
//
// Toàn bộ giao dịch được lưu local bằng UserDefaults (Codable), cập nhật số dư,
// ghi lịch sử và bắn notification thật bằng UNUserNotificationCenter.
// Không có mạng, không có tài khoản ngân hàng thật — đây là bản mô phỏng đầy đủ
// để mọi nút trên giao diện đều có tác động nhất quán.

final class BankState {

    static let shared = BankState()

    private struct Snapshot: Codable {
        var accounts: [TCBAccount]
        var transactions: [TCBAction]
        var savings: [TCBSaving]
        var beneficiaries: [TCBBeneficiary]
        var claimedVouchers: [String]
        var autoEarnEnabled: Bool
        var autoEarnThreshold: Int64
        var uPoint: Int64
        var cashback: Int64
        var pin: String
    }

    private let key = "tcb.bank.state.v1"
    private var snap: Snapshot

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            snap = decoded
        } else {
            snap = Self.seed()
            save()
        }
    }

    // MARK: Seed

    private static func seed() -> Snapshot {
        let now = Date()
        func ago(_ minutes: Double) -> Date { now.addingTimeInterval(-minutes * 60) }

        let accounts = [
            TCBAccount(id: "checking", name: "Tài khoản thanh toán", number: "19036728491507",
                       balance: 48_215_670, currency: "VND", kind: "checking"),
            TCBAccount(id: "savings-1", name: "Tài khoản tiết kiệm", number: "19036728491566",
                       balance: 120_000_000, currency: "VND", kind: "savings"),
            TCBAccount(id: "usd", name: "Tài khoản USD", number: "19036728491573",
                       balance: 2_340, currency: "USD", kind: "foreign")
        ]

        let transactions = [
            TCBAction(title: "Nhận tiền từ NGUYEN THI LAN", subtitle: "Chuyển khoản nhanh 24/7",
                      amount: 5_000_000, date: ago(24), isCredit: true),
            TCBAction(title: "Thanh toán GRAB", subtitle: "Ví điện tử",
                      amount: 68_000, date: ago(190), isCredit: false),
            TCBAction(title: "Nhận tiền từ CONG TY TNHH ABC", subtitle: "Lương tháng 11",
                      amount: 22_400_000, date: ago(1_510), isCredit: true),
            TCBAction(title: "Chuyển tiền TRAN MINH DUC", subtitle: "Chuyển khoản thường",
                      amount: 1_250_000, date: ago(2_760), isCredit: false),
            TCBAction(title: "Thanh toán SHOPEE", subtitle: "Thẻ ghi nợ",
                      amount: 349_000, date: ago(4_100), isCredit: false)
        ]

        let savings = [
            TCBSaving(id: "sv-1", name: "Tiết kiệm 6 tháng", principal: 120_000_000,
                      rate: 6.2, termMonths: 6, created: ago(60 * 24 * 40)),
            TCBSaving(id: "sv-2", name: "Tiết kiệm sinh lời tự động", principal: 25_000_000,
                      rate: 5.5, termMonths: 1, created: ago(60 * 24 * 12))
        ]

        let beneficiaries = [
            TCBBeneficiary(id: "bf-1", name: "NGUYEN THI LAN", account: "19036728123456", bank: "Techcombank"),
            TCBBeneficiary(id: "bf-2", name: "TRAN MINH DUC", account: "0011234567890", bank: "Vietcombank"),
            TCBBeneficiary(id: "bf-3", name: "CONG TY TNHH ABC", account: "19036729998877", bank: "Techcombank")
        ]

        return Snapshot(accounts: accounts,
                        transactions: transactions,
                        savings: savings,
                        beneficiaries: beneficiaries,
                        claimedVouchers: [],
                        autoEarnEnabled: true,
                        autoEarnThreshold: 10_000_000,
                        uPoint: 500_089,
                        cashback: 3_120_000,
                        pin: "123456")
    }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(snap) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func commit() {
        save()
        NotificationCenter.default.post(name: .tcbStateChanged, object: nil)
    }

    func resetDemo() {
        snap = Self.seed()
        commit()
    }

    // MARK: Read

    var accounts: [TCBAccount] { snap.accounts }
    var transactions: [TCBAction] { snap.transactions }
    var savings: [TCBSaving] { snap.savings }
    var beneficiaries: [TCBBeneficiary] { snap.beneficiaries }
    var claimedVouchers: [String] { snap.claimedVouchers }
    var autoEarnEnabled: Bool { snap.autoEarnEnabled }
    var autoEarnThreshold: Int64 { snap.autoEarnThreshold }
    var uPoint: Int64 { snap.uPoint }
    var cashback: Int64 { snap.cashback }
    var pin: String { snap.pin }

    var dailyLimit: Int64 {
        let value = UserDefaults.standard.object(forKey: "tcb.limit.daily") as? Int ?? 50_000_000
        return Int64(value)
    }

    var checking: TCBAccount? {
        snap.accounts.first { $0.kind == "checking" }
    }

    var totalVND: Int64 {
        snap.accounts.filter { $0.currency == "VND" }.reduce(0) { $0 + $1.balance }
    }

    func account(id: String) -> TCBAccount? {
        snap.accounts.first { $0.id == id }
    }

    func isVoucherClaimed(_ id: String) -> Bool {
        snap.claimedVouchers.contains(id)
    }

    // MARK: Write - transfer

    @discardableResult
    func transfer(to name: String,
                  account: String,
                  bank: String,
                  amount: Int64,
                  note: String,
                  category: String = "Chuyển khoản") -> Result<TCBAction, BankError> {

        let digits = account.filter { $0.isNumber }
        guard digits.count >= 8 else { return .failure(.invalidAccount) }
        guard amount > 0 else { return .failure(.invalidAmount) }
        guard amount <= dailyLimit else { return .failure(.limitExceeded) }
        guard var source = checking else { return .failure(.notFound) }
        guard source.balance >= amount else { return .failure(.insufficient) }

        source.balance -= amount
        replace(source)

        let item = TCBAction(title: "Chuyển tiền \(name.isEmpty ? digits : name)",
                             subtitle: "\(category) • \(bank.isEmpty ? "Techcombank" : bank)",
                             amount: amount,
                             date: Date(),
                             isCredit: false)
        snap.transactions.insert(item, at: 0)

        let notification = BankNotification(direction: .debit,
                                            account: source.number,
                                            amount: amount,
                                            balance: source.balance,
                                            content: note.isEmpty ? category : note)
        NotificationEngine.shared.fire(notification, after: 0.6)

        if !snap.beneficiaries.contains(where: { $0.account == digits }) {
            snap.beneficiaries.insert(TCBBeneficiary(id: UUID().uuidString,
                                                     name: name.isEmpty ? "Người thụ hưởng mới" : name,
                                                     account: digits,
                                                     bank: bank.isEmpty ? "Techcombank" : bank), at: 0)
        }

        commit()
        return .success(item)
    }

    // MARK: Write - bill payment

    @discardableResult
    func payBill(provider: String, amount: Int64, note: String) -> Result<TCBAction, BankError> {
        guard amount > 0 else { return .failure(.invalidAmount) }
        guard var source = checking else { return .failure(.notFound) }
        guard source.balance >= amount else { return .failure(.insufficient) }

        source.balance -= amount
        replace(source)

        let item = TCBAction(title: "Thanh toán \(provider)",
                             subtitle: "Hóa đơn • \(note.isEmpty ? "Thanh toán hóa đơn" : note)",
                             amount: amount,
                             date: Date(),
                             isCredit: false)
        snap.transactions.insert(item, at: 0)

        let notification = BankNotification(direction: .debit,
                                            account: source.number,
                                            amount: amount,
                                            balance: source.balance,
                                            content: "Thanh toán \(provider)")
        NotificationEngine.shared.fire(notification, after: 0.6)

        commit()
        return .success(item)
    }

    // MARK: Write - savings

    @discardableResult
    func openSavings(name: String, amount: Int64, rate: Double, termMonths: Int) -> Result<TCBSaving, BankError> {
        guard amount >= 100_000 else { return .failure(.invalidAmount) }
        guard var source = checking else { return .failure(.notFound) }
        guard source.balance >= amount else { return .failure(.insufficient) }

        source.balance -= amount
        replace(source)

        let saving = TCBSaving(id: UUID().uuidString,
                               name: name,
                               principal: amount,
                               rate: rate,
                               termMonths: termMonths,
                               created: Date())
        snap.savings.insert(saving, at: 0)

        let account = TCBAccount(id: saving.id,
                                 name: name,
                                 number: String(format: "1903%011d", Int.random(in: 0..<99_999_999_999)),
                                 balance: amount,
                                 currency: "VND",
                                 kind: "savings")
        snap.accounts.insert(account, at: 1)

        let item = TCBAction(title: "Gửi tiết kiệm \(name)",
                             subtitle: "Kỳ hạn \(termMonths) tháng • \(String(format: "%.1f", rate))%/năm",
                             amount: amount,
                             date: Date(),
                             isCredit: false)
        snap.transactions.insert(item, at: 0)

        let notification = BankNotification(direction: .debit,
                                            account: source.number,
                                            amount: amount,
                                            balance: source.balance,
                                            content: "Gửi tiết kiệm \(name)")
        NotificationEngine.shared.fire(notification, after: 0.6)

        commit()
        return .success(saving)
    }

    func setAutoEarn(_ enabled: Bool, threshold: Int64) {
        snap.autoEarnEnabled = enabled
        snap.autoEarnThreshold = threshold
        commit()
    }

    // MARK: Write - rewards

    func redeemVoucher(id: String, cost: Int64) -> Result<Void, BankError> {
        guard snap.uPoint >= cost else { return .failure(.notEnoughPoints) }
        guard !snap.claimedVouchers.contains(id) else { return .failure(.notFound) }
        snap.uPoint -= cost
        snap.claimedVouchers.append(id)
        commit()
        return .success(())
    }

    // MARK: Write - PIN

    func changePIN(_ newPIN: String) {
        snap.pin = newPIN
        commit()
    }

    func verifyPIN(_ pin: String) -> Bool {
        pin == snap.pin
    }

    // MARK: Helpers

    private func replace(_ account: TCBAccount) {
        guard let index = snap.accounts.firstIndex(where: { $0.id == account.id }) else { return }
        snap.accounts[index] = account
    }
}
