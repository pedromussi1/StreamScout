import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MovieSearchViewModel()
    @State private var selectedMovie: Movie?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if !viewModel.hasSearched && !viewModel.isLoading {
                        welcomeView
                    }

                    if let error = viewModel.errorMessage {
                        errorView(error)
                    }

                    if viewModel.isLoading && viewModel.movies.isEmpty {
                        ProgressView()
                            .padding(.top, 60)
                    } else if viewModel.hasSearched && viewModel.movies.isEmpty && !viewModel.isLoading {
                        noResultsView
                    } else {
                        movieGrid
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("StreamScout")
            .searchable(text: $viewModel.searchText, prompt: "Search for a movie...")
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(spacing: 12) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Search for a movie to see\nwhere it's streaming")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .foregroundStyle(.red)
            Button("Try Again") {
                let q = viewModel.searchText
                viewModel.searchText = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.searchText = q
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 40)
    }

    // MARK: - No Results

    private var noResultsView: some View {
        Text("No movies found. Try a different search.")
            .foregroundStyle(.secondary)
            .padding(.top, 60)
    }

    // MARK: - Movie Grid

    private var movieGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.movies) { movie in
                MovieCard(movie: movie)
                    .onTapGesture { selectedMovie = movie }
                    .onAppear { viewModel.loadMoreIfNeeded(currentMovie: movie) }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

// MARK: - Movie Card

private struct MovieCard: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Poster
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                case .failure:
                    posterPlaceholder
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(2/3, contentMode: .fill)
                @unknown default:
                    posterPlaceholder
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Info
            Text(movie.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)

            HStack(spacing: 4) {
                Text(movie.year)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if movie.voteCount > 0 {
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.quaternary)
            .aspectRatio(2/3, contentMode: .fill)
            .overlay {
                Image(systemName: "film")
                    .font(.title)
                    .foregroundStyle(.tertiary)
            }
    }
}

#Preview {
    ContentView()
}
