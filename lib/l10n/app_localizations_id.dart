// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Refi';

  @override
  String get profileScreenTitle => 'Profil';

  @override
  String get signOut => 'Keluar';

  @override
  String get signOutDialogTitle => 'Keluar';

  @override
  String get signOutDialogContent => 'Apakah Anda yakin ingin keluar?';

  @override
  String get cancel => 'Batal';

  @override
  String get guestUser => 'Pengguna Tamu';

  @override
  String get browsingAsGuest => 'Menjelajah sebagai tamu';

  @override
  String get tmdbUser => 'Pengguna TMDB';

  @override
  String get guestSession => 'Sesi Tamu';

  @override
  String get tmdbAccount => 'Akun TMDB';

  @override
  String get joined => 'Bergabung';

  @override
  String get language => 'Bahasa';

  @override
  String get region => 'Wilayah';

  @override
  String get adult => 'Dewasa';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get viewAccountInfo => 'Lihat Info Akun';

  @override
  String get signIn => 'Masuk';

  @override
  String get signUpAtTmdb => 'Daftar di TMDB';

  @override
  String couldNotOpen(String url) {
    return 'Tidak dapat membuka $url';
  }

  @override
  String get settings => 'Pengaturan';

  @override
  String get appLanguage => 'Bahasa Aplikasi';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get darkThemeEnabled => 'Tema gelap diaktifkan';

  @override
  String get lightThemeEnabled => 'Tema terang diaktifkan';

  @override
  String get about => 'Tentang';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfService => 'Syarat Layanan';

  @override
  String get helpAndSupport => 'Bantuan & Dukungan';

  @override
  String get guest => 'Tamu';

  @override
  String hiUserGreeting(String userName) {
    return 'Hai, $userName!';
  }

  @override
  String get profileAndSettings => 'Profil & Pengaturan';

  @override
  String get whatMovieDoYouWantToSee => 'film apa yang ingin Anda tonton?';

  @override
  String get findTheMovieYouLike => 'temukan film yang Anda suka';

  @override
  String get frequentlyVisited => 'Sering Dikunjungi';

  @override
  String get trendingToday => 'Trending Hari Ini';

  @override
  String get trendingThisWeek => 'Trending Minggu Ini';

  @override
  String get latestTrailers => 'Trailer Terbaru';

  @override
  String get popularOnStreaming => 'Populer di Streaming';

  @override
  String get popularOnTv => 'Populer di TV';

  @override
  String get availableForRent => 'Tersedia untuk Disewa';

  @override
  String get currentlyInTheaters => 'Sedang di Bioskop';

  @override
  String get family => 'Keluarga';

  @override
  String get loadingMovieDetails => 'Memuat detail film...';

  @override
  String get addedToFavorites => 'Ditambahkan ke favorit';

  @override
  String get removedFromFavorites => 'Dihapus dari favorit';

  @override
  String get removeFromFavorites => 'Hapus dari favorit';

  @override
  String get addToFavorites => 'Tambah ke favorit';

  @override
  String get addedToWatchlist => 'Ditambahkan ke daftar tonton';

  @override
  String get removedFromWatchlist => 'Dihapus dari daftar tonton';

  @override
  String get removeFromWatchlist => 'Hapus dari daftar tonton';

  @override
  String get addToWatchlist => 'Tambah ke daftar tonton';

  @override
  String get noOverviewAvailable => 'Tidak ada ringkasan tersedia.';

  @override
  String get trailers => 'Trailer';

  @override
  String get topBilledCast => 'Pemeran Utama';

  @override
  String get fullCastAndCrew => 'Semua Pemeran & Kru';

  @override
  String get director => 'Sutradara';

  @override
  String get writers => 'Penulis';

  @override
  String get viewFullCastAndCrew => 'Lihat Semua Pemeran & Kru';

  @override
  String get crew => 'Kru';

  @override
  String get userReviews => 'Ulasan Pengguna';

  @override
  String viewAllReviews(int count) {
    return 'Lihat Semua Ulasan ($count)';
  }

  @override
  String allReviews(int count) {
    return 'Semua Ulasan ($count)';
  }

  @override
  String get media => 'Media';

  @override
  String get backdrops => 'Latar Belakang';

  @override
  String get posters => 'Poster';

  @override
  String imageGalleryTitle(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get exploreScreenTitle => 'Jelajahi';

  @override
  String get searchMoviesHint => 'Cari film...';

  @override
  String get advancedSearchActive => 'Pencarian lanjutan aktif';

  @override
  String get exitAdvancedSearch => 'Keluar dari pencarian lanjutan';

  @override
  String get advancedSearch => 'Pencarian lanjutan';

  @override
  String get advancedSearchTitle => 'Pencarian Lanjutan';

  @override
  String get clearFilters => 'Hapus Filter';

  @override
  String get applyFilters => 'Terapkan Filter';

  @override
  String get genres => 'Genre';

  @override
  String failedToLoadGenres(String message) {
    return 'Gagal memuat genre: $message';
  }

  @override
  String get releaseYear => 'Tahun Rilis';

  @override
  String get fromYear => 'Dari Tahun';

  @override
  String get toYear => 'Ke Tahun';

  @override
  String get ratingRange => 'Rentang Rating';

  @override
  String get minimumVoteCount => 'Jumlah Vote Minimum';

  @override
  String get originalLanguage => 'Bahasa Asli';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get anyLanguage => 'Bahasa Apa Saja';

  @override
  String get spanish => 'Spanyol';

  @override
  String get french => 'Prancis';

  @override
  String get german => 'Jerman';

  @override
  String get italian => 'Italia';

  @override
  String get japanese => 'Jepang';

  @override
  String get korean => 'Korea';

  @override
  String get chinese => 'Tiongkok';

  @override
  String get portuguese => 'Portugis';

  @override
  String get russian => 'Rusia';

  @override
  String get runtimeMinutes => 'Durasi (menit)';

  @override
  String get minRuntime => 'Durasi Min';

  @override
  String get maxRuntime => 'Durasi Maks';

  @override
  String get sortBy => 'Urutkan Berdasarkan';

  @override
  String get sortOrder => 'Urutan';

  @override
  String get popularityHighToLow => 'Popularitas (Tinggi ke Rendah)';

  @override
  String get popularityLowToHigh => 'Popularitas (Rendah ke Tinggi)';

  @override
  String get releaseDateNewest => 'Tanggal Rilis (Terbaru)';

  @override
  String get releaseDateOldest => 'Tanggal Rilis (Terlama)';

  @override
  String get ratingHighToLow => 'Rating (Tinggi ke Rendah)';

  @override
  String get ratingLowToHigh => 'Rating (Rendah ke Tinggi)';

  @override
  String get voteCountHighToLow => 'Jumlah Vote (Tinggi ke Rendah)';

  @override
  String get revenueHighToLow => 'Pendapatan (Tinggi ke Rendah)';

  @override
  String get noAdvancedSearchPerformed => 'Belum Ada Pencarian Lanjutan';

  @override
  String get configureFiltersMessage =>
      'Konfigurasi filter Anda dan cari film.';

  @override
  String get popularMovies => 'Film Populer';

  @override
  String get noMoviesAvailable => 'Tidak Ada Film Tersedia';

  @override
  String get unableToLoadPopularMovies =>
      'Tidak dapat memuat film populer saat ini.';

  @override
  String get loadingText => 'Memuat...';

  @override
  String get fetchingPopularMovies => 'Mengambil film populer untuk Anda.';

  @override
  String minRatingLabel(String rating) {
    return 'Min: $rating';
  }

  @override
  String maxRatingLabel(String rating) {
    return 'Maks: $rating';
  }

  @override
  String minimumVotesLabel(int count) {
    return 'Vote minimum: $count';
  }

  @override
  String get favoritesScreenTitle => 'Film Saya';

  @override
  String get favoritesTabTitle => 'Favorit';

  @override
  String get watchlistTabTitle => 'Daftar Tonton';

  @override
  String get loadingYourMovies => 'Memuat film Anda...';

  @override
  String get noMoviesInWatchlistTitle => 'Tidak Ada Film di Daftar Tonton';

  @override
  String get noMoviesInWatchlistMessage =>
      'Tambahkan film ke daftar tonton Anda untuk melacak film yang ingin ditonton.';

  @override
  String welcomeToApp(String appName) {
    return 'Selamat datang di $appName';
  }

  @override
  String get signInWithTmdbSubtitle =>
      'Masuk dengan akun TMDB Anda untuk menemukan film yang menakjubkan';

  @override
  String get tmdbUsername => 'Username TMDB';

  @override
  String get enterTmdbUsername => 'Masukkan username TMDB Anda';

  @override
  String get enterPassword => 'Masukkan kata sandi Anda';

  @override
  String get signInWithTmdb => 'Masuk dengan TMDB';

  @override
  String get browseModeInfo => 'Anda dapat menjelajahi film tanpa masuk';

  @override
  String get signInBenefits =>
      'Masuk untuk menilai film dan membuat daftar tonton';

  @override
  String get noTmdbAccount => 'Tidak punya akun TMDB? ';

  @override
  String get pleaseRegisterAt =>
      'Silakan daftar di https://www.themoviedb.org/signup';

  @override
  String get pleaseResetPasswordAt =>
      'Silakan reset kata sandi Anda di https://www.themoviedb.org/reset-password';

  @override
  String get dismiss => 'Tutup';

  @override
  String get enterTmdbUsernameValidation =>
      'Silakan masukkan username TMDB Anda';

  @override
  String get usernameMinLengthValidation => 'Username harus minimal 3 karakter';

  @override
  String get enterPasswordValidation => 'Silakan masukkan kata sandi Anda';

  @override
  String get passwordMinLengthValidation =>
      'Kata sandi harus minimal 6 karakter';

  @override
  String get signUpTitle => 'Daftar';

  @override
  String get createTmdbAccount => 'Buat Akun TMDB';

  @override
  String createTmdbAccountDescription(String appName) {
    return 'Untuk menggunakan semua fitur $appName, Anda memerlukan akun TMDB. Pendaftaran gratis dan hanya membutuhkan satu menit.';
  }

  @override
  String get withTmdbAccountYouCan => 'Dengan akun TMDB Anda dapat:';

  @override
  String get rateMoviesAndTvShows => 'Menilai film dan acara TV';

  @override
  String get createAndManageWatchlists => 'Membuat dan mengelola daftar tonton';

  @override
  String get markMoviesAsFavorites => 'Menandai film sebagai favorit';

  @override
  String get syncAcrossDevices => 'Sinkronisasi di semua perangkat';

  @override
  String get registerAtTmdb => 'Daftar di TMDB';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? ';

  @override
  String get continueBrowsingAsGuest => 'Lanjutkan menjelajah sebagai tamu';

  @override
  String get pleaseVisitTmdbSignup =>
      'Silakan kunjungi https://www.themoviedb.org/signup untuk mendaftar';

  @override
  String get resetPasswordTitle => 'Reset Kata Sandi';

  @override
  String get resetYourPassword => 'Reset Kata Sandi Anda';

  @override
  String get resetPasswordDescription =>
      'Untuk mereset kata sandi akun TMDB Anda, Anda perlu mengunjungi situs web TMDB.';

  @override
  String get howToResetPassword => 'Cara mereset kata sandi Anda:';

  @override
  String get visitTmdbResetPage => 'Kunjungi halaman reset kata sandi TMDB';

  @override
  String get enterUsernameOrEmail => 'Masukkan username atau email TMDB Anda';

  @override
  String get checkEmailForInstructions =>
      'Periksa email Anda untuk instruksi reset';

  @override
  String get returnToSignIn =>
      'Kembali ke sini untuk masuk dengan kata sandi baru Anda';

  @override
  String get resetPasswordAtTmdb => 'Reset Kata Sandi di TMDB';

  @override
  String get backToSignIn => 'Kembali ke Masuk';

  @override
  String get pleaseVisitTmdbResetPassword =>
      'Silakan kunjungi https://www.themoviedb.org/reset-password untuk mereset kata sandi Anda';

  @override
  String get homeLabel => 'Beranda';

  @override
  String get exploreLabel => 'Jelajahi';

  @override
  String get favoritesLabel => 'Favorit';

  @override
  String get profileLabel => 'Profil';

  @override
  String get appTitleFull => 'Refi - Rekomendasi Film';

  @override
  String get login => 'Masuk';

  @override
  String get register => 'Daftar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerButton => 'Daftar';

  @override
  String get sendResetLink => 'Kirim Tautan Reset';

  @override
  String get home => 'Beranda';

  @override
  String get explore => 'Jelajahi';

  @override
  String get favorites => 'Favorit';

  @override
  String get profile => 'Profil';

  @override
  String get nowPlaying => 'Sedang Tayang';

  @override
  String get upcoming => 'Akan Datang';

  @override
  String get topRated => 'Peringkat Teratas';

  @override
  String get popular => 'Populer';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get searchMovies => 'Cari film...';

  @override
  String get movieDetails => 'Detail Film';

  @override
  String get overview => 'Ringkasan';

  @override
  String get cast => 'Pemeran';

  @override
  String get reviews => 'Ulasan';

  @override
  String get recommendations => 'Rekomendasi';

  @override
  String get accountInformation => 'Informasi Akun';

  @override
  String get name => 'Nama';

  @override
  String get changePassword => 'Ubah Kata Sandi';

  @override
  String get privacySettings => 'Pengaturan Privasi';

  @override
  String get allowPersonalization => 'Izinkan Personalisasi';

  @override
  String get allowNotifications => 'Izinkan Notifikasi';

  @override
  String get languageSettings => 'Pengaturan Bahasa';

  @override
  String get english => 'Inggris';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get logout => 'Keluar';

  @override
  String get oopsSomethingWentWrong => 'Ups! Terjadi kesalahan.';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get networkErrorMessage =>
      'Silakan periksa koneksi internet Anda dan coba lagi.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get noResultsFoundTitle => 'Tidak Ada Hasil yang Ditemukan';

  @override
  String noResultsFoundMessage(String searchQuery) {
    return 'Kami tidak dapat menemukan film yang cocok dengan \"$searchQuery\". Silakan coba istilah pencarian yang berbeda.';
  }

  @override
  String get noMoviesFoundGenericMessage =>
      'Kami tidak dapat menemukan film apa pun saat ini. Silakan coba lagi nanti.';

  @override
  String get clearSearchButton => 'Hapus Pencarian';

  @override
  String get noFavoritesYetTitle => 'Belum Ada Favorit';

  @override
  String get noFavoritesYetMessage =>
      'Anda belum menambahkan film apa pun ke favorit Anda. Mulai jelajahi dan tambahkan beberapa!';

  @override
  String get exploreMoviesButton => 'Jelajahi Film';

  @override
  String get pageNotFound => 'Halaman Tidak Ditemukan';

  @override
  String get pageNotFoundMessage => 'Halaman yang Anda cari tidak ada.';

  @override
  String get goHome => 'Kembali ke Beranda';

  @override
  String get madeByText => 'Dibuat oleh Neddy AP';

  @override
  String get authorWebsiteUrl => 'https://neddyap.me';
}
