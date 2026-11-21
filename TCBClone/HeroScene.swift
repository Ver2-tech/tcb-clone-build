import UIKit

// MARK: - Hero illustration
//
// Dựng lại đúng khung cảnh trong ảnh store: mặt trời lớn bên phải,
// con đường chéo sáng dần về phía chân trời, 5 cột đèn cong dần nhỏ lại,
// một chiếc xe đang chạy trên đường. Toàn bộ vẽ bằng Core Graphics nên
// không cần asset ảnh và vẫn sắc nét ở mọi độ phân giải.

final class HeroSceneView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let w = rect.width
        let h = rect.height

        drawSun(in: ctx, w: w, h: h)
        drawRoad(in: ctx, w: w, h: h)
        drawLamps(in: ctx, w: w, h: h)
        drawCar(in: ctx, w: w, h: h)
    }

    // MARK: Sun

    private func drawSun(in ctx: CGContext, w: CGFloat, h: CGFloat) {
        let center = CGPoint(x: w * 0.88, y: h * 0.56)
        let radius = h * 0.30

        ctx.saveGState()
        let colors = [TCB.sun.withAlphaComponent(0.95).cgColor,
                      TCB.sun.withAlphaComponent(0.55).cgColor,
                      TCB.sun.withAlphaComponent(0.0).cgColor] as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 0.72, 1.0]) {
            ctx.drawRadialGradient(gradient,
                                   startCenter: center, startRadius: radius * 0.55,
                                   endCenter: center, endRadius: radius * 1.6,
                                   options: [])
        }
        ctx.setFillColor(TCB.sun.cgColor)
        ctx.fillEllipse(in: CGRect(x: center.x - radius,
                                   y: center.y - radius,
                                   width: radius * 2,
                                   height: radius * 2))
        ctx.restoreGState()
    }

    // MARK: Road

    private func drawRoad(in ctx: CGContext, w: CGFloat, h: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -w * 0.10, y: h))
        path.addLine(to: CGPoint(x: w * 0.46, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 1.10, y: h * 0.50))
        path.addLine(to: CGPoint(x: w * 1.10, y: h))
        path.close()

        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.clip()

        let colors = [TCB.road.withAlphaComponent(0.18).cgColor,
                      TCB.road.withAlphaComponent(0.55).cgColor,
                      TCB.road.withAlphaComponent(0.85).cgColor] as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 0.55, 1.0]) {
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: w * 0.5, y: h * 0.60),
                                   end: CGPoint(x: w * 0.5, y: h),
                                   options: [])
        }
        ctx.restoreGState()

        // Vạch chia làn mờ.
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.30).cgColor)
        ctx.setLineWidth(max(1.0, h * 0.004))
        ctx.setLineCap(.round)
        let lane = UIBezierPath()
        lane.move(to: CGPoint(x: w * 0.10, y: h))
        lane.addLine(to: CGPoint(x: w * 0.52, y: h * 0.66))
        ctx.addPath(lane.cgPath)
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: Lamps

    private func drawLamps(in ctx: CGContext, w: CGFloat, h: CGFloat) {
        // 5 cột, cột gần bên trái cao nhất, nhỏ dần về chân trời.
        let specs: [(x: CGFloat, baseY: CGFloat, height: CGFloat)] = [
            (0.06, 0.90, 0.36),
            (0.24, 0.82, 0.30),
            (0.42, 0.76, 0.24),
            (0.60, 0.72, 0.18),
            (0.75, 0.69, 0.13)
        ]

        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.55).cgColor)
        ctx.setLineCap(.round)

        for spec in specs {
            let x = w * spec.x
            let base = h * spec.baseY
            let top = base - h * spec.height
            let head = h * spec.height * 0.22

            ctx.setLineWidth(max(1.0, h * 0.006))
            let pole = UIBezierPath()
            pole.move(to: CGPoint(x: x, y: base))
            pole.addQuadCurve(to: CGPoint(x: x + head * 0.55, y: top),
                              controlPoint: CGPoint(x: x, y: top + h * 0.06))
            ctx.addPath(pole.cgPath)
            ctx.strokePath()

            // Chụp đèn.
            ctx.setLineWidth(max(1.0, h * 0.005))
            let shade = UIBezierPath()
            shade.move(to: CGPoint(x: x + head * 0.30, y: top - head * 0.10))
            shade.addQuadCurve(to: CGPoint(x: x + head * 1.05, y: top - head * 0.02),
                               controlPoint: CGPoint(x: x + head * 0.70, y: top - head * 0.24))
            ctx.addPath(shade.cgPath)
            ctx.strokePath()

            // Quầng sáng nhỏ.
            ctx.setFillColor(TCB.sun.withAlphaComponent(0.55).cgColor)
            ctx.fillEllipse(in: CGRect(x: x + head * 0.86,
                                       y: top - head * 0.10,
                                       width: head * 0.34,
                                       height: head * 0.34))
        }
        ctx.restoreGState()
    }

    // MARK: Car

    private func drawCar(in ctx: CGContext, w: CGFloat, h: CGFloat) {
        let cx = w * 0.50
        let cy = h * 0.80
        let carW = w * 0.155
        let carH = carW * 0.40

        ctx.saveGState()

        // Vệt tốc độ phía sau.
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.35).cgColor)
        ctx.setLineWidth(max(1.0, h * 0.0035))
        ctx.setLineCap(.round)
        for i in 0..<3 {
            let y = cy - carH * 0.05 + CGFloat(i) * carH * 0.22
            let line = UIBezierPath()
            line.move(to: CGPoint(x: cx - carW * (1.05 + CGFloat(i) * 0.14), y: y))
            line.addLine(to: CGPoint(x: cx - carW * (0.55 + CGFloat(i) * 0.05), y: y))
            ctx.addPath(line.cgPath)
            ctx.strokePath()
        }

        // Thân xe.
        let body = UIBezierPath(roundedRect: CGRect(x: cx - carW * 0.5,
                                                    y: cy - carH * 0.45,
                                                    width: carW,
                                                    height: carH),
                                cornerRadius: carH * 0.32)
        ctx.setFillColor(UIColor(red: 0x9E/255.0, green: 0x2B/255.0, blue: 0x22/255.0, alpha: 1.0).cgColor)
        ctx.addPath(body.cgPath)
        ctx.fillPath()

        // Cabin.
        let cabin = UIBezierPath(roundedRect: CGRect(x: cx - carW * 0.24,
                                                     y: cy - carH * 0.82,
                                                     width: carW * 0.52,
                                                     height: carH * 0.46),
                                 cornerRadius: carH * 0.18)
        ctx.setFillColor(UIColor(red: 0xF6/255.0, green: 0xE6/255.0, blue: 0xD2/255.0, alpha: 1.0).cgColor)
        ctx.addPath(cabin.cgPath)
        ctx.fillPath()

        // Kính.
        let glass = UIBezierPath(roundedRect: CGRect(x: cx - carW * 0.20,
                                                     y: cy - carH * 0.76,
                                                     width: carW * 0.44,
                                                     height: carH * 0.30),
                                 cornerRadius: carH * 0.10)
        ctx.setFillColor(UIColor(red: 0x8A/255.0, green: 0x4B/255.0, blue: 0x3C/255.0, alpha: 0.85).cgColor)
        ctx.addPath(glass.cgPath)
        ctx.fillPath()

        // Bánh.
        ctx.setFillColor(UIColor(red: 0x5B/255.0, green: 0x1A/255.0, blue: 0x16/255.0, alpha: 1.0).cgColor)
        for dx in [-carW * 0.30, carW * 0.30] {
            let r = carH * 0.22
            ctx.fillEllipse(in: CGRect(x: cx + dx - r,
                                       y: cy + carH * 0.20 - r,
                                       width: r * 2,
                                       height: r * 2))
        }

        ctx.restoreGState()
    }
}
