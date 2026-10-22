import SwiftUI

enum AppTab: Hashable {
    case explore, map, favorites, info
}

struct ContentView: View {
    @State private var selection: AppTab = .explore

    var body: some View {
        TabView(selection: $selection) {
            ExploreView()
                .tabItem { Label("探索", systemImage: "binoculars.fill") }
                .tag(AppTab.explore)
            MapExploreView()
                .tabItem { Label("地圖", systemImage: "map.fill") }
                .tag(AppTab.map)
            FavoritesView()
                .tabItem { Label("收藏", systemImage: "heart.fill") }
                .tag(AppTab.favorites)
            InfoView()
                .tabItem { Label("認識冰島", systemImage: "info.circle.fill") }
                .tag(AppTab.info)
        }
        .tint(.glacier)
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
}
