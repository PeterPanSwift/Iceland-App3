import Foundation
import Observation

@Observable
final class FavoritesStore {
    private static let key = "favoriteAttractions"
    private(set) var ids: [String]

    init() {
        if ProcessInfo.processInfo.arguments.contains("-resetFavorites") {
            UserDefaults.standard.removeObject(forKey: Self.key)
        }
        ids = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
    }

    func contains(_ attraction: Attraction) -> Bool {
        ids.contains(attraction.id)
    }

    func toggle(_ attraction: Attraction) {
        if let index = ids.firstIndex(of: attraction.id) {
            ids.remove(at: index)
        } else {
            ids.append(attraction.id)
        }
        UserDefaults.standard.set(ids, forKey: Self.key)
    }

    var attractions: [Attraction] {
        ids.compactMap { id in Attraction.all.first { $0.id == id } }
    }
}
