import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    @State private var providers: CountryProviders?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    movieHeader
                    providerContent
                    attributionFooter
                }
                .padding()
            }
            .navigationTitle("Where to Watch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task { await loadProviders() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Movie Header

    private var movieHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: movie.posterURL) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "film")
                                .foregroundStyle(.tertiary)
                        }
                }
            }
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.title3.weight(.semibold))

                HStack(spacing: 4) {
                    Text(movie.year)
                    if movie.voteCount > 0 {
                        Text("·")
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .padding(.top, 2)
                }
            }
        }
    }

    // MARK: - Provider Content

    @ViewBuilder
    private var providerContent: some View {
        if isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text("Loading streaming info...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else if let error = errorMessage {
            Text(error)
                .font(.subheadline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        } else if let providers, hasAnyProviders(providers) {
            VStack(alignment: .leading, spacing: 16) {
                providerSection(title: "Stream", providers: providers.flatrate, accent: true)
                providerSection(title: "Free", providers: providers.free, accent: true)
                providerSection(title: "Rent", providers: providers.rent, accent: false)
                providerSection(title: "Buy", providers: providers.buy, accent: false)
            }
        } else {
            Text("Not currently available on any US streaming service.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }

    // MARK: - Provider Section

    @ViewBuilder
    private func providerSection(title: String, providers: [Provider]?, accent: Bool) -> some View {
        if let providers, !providers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(1)
                    .foregroundStyle(accent ? .green : .secondary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(providers) { provider in
                        VStack(spacing: 4) {
                            AsyncImage(url: provider.logoURL) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.quaternary)
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            Text(provider.providerName)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 70)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Attribution Footer

    private var attributionFooter: some View {
        VStack(spacing: 4) {
            Divider()
                .padding(.top, 8)
            Text("Movie data provided by TMDB")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Text("Streaming availability powered by JustWatch")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            if let link = providers?.link, let url = URL(string: link) {
                Link("View on JustWatch →", destination: url)
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func hasAnyProviders(_ p: CountryProviders) -> Bool {
        let hasFlat = !(p.flatrate ?? []).isEmpty
        let hasFree = !(p.free ?? []).isEmpty
        let hasRent = !(p.rent ?? []).isEmpty
        let hasBuy = !(p.buy ?? []).isEmpty
        return hasFlat || hasFree || hasRent || hasBuy
    }

    private func loadProviders() async {
        do {
            let response = try await TMDBService.shared.getWatchProviders(movieId: movie.id)
            providers = response.us
            isLoading = false
        } catch {
            errorMessage = "Could not load streaming info."
            isLoading = false
        }
    }
}
