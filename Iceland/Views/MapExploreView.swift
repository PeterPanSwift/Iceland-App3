import MapKit
import SwiftUI

struct MapExploreView: View {
    private static let overview = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 64.75, longitude: -19.0),
        span: MKCoordinateSpan(latitudeDelta: 4.6, longitudeDelta: 11.0)))

    @State private var position = MapExploreView.overview
    @State private var selected: Attraction?

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                ForEach(Attraction.all) { attraction in
                    Annotation(attraction.name, coordinate: attraction.coordinate) {
                        MapPin(attraction: attraction, isSelected: selected == attraction)
                            .onTapGesture { select(attraction) }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .safeAreaInset(edge: .bottom) {
                cardStrip
            }
            .navigationTitle("景點地圖")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if selected != nil {
                        Button("全島") {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                selected = nil
                                position = Self.overview
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Attraction.self) { attraction in
                AttractionDetailView(attraction: attraction)
            }
        }
    }

    private func select(_ attraction: Attraction) {
        withAnimation(.easeInOut(duration: 1.6)) {
            selected = attraction
            position = .camera(MapCamera(centerCoordinate: attraction.coordinate,
                                         distance: 30_000, heading: 20, pitch: 55))
        }
    }

    private var cardStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Attraction.all) { attraction in
                    MapCard(attraction: attraction, isSelected: selected == attraction) {
                        select(attraction)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .accessibilityIdentifier("mapCardStrip")
    }
}

private struct MapPin: View {
    let attraction: Attraction
    let isSelected: Bool

    var body: some View {
        PhotoView(name: attraction.id)
            .frame(width: isSelected ? 56 : 36, height: isSelected ? 56 : 36)
            .clipShape(Circle())
            .overlay(Circle().stroke(isSelected ? Color.aurora : .white, lineWidth: 3))
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .animation(.bouncy, value: isSelected)
    }
}

private struct MapCard: View {
    let attraction: Attraction
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            PhotoView(name: attraction.id)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(attraction.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(attraction.region)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isSelected {
                    NavigationLink(value: attraction) {
                        Label("查看介紹", systemImage: "chevron.right.circle.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .accessibilityIdentifier("mapDetail-\(attraction.id)")
                } else {
                    Label(attraction.distance == 0 ? "市中心" : "\(attraction.distance) km", systemImage: "car.fill")
                        .font(.caption)
                        .foregroundStyle(Color.glacier)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(width: 236)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(isSelected ? Color.glacier : .clear, lineWidth: 2))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("mapcard-\(attraction.id)")
    }
}
