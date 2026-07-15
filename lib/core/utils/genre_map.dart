/// TMDB Genre ID to Name Mapping
/// Standard genre IDs from The Movie Database (TMDB) API
const Map<int, String> genreMap = {
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
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
  // TV Show specific genres
  10759: 'Action & Adventure',
  10762: 'Kids',
  10763: 'News',
  10764: 'Reality',
  10765: 'Sci-Fi & Fantasy',
  10766: 'Soap',
  10767: 'Talk',
  10768: 'War & Politics',
};

/// Convert genre IDs to their string names
/// 
/// [genreIds] - List of genre IDs from TMDB API
/// [fallback] - Text to show if genres are empty or null (default: 'General')
/// Returns a formatted string like "Action • Sci-Fi"
String getGenreString(List<int>? genreIds, {String fallback = 'General'}) {
  if (genreIds == null || genreIds.isEmpty) {
    return fallback;
  }

  final genreNames = genreIds
      .map((id) => genreMap[id] ?? 'Unknown')
      .toList();

  return genreNames.join(' • ');
}
