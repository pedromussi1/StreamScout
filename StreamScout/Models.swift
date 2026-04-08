import Foundation

struct MovieSearchResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let overview: String?

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "\(Config.imageBaseURL)/\(Config.posterSize)\(path)")
    }

    var year: String {
        guard let date = releaseDate, date.count >= 4 else { return "N/A" }
        return String(date.prefix(4))
    }
}

struct WatchProvidersResponse: Codable {
    let id: Int
    let results: [String: CountryProviders]

    var us: CountryProviders? { results["US"] }
}

struct CountryProviders: Codable {
    let link: String?
    let flatrate: [Provider]?
    let free: [Provider]?
    let rent: [Provider]?
    let buy: [Provider]?
}

struct Provider: Codable, Identifiable, Hashable {
    let providerId: Int
    let providerName: String
    let logoPath: String

    var id: Int { providerId }

    var logoURL: URL? {
        URL(string: "\(Config.imageBaseURL)/\(Config.logoSize)\(logoPath)")
    }
}
