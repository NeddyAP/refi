# refi

Refi is a Flutter-based mobile application designed to help users discover, track, and manage movies. It leverages The Movie Database (TMDB) API to provide a rich movie browsing experience.

## Features

*   **Discover Movies**: Browse various categories like Popular, Top Rated, Now Playing, and Upcoming movies.
*   **Trending Content**: Stay updated with movies and TV shows trending today and this week.
*   **Explore**:
    *   Search for movies by title.
    *   Advanced search with filters for genres, release year, rating, language, runtime, and more.
    *   Browse movies by genre.
*   **Movie Details**: View comprehensive details for each movie, including:
    *   Synopsis, rating, release date, runtime.
    *   Trailers and video clips.
    *   Top-billed cast and crew information.
    *   User reviews.
    *   Image galleries (backdrops and posters).
*   **TMDB Account Integration**:
    *   Sign in with your TMDB account.
    *   Manage your favorite movies and watchlist, synced with your TMDB account.
    *   Guest mode available for browsing without an account (local favorites/watchlist).
*   **User Profile**:
    *   View TMDB account information.
    *   Manage app settings like theme (Dark/Light) and language.
*   **Localization**: Supports English and Indonesian languages.
*   **Responsive UI**: Designed for a seamless experience on mobile devices.

## Tech Stack & Architecture

*   **Framework**: Flutter
*   **State Management**: Provider
*   **Navigation**: GoRouter
*   **HTTP Client**: Dio (for API communication)
*   **Local Storage**: SharedPreferences (for user preferences and local auth state)
*   **API**: The Movie Database (TMDB) API
*   **Localization**: flutter_localizations with ARB files

The project follows a feature-first directory structure, promoting modularity and separation of concerns.

## Setup Instructions

### Prerequisites

*   Flutter SDK (version `^3.8.0` or compatible)
*   An IDE like Android Studio or VS Code with Flutter plugins.
*   A TMDB API Key. You can get one from [the TMDB website](https://www.themoviedb.org/settings/api).

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://neddyap/refi.git
    cd refi
    ```

2.  **Create and configure the `.env` file:**
    *   In the root of the project, create a file named `.env`.
    *   Add your TMDB API Key to this file:
        ```env
        TMDB_API_KEY=YOUR_TMDB_API_KEY_HERE
        ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```
    Select your desired emulator or physical device.

## Folder Structure Overview

The `lib` directory is organized as follows:

*   `lib/core`: Contains core functionalities like API client, constants, router, and theme.
*   `lib/features`: Contains individual application features (e.g., `auth`, `home`, `explore`, `movie_details`, `profile`, `favorites`). Each feature typically has its own `models`, `providers`, `repositories`, `screens`, `services`, and `widgets`.
*   `lib/shared`: Contains widgets, models, and providers that are shared across multiple features.
*   `lib/l10n`: Localization files (`.arb`) and generated localizations.
*   `lib/main.dart`: The main entry point of the application.

## API Integration

This application uses [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs) to fetch movie and TV show data. An API key is required and must be configured in the `.env` file.

## Localization

The app supports internationalization (i18n) and localization (l10n) using Flutter's built-in `flutter_localizations` package and ARB files.
*   Localization strings are stored in `lib/l10n/app_en.arb` (English) and `lib/l10n/app_id.arb` (Indonesian).
*   The `l10n.yaml` file configures the code generation for localizations.
*   To add or update translations, modify the ARB files and run `flutter gen-l10n`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for bugs, feature requests, or improvements.
