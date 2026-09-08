enum SearchMode { keyword, categories }

class SearchConstants {
  static final List<int> years = List.generate(
    DateTime.now().year - 1950 + 1,
    (index) => DateTime.now().year - index,
  );

  static const Map<String, String> languages = {
    'en': 'English',
    'es': 'Spanish',
    'tr': 'Turkish',
    'ar': 'Arabic',
    'fr': 'French',
    'de': 'German',
    'hi': 'Hindi',
    'ja': 'Japanese',
    'ko': 'Korean',
  };

  /// Production Companies / Studios - these use with_companies parameter
  static const Map<int, String> productionCompanies = {
    25: '20th Century Fox',
    420: 'Marvel Studios',
    4: 'Paramount Pictures',
    3: 'Pixar Animation Studios',
    2: 'Walt Disney Pictures',
    174: 'Warner Bros. Pictures',
  };

  /// Streaming Platforms - these use with_watch_providers or with_networks parameters
  static const Map<int, String> streamingPlatforms = {
    9: 'Amazon Prime Video',
    80: 'AMC',
    350: 'Apple TV+',
    337: 'Disney+',
    1899: 'HBO',
    15: 'Hulu',
    8: 'Netflix',
  };

  /// Combined companies and platforms for backward compatibility with UI
  /// Maps display names to (id, isCompany) tuples
  /// isCompany=true means it's a production company, false means it's a streaming platform
  static const Map<String, (int, bool)> allStudiosAndPlatforms = {
    '20th Century Fox': (25, true),
    'Marvel Studios': (420, true),
    'Paramount Pictures': (4, true),
    'Pixar Animation Studios': (3, true),
    'Walt Disney Pictures': (2, true),
    'Warner Bros. Pictures': (174, true),
    'Amazon Prime Video': (9, false),
    'AMC': (80, false),
    'Apple TV+': (350, false),
    'Disney+': (337, false),
    'HBO': (1899, false),
    'Hulu': (15, false),
    'Netflix': (8, false),
  };

  static const Map<int, String> movieGenres = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static const Map<int, String> tvGenres = {
    10759: 'Action & Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    10762: 'Kids',
    9648: 'Mystery',
    10763: 'News',
    10764: 'Reality',
    10765: 'Sci-Fi & Fantasy',
    10766: 'Soap',
    10767: 'Talk',
    10768: 'War & Politics',
    37: 'Western',
  };
}
