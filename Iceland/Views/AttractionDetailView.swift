import MapKit
import SwiftUI

struct AttractionDetailView: View {
    let attraction: Attraction
    @Environment(FavoritesStore.self) private var favorites

    private let headerHeight: CGFloat = 420

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                content
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous))
                    .offset(y: -28)
                    .padding(.bottom, -28)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let isFavorite = favorites.contains(attraction)
                Button {
                    withAnimation(.bouncy) { favorites.toggle(attraction) }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? Color.lava : Color.primary)
                        .symbolEffect(.bounce, value: isFavorite)
                }
                .accessibilityLabel(isFavorite ? "取消收藏" : "加入收藏")
                .accessibilityIdentifier("favoriteButton")
            }
        }
    }

    private var header: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView).minY
            PhotoView(name: attraction.id)
                .frame(width: geo.size.width, height: headerHeight + max(0, minY))
                .overlay {
                    LinearGradient(colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.55)],
                                   startPoint: .top, endPoint: .bottom)
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(attraction.localName.uppercased())
                            .font(.caption.weight(.bold))
                            .tracking(2)
                            .foregroundStyle(Color.aurora)
                        Text(attraction.name)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
                .offset(y: -max(0, minY))
        }
        .frame(height: headerHeight)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(attraction.tagline)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.glacier)
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(attraction.region)
                    Text("·")
                    Image(systemName: "star.fill").foregroundStyle(.orange)
                    Text(attraction.rating.formatted(.number.precision(.fractionLength(1))))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                FactTile(symbol: "calendar", title: "最佳季節", value: attraction.bestSeason)
                FactTile(symbol: "clock", title: "建議停留", value: attraction.duration)
                FactTile(symbol: "car.fill", title: "距首都",
                         value: attraction.distance == 0 ? "市中心" : "\(attraction.distance) km")
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "景點介紹")
                Text(attraction.summary)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundStyle(Color.primary.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(text: "必看亮點")
                ForEach(attraction.highlights, id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.aurora)
                        Text(item)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "位置")
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: attraction.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 1.2)))) {
                    Marker(attraction.name, systemImage: attraction.category.symbol, coordinate: attraction.coordinate)
                        .tint(Color.glacier)
                }
                .mapStyle(.standard(elevation: .realistic))
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .allowsHitTesting(false)
            }

            if let credit = PhotoCredit.credit(for: attraction.id) {
                Text("照片：\(credit.artist)／\(credit.license)，來源 Wikimedia Commons")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private struct FactTile: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.glacier)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .padding(.vertical, 6)
        .background(Color.glacier.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
