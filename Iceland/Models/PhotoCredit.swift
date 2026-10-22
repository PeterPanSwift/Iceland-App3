import Foundation

struct PhotoCredit: Decodable, Identifiable {
    let image: String
    let title: String
    let artist: String
    let license: String
    let source: String

    var id: String { image }

    static let all: [PhotoCredit] = {
        guard let url = Bundle.main.url(forResource: "credits", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let credits = try? JSONDecoder().decode([PhotoCredit].self, from: data)
        else { return [] }
        return credits
    }()

    static func credit(for image: String) -> PhotoCredit? {
        all.first { $0.image == image }
    }
}
