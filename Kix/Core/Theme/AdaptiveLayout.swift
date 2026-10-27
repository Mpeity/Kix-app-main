import SwiftUI

enum AdaptiveLayout {
    static let maxContentWidth: CGFloat = 600
    static let maxButtonWidth: CGFloat = 400
    static let wideBreakpoint: CGFloat = 700
    static let maxCardWidth: CGFloat = 500

    static func columnCount(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 2 : 1
    }

    static func favoritesColumnCount(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 3 : 2
    }
}

struct AdaptiveContent<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: sizeClass == .regular
                   ? AdaptiveLayout.maxContentWidth
                   : .infinity)
            .frame(maxWidth: .infinity)
    }
}
