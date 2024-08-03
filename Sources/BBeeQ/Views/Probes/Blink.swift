import SwiftUI

struct BlinkViewModifier: ViewModifier {
  let duration: Double
  @State private var opacity = 1.0

  func body(content: Content) -> some View {
    content
      .opacity(opacity)
      .animation(.easeOut(duration: duration).repeatForever(), value: opacity)
      .onAppear {
        withAnimation {
          opacity = 0.3
        }
      }
  }
}

extension View {
  func blinking(duration: Double = 0.75) -> some View {
    modifier(BlinkViewModifier(duration: duration))
  }
}
