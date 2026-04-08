import Foundation

final class TMDBService {
    static let shared = TMDBService()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    func searchMovies(query: String, page: Int = 1) async throws -> MovieSearchResponse {
        var components = URLComponents(string: "\(Config.tmdbBaseURL)/search/movie")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(Config.tmdbAPIKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(MovieSearchResponse.self, from: data)
    }

    func getWatchProviders(movieId: Int) async throws -> WatchProvidersResponse {
        let url = URL(string: "\(Config.tmdbBaseURL)/movie/\(movieId)/watch/providers")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.tmdbAPIKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(WatchProvidersResponse.self, from: data)
    }
}
