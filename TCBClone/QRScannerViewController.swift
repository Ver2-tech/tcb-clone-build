import UIKit
import AVFoundation

// MARK: - Parsed QR payload

struct QRPayInfo {
    var raw: String
    var account: String = ""
    var bank: String = ""
    var amount: Int64 = 0
    var note: String = ""
    var name: String = ""
}

// MARK: - Delegate

protocol QRScannerDelegate: AnyObject {
    func qrScanner(_ scanner: QRScannerViewController, didRead info: QRPayInfo)
}

// MARK: - Camera scanner

final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    weak var delegate: QRScannerDelegate?

    private let session = AVCaptureSession()
    private var preview: AVCaptureVideoPreviewLayer?
    private let overlay = UIView()
    private let frameView = UIView()
    private let scanLine = UIView()
    private let torchButton = UIButton(type: .system)
    private let manualButton = UIButton(type: .system)
    private let hint = UILabel()
    private var didRead = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Quét mã QR"
        applyTCBNavigationBar("Quét mã QR")
        buildOverlay()
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if !session.isRunning { DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() } }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview?.frame = view.bounds
    }

    // MARK: UI

    private func buildOverlay() {
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.isUserInteractionEnabled = false
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)

        let side: CGFloat = 250

        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 1.5
        frameView.layer.cornerRadius = 12
        frameView.backgroundColor = .clear
        frameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frameView)

        let lineColor = UIColor(red: 0xED/255.0, green: 0x1C/255.0, blue: 0x24/255.0, alpha: 1.0)
        scanLine.backgroundColor = lineColor
        scanLine.layer.shadowColor = lineColor.cgColor
        scanLine.layer.shadowRadius = 8
        scanLine.layer.shadowOpacity = 0.9
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        frameView.addSubview(scanLine)

        hint.text = "Đặt mã QR vào khung để quét"
        hint.font = TCB.font(13, .medium)
        hint.textColor = .white
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hint)

        torchButton.setTitle("Bật đèn", for: .normal)
        torchButton.setTitleColor(.white, for: .normal)
        torchButton.titleLabel?.font = TCB.font(14, .semibold)
        torchButton.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        torchButton.layer.cornerRadius = 22
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        torchButton.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
        view.addSubview(torchButton)

        manualButton.setTitle("Nhập số tài khoản thủ công", for: .normal)
        manualButton.setTitleColor(.white, for: .normal)
        manualButton.titleLabel?.font = TCB.font(14, .medium)
        manualButton.translatesAutoresizingMaskIntoConstraints = false
        manualButton.addTarget(self, action: #selector(manualEntry), for: .touchUpInside)
        view.addSubview(manualButton)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            frameView.widthAnchor.constraint(equalToConstant: side),
            frameView.heightAnchor.constraint(equalToConstant: side),

            scanLine.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: 12),
            scanLine.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: -12),
            scanLine.heightAnchor.constraint(equalToConstant: 2),
            scanLine.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 20),

            hint.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 20),
            hint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            hint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            torchButton.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 24),
            torchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            torchButton.widthAnchor.constraint(equalToConstant: 140),
            torchButton.heightAnchor.constraint(equalToConstant: 44),

            manualButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            manualButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.scanLine.transform = CGAffineTransform(translationX: 0, y: side - 44)
        }
    }

    // MARK: Camera

    private func setupCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.configureSession() }
                    else { self?.hint.text = "Cần cấp quyền camera để quét mã" }
                }
            }
        default:
            hint.text = "Cần cấp quyền camera trong Cài đặt"
        }
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            hint.text = "Không tìm thấy camera"
            return
        }

        session.beginConfiguration()
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .code128, .code39]
        }
        session.commitConfiguration()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        preview = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !didRead,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let raw = object.stringValue else { return }
        didRead = true
        session.stopRunning()
        let info = QRPayInfo.parse(raw)
        delegate?.qrScanner(self, didRead: info)
    }

    // MARK: Actions

    @objc private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            torchButton.setTitle(device.torchMode == .on ? "Tắt đèn" : "Bật đèn", for: .normal)
            device.unlockForConfiguration()
        } catch {
            hint.text = "Không bật được đèn flash"
        }
    }

    @objc private func manualEntry() {
        let alert = UIAlertController(title: "Nhập số tài khoản",
                                      message: "Nhập số tài khoản hoặc nội dung mã QR",
                                      preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "19036728491507"
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel) { [weak self] _ in
            self?.didRead = false
            self?.session.startRunning()
        })
        alert.addAction(UIAlertAction(title: "Tiếp tục", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self?.didRead = true
            self?.delegate?.qrScanner(self!, didRead: QRPayInfo.parse(text))
        })
        present(alert, animated: true)
    }
}

// MARK: - Payload parser

extension QRPayInfo {

    static func parse(_ raw: String) -> QRPayInfo {
        var info = QRPayInfo(raw: raw)

        if raw.hasPrefix("000201") {
            let tags = tlv(raw)
            let merchant = tlv(tags["38"] ?? "")
            let extra = tlv(tags["62"] ?? "")

            info.bank = merchant["00"] ?? ""
            info.account = merchant["01"] ?? tags["38"] ?? ""
            info.amount = Int64(tags["54"] ?? "") ?? 0
            info.note = extra["08"] ?? tags["08"] ?? ""
            info.name = extra["09"] ?? ""
            return info
        }

        let digits = raw.filter { $0.isNumber }
        if digits.count >= 8 {
            info.account = digits
        } else {
            info.note = raw
        }
        return info
    }

    private static func tlv(_ text: String) -> [String: String] {
        var result: [String: String] = [:]
        var index = text.startIndex

        while index < text.endIndex {
            guard let idEnd = text.index(index, offsetBy: 2, limitedBy: text.endIndex),
                  let id = Int(text[index..<idEnd]) else { break }
            guard let lenEnd = text.index(idEnd, offsetBy: 2, limitedBy: text.endIndex),
                  let length = Int(text[idEnd..<lenEnd]) else { break }
            guard let valueEnd = text.index(lenEnd, offsetBy: length, limitedBy: text.endIndex) else { break }

            result[String(format: "%02d", id)] = String(text[lenEnd..<valueEnd])
            index = valueEnd
        }
        return result
    }
}
