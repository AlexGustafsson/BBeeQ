import SwiftUI

struct PulsatingCircle: View {
  @State var animate = false

  @State private var isAnimating = false

  var body: some View {
    VStack {
      ZStack {
        Circle().fill(.red).strokeBorder(.white, lineWidth: 2)
          .frame(width: 12, height: 12)
        Circle().fill(.red.opacity(0.25)).frame(width: 40, height: 40)
          .scaleEffect(self.isAnimating ? 1 : 0)
        Circle().fill(.red.opacity(0.35)).frame(width: 30, height: 30)
          .scaleEffect(self.isAnimating ? 1 : 0)
        Circle().fill(.red.opacity(0.45)).frame(width: 15, height: 15)
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

#Preview {
  VStack {
    PulsatingCircle(animate: true)
    PulsatingCircle(animate: false)
  }
}
