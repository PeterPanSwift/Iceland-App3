import SwiftUI

@main
struct IcelandApp: App {
    @State private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favorites)
        }
    }
}
