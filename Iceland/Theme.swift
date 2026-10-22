import SwiftUI

extension Color {
    static let glacier = Color(red: 0.20, green: 0.56, blue: 0.80)
    static let aurora = Color(red: 0.24, green: 0.82, blue: 0.60)
    static let fjord = Color(red: 0.05, green: 0.12, blue: 0.24)
    static let lava = Color(red: 0.93, green: 0.42, blue: 0.24)
}

/// A photo that fills whatever frame it is given without affecting layout.
struct PhotoView: View {
    let name: String

    var body: some View {
        Color.fjord.opacity(0.15)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(.primary)
    }
}
