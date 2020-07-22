import SwiftUI

struct AddDashedCardStyle: ViewModifier {
    var notchSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .overlay(
                NotchedRoundedRectangle(notchSize: notchSize, cornerRadius: 16)
                    .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
                    .foregroundColor(Color.white)
                    .padding(5)
        )
            .clipShape(NotchedRoundedRectangle(notchSize: notchSize, cornerRadius: 20))
            .modifier(Shadow())
    }
}

struct NotchedRoundedRectangle: Shape {
    let notchSize: CGSize
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        if notchSize == .zero {
            let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
            path.addRoundedRect(in: rect, cornerSize: cornerSize)
            return path
        }

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - notchSize.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + notchSize.height),
            control: CGPoint(x: rect.maxX - notchSize.width, y: rect.minY + notchSize.height)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )

        path.closeSubpath()

        return path
    }
}
