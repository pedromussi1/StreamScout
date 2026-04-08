import Foundation
import Combine

@MainActor
final class MovieSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasSearched = false

    private var currentPage = 1
    private var totalPages = 1
    private var currentTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let service = TMDBService.shared

    var hasMorePages: Bool { currentPage < totalPages }

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        currentTask?.cancel()

        guard query.trimmingCharacters(in: .whitespaces).count >= 2 else {
            movies = []
            errorMessage = nil
            if query.isEmpty { hasSearched = false }
            return
        }

        hasSearched = true
        isLoading = true
        errorMessage = nil
        currentPage = 1
        movies = []

        currentTask = Task {
            do {
                let response = try await service.searchMovies(query: query, page: 1)
                guard !Task.isCancelled else { return }
                movies = response.results
                totalPages = response.totalPages
                isLoading = false
            } catch is CancellationError {
                // Silently ignore — new search replaced this one
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Something went wrong. Please try again."
                isLoading = false
            }
        }
    }

    func loadMoreIfNeeded(currentMovie: Movie) {
        guard let last = movies.last, last.id == currentMovie.id,
              hasMorePages, !isLoading else { return }

        isLoading = true
        let nextPage = currentPage + 1
        let query = searchText

        currentTask = Task {
            do {
                let response = try await service.searchMovies(query: query, page: nextPage)
                guard !Task.isCancelled else { return }
                movies.append(contentsOf: response.results)
                currentPage = nextPage
                totalPages = response.totalPages
                isLoading = false
            } catch is CancellationError {
                // Ignored
            } catch {
                guard !Task.isCancelled else { return }
                isLoading = false
            }
        }
    }
}
