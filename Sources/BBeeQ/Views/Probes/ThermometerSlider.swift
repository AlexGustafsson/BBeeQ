import SwiftUI

struct ThermometerSlider: View {
  var current: Double
  @Binding var target: Double

  @State var minValue = Int(0)
  @State var maxValue = Int(300)

  @State private var representedCurrent: Double = 0
  @State private var held = false

  private let trackHeight: CGFloat = 8
  private let thumbRadius: CGFloat = 10

  var body: some View {
    GeometryReader { geometry in
      //--Container ZStack
      ZStack(alignment: .leading) {
        //--Track
        RoundedRectangle(cornerRadius: 4)
          .fill(.red.opacity(0.5))
          .frame(width: geometry.size.width, height: trackHeight)
          .onTapGesture { location in
            withAnimation {
              target =
                Double(
                  (location.x / geometry.size.width)
                    * CGFloat(maxValue - minValue)) + Double(minValue)
            }
          }

        //--Tinted track
        let currentWidth =
          geometry.size.width * CGFloat(representedCurrent)
          / CGFloat(maxValue - minValue)
        RoundedRectangle(cornerRadius: 4)
          .fill(.red)
          .frame(width: currentWidth, height: trackHeight)
          .allowsHitTesting(false)
          .onChange(of: current) {
            withAnimation {
              representedCurrent = current
            }
          }

        //--Thumb
        Circle()
          .fill(.white)
          .fill(.gray.opacity(held ? 0.1 : 0.0))
          .frame(width: thumbRadius * 2)
          .shadow(radius: 1)

          .offset(
            x: CGFloat(
              CGFloat(target) / CGFloat(maxValue) * geometry.size.width
                - thumbRadius)
          )

          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { gesture in
                held = true
                updateValue(with: gesture, in: geometry)
              }
              .onEnded { _ in
                held = false
              }
          )

      }

    }
    .frame(height: 2 * thumbRadius)
    .padding([.leading, .trailing], thumbRadius)
  }

  private func updateValue(
    with gesture: DragGesture.Value, in geometry: GeometryProxy
  ) {
    let dragPortion = gesture.location.x / geometry.size.width
    let newValue = Int(
      dragPortion * CGFloat(maxValue - minValue) + CGFloat(minValue))
    target = Double(min(max(newValue, minValue), maxValue))
  }
}
