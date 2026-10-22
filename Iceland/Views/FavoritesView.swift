import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        NavigationStack {
            Group {
                if favorites.attractions.isEmpty {
                    ContentUnavailableView {
                        Label("還沒有收藏的景點", systemImage: "heart")
                    } description: {
                        Text("在景點頁面點右上角的愛心，就能把想去的地方加到這裡，規劃你的冰島行程。")
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            summary
                            LazyVStack(spacing: 20) {
                                ForEach(favorites.attractions) { attraction in
                                    NavigationLink(value: attraction) {
                                        AttractionCard(attraction: attraction)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(20)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("我的收藏")
            .navigationDestination(for: Attraction.self) { attraction in
                AttractionDetailView(attraction: attraction)
            }
        }
    }

    private var summary: some View {
        let list = favorites.attractions
        let hours = list.count * 2
        return HStack(spacing: 16) {
            Image(systemName: "map.circle.fill")
                .font(.system(size: 42))
                .foregroundStyle(Color.white, Color.glacier)
            VStack(alignment: .leading, spacing: 4) {
                Text("你的冰島清單")
                    .font(.headline)
                Text("\(list.count) 個景點 · 約需 \(hours) 小時遊覽")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.glacier.opacity(0.18), Color.aurora.opacity(0.18)],
                           startPoint: .leading, endPoint: .trailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
