# StreamScout iOS

Search any movie and instantly see which US streaming services have it.

## Features

- Search 800,000+ movies via TMDB
- See streaming availability grouped by Stream, Free, Rent, and Buy
- Provider logos and names displayed as badges
- Infinite scroll pagination for search results
- Dark theme throughout

## Setup

1. Clone the repo
2. Get a free TMDB API Read Access Token at [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api)
3. Copy `StreamScout/Config.swift.example` to `StreamScout/Config.swift`
4. Replace `YOUR_TMDB_BEARER_TOKEN_HERE` with your token
5. Open `StreamScout.xcodeproj` in Xcode
6. Build and run (iOS 17.0+)

## Tech Stack

- SwiftUI
- async/await + URLSession
- Combine (debounce only)
- Zero external dependencies

## Credits

- Movie data provided by [TMDB](https://www.themoviedb.org/)
- Streaming availability powered by [JustWatch](https://www.justwatch.com/)

## Web Version

A web version of StreamScout is also available at [stream-scout-five.vercel.app](https://stream-scout-five.vercel.app) — source at [pedromussi1/stream-scout](https://github.com/pedromussi1/stream-scout).
