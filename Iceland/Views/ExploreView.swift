import SwiftUI

struct ExploreView: View {
    @State private var category: Category?

    private var filtered: [Attraction] {
        guard let category else { return Attraction.all }
        return Attraction.all.filter { $0.category == category }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("火與冰交織的國度，\(Attraction.all.count) 個必訪絕景")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)

                    FeaturedCarousel(items: Attraction.featured)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(text: "依主題探索")
                            .padding(.horizontal, 20)
                        categoryChips
                    }

                    LazyVStack(spacing: 20) {
                        ForEach(filtered) { attraction in
                            NavigationLink(value: attraction) {
                                AttractionCard(attraction: attraction)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("card-\(attraction.id)")
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.snappy, value: category)
                }
                .padding(.bottom, 24)
            }
            .accessibilityIdentifier("exploreScroll")
            .background(Color(.systemGroupedBackground))
            .navigationTitle("探索冰島")
            .navigationDestination(for: Attraction.self) { attraction in
                AttractionDetailView(attraction: attraction)
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "全部", symbol: "sparkles", isSelected: category == nil) {
                    category = nil
                }
                .accessibilityIdentifier("chip-all")
                ForEach(Category.allCases) { item in
                    CategoryChip(title: item.rawValue, symbol: item.symbol, isSelected: category == item) {
                        category = item
                    }
                    .accessibilityIdentifier("chip-\(item.identifier)")
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.glacier : Color(.secondarySystemGroupedBackground), in: Capsule())
                .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct FeaturedCarousel: View {
    let items: [Attraction]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(items) { attraction in
                    NavigationLink(value: attraction) {
                        FeaturedCard(attraction: attraction)
                    }
                    .buttonStyle(.plain)
                    .containerRelativeFrame(.horizontal) { width, _ in width - 48 }
                    .accessibilityIdentifier("featured-\(attraction.id)")
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 440)
        .accessibilityIdentifier("featuredCarousel")
    }
}

private struct FeaturedCard: View {
    let attraction: Attraction

    var body: some View {
        PhotoView(name: attraction.id)
            .overlay {
                LinearGradient(colors: [.clear, .clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .topLeading) {
                Label(attraction.region, systemImage: "mappin.and.ellipse")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(attraction.localName.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(Color.aurora)
                    Text(attraction.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text(attraction.tagline)
                        .font(.subheadline)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(22)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
    }
}

struct AttractionCard: View {
    let attraction: Attraction
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PhotoView(name: attraction.id)
                .frame(height: 200)
                .overlay(alignment: .topTrailing) {
                    if favorites.contains(attraction) {
                        Image(systemName: "heart.fill")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(9)
                            .background(Color.lava, in: Circle())
                            .padding(12)
                    }
                }
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(attraction.name)
                        .font(.headline)
                    Text(attraction.localName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        Label(attraction.category.rawValue, systemImage: attraction.category.symbol)
                        Label(attraction.distance == 0 ? "市中心" : "\(attraction.distance) km", systemImage: "car.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.glacier)
                    .padding(.top, 4)
                }
                Spacer()
                Label(attraction.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            .padding(16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}
