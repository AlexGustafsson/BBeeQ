import SwiftUI

// A simple list view for selecting multiple values in order to get a consistent
// behavior cross-platform. iOS doesn't work at all within a form.

struct Select<Data, ID, RowContent>: View where Data: RandomAccessCollection, ID : Hashable, RowContent: View {
  public var data: Data
  public var id: KeyPath<Data.Element, ID>
  @Binding public var selection: Set<ID>
  @ViewBuilder public var content: (Data.Element, Bool) -> RowContent

  var body: some View {
    List(data, id: id) { item in
      content(item, selection.contains(item[keyPath: id])).onTapGesture {
        if selection.contains(item[keyPath: id]) {
          selection.remove(item[keyPath: id])
        } else {
          selection.insert(item[keyPath: id])
        }
      }
    }
  }
}
