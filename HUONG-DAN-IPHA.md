# Cài lên iPhone

Máy Windows này không có Xcode nên **không build được IPA ở đây**. Có 2 cách.

## Cách 1 — GitHub Actions (không cần Mac)

1. Tạo repo riêng trên GitHub.
2. Upload toàn bộ thư mục `TCBClone` vào repo (giữ nguyên cấu trúc, có `.github/workflows/build-ipa.yml`).
3. Vào tab **Actions** → **Build IPA (unsigned)** → **Run workflow**.
4. Chạy xong, tải artifact `TCBClone-unsigned` về, giải nén được `TCBClone-unsigned.ipa`.
5. Trên Windows cài **Sideloadly** (https://sideloadly.io) → cắm iPhone qua cáp → chọn file IPA → nhập Apple ID + mật khẩu ứng dụng (app-specific password, tạo ở appleid.apple.com) → Start.
6. Trên iPhone: **Cài đặt → Chung → VPN & Quản lý thiết bị** → chọn cert → Trust.

Apple ID miễn phí: cert hết hạn sau **7 ngày**, phải cài lại bằng Sideloadly. Có tài khoản Developer trả phí thì dùng được 1 năm.

## Cách 2 — máy Mac có Xcode

```bash
cd TCBClone
bash build-unsigned.sh
```

Ra `TCBClone-unsigned.ipa`, rồi làm tiếp bước 5–6 ở trên. Hoặc mở `TCBClone.xcodeproj`, chọn team của mày, ⌘R chạy trực tiếp.

## Về cái API ngân hàng

Không phải là "dễ lấy" — lý do cụ thể:

- IPA trên App Store được **FairPlay encrypt**. Không đọc được endpoint thật nếu không có IPA đã decrypt từ máy jailbreak. File mày đưa tuần trước là hàng giả 143 KB, trong đó chỉ có một call tới `shopaccuytin.fun/check.php`, không phải API của TCB.
- Dù có bản decrypt, app dùng **mTLS + device binding + ký request bằng key nằm trong Keychain/Secure Enclave + FIDO**. Thiếu mấy cái đó thì server trả 401/403 ngay, đang chạy giả cũng bị chặn.
- Muốn tao nối API thì đưa cụ thể: endpoint, method, header, ví dụ request/response, và credential/cert hợp lệ. Có mấy thứ đó tao viết lớp network và thay toàn bộ dữ liệu mẫu bằng dữ liệu thật.

Không có mấy thứ đó thì app chạy offline là mức cao nhất có thể làm được — mọi luồng vẫn hoạt động, chỉ không đụng tới tiền thật.

## Đăng nhập

Tên đăng nhập bất kỳ, PIN mặc định `123456`. Đổi PIN trong **Cài đặt → Bảo mật & đăng nhập**.
