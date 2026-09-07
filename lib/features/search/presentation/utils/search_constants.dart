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

  static const Map<int, String> companies = {
    213: 'Netflix',
    2552: 'Apple TV+',
    1024: 'Amazon Prime Videos',
    2739: 'Disney+',
    49: 'HBO / Max',
    453: 'Hulu',
    4338: 'Paramount+',
    174: 'AMC',
    420: 'Marvel Studios',
    3: 'Pixar',
    1741: 'Warner Bros.',
    2: 'Walt Disney Pictures',
    4: 'Paramount Pictures',
    25: '20th Century Fox',
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
