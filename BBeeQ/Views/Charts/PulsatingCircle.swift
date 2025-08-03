import SwiftUI

struct PulsatingCircle: View {
  private var animate = true
  private var fill = Color.red

  @State private var isAnimating = false

  var body: some View {
    VStack {
      ZStack {
        Circle().fill(fill).strokeBorder(.white, lineWidth: 2)
          .frame(width: 12, height: 12)
        Circle().fill(fill.opacity(0.25)).frame(width: 40, height: 40)
          .scaleEffect(self.isAnimating ? 1 : 0)
        Circle().fill(fill.opacity(0.35)).frame(width: 30, height: 30)
          .scaleEffect(self.isAnimating ? 1 : 0)
        Circle().fill(fill.opacity(0.45)).frame(width: 15, height: 15)
          .scaleEffect(self.isAnimating ? 1 : 0)
      }
      .animation(
        .easeInOut(duration: 1).repeatForever(autoreverses: true),
        value: isAnimating
      )
      .onChange(of: animate, initial: true) {
        isAnimating = animate
      }
    }
  }
}

extension PulsatingCircle {
  func animate(_ animate: Bool = true) -> Self {
    var copy = self
    copy.animate = animate
    return copy
  }

  func fill(_ color: Color) -> Self {
    var copy = self
    copy.fill = color
    return copy
  }
}

#Preview {
  VStack {
    PulsatingCircle().animate()
    PulsatingCircle().fill(.blue)
    PulsatingCircle().animate(false)
  }
}
