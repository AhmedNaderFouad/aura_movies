/// Centralized TMDB ID configuration for production companies, TV networks, and watch providers.
/// These IDs must NEVER be confused or interchanged as they belong to different TMDB namespaces.
class ProductionCompanyIds {
  // Production Company IDs (used with with_companies parameter)
  static const int twentyCenturyFox = 25;
  static const int marvelStudios = 420;
  static const int paramountPictures = 4;
  static const int pixarAnimationStudios = 3;
  static const int waltDisneyPictures = 2;
  static const int warnerBrosPictures = 174;

  static const Map<int, String> all = {
    twentyCenturyFox: '20th Century Fox',
    marvelStudios: 'Marvel Studios',
    paramountPictures: 'Paramount Pictures',
    pixarAnimationStudios: 'Pixar Animation Studios',
    waltDisneyPictures: 'Walt Disney Pictures',
    warnerBrosPictures: 'Warner Bros. Pictures',
  };

  static bool isValid(int id) => all.containsKey(id);

  static String? getName(int id) => all[id];

  static const List<int> validIds = [
    twentyCenturyFox,
    marvelStudios,
    paramountPictures,
    pixarAnimationStudios,
    waltDisneyPictures,
    warnerBrosPictures,
  ];
}

class TvNetworkIds {
  // TV Network IDs (used with with_networks parameter)
  static const int netflix = 213;
  static const int amazonPrimeVideo = 1024;
  static const int disneyPlus = 2739;
  static const int appleTvPlus = 2552;
  static const int hbo = 49; // Note: HBO Max may have additional IDs
  static const int hulu = 453;
  static const int amc = 67;

  static const Map<int, String> all = {
    netflix: 'Netflix',
    amazonPrimeVideo: 'Amazon Prime Video',
    disneyPlus: 'Disney+',
    appleTvPlus: 'Apple TV+',
    hbo: 'HBO',
    hulu: 'Hulu',
    amc: 'AMC',
  };

  static bool isValid(int id) => all.containsKey(id);

  static String? getName(int id) => all[id];
}

class WatchProviderIds {
  // Watch Provider IDs (used with with_watch_providers parameter for streaming availability)
  // CRITICAL: These are DIFFERENT from TV Network IDs, even when the number is the same!
  // Example: Network ID 174 = AMC (TV network)
  //          Company ID 174 = Warner Bros. Pictures (production company)
  //          But these don't conflict because they're in different namespaces.

  static const int netflix = 8;
  static const int amazonPrimeVideo = 9;
  static const int hulu = 15;
  static const int disneyPlus = 337;
  static const int appleTvPlus = 350;
  static const int amc =
      80; // AMC+ watch provider (different from AMC network ID 67)
  static const int hboMax =
      1899; // HBO Max as watch provider (different from HBO network ID 49)

  // Alternative HBO/Max provider IDs (if TMDB has variants)
  static const List<int> hboMaxAlternatives = [1899, 384];

  static const Map<int, String> all = {
    netflix: 'Netflix',
    amazonPrimeVideo: 'Amazon Prime Video',
    hulu: 'Hulu',
    disneyPlus: 'Disney+',
    appleTvPlus: 'Apple TV+',
    amc: 'AMC+',
    hboMax: 'HBO Max',
  };

  static bool isValid(int id) => all.containsKey(id);

  static String? getName(int id) => all[id];

  /// Get watch provider ID(s) for a given streaming platform name.
  /// For most platforms returns a single ID.
  /// For HBO/Max may return multiple IDs joined with pipe for OR semantics.
  static String getProviderIdForName(String name) {
    switch (name.toLowerCase()) {
      case 'netflix':
        return netflix.toString();
      case 'amazon prime video':
      case 'amazon':
        return amazonPrimeVideo.toString();
      case 'hulu':
        return hulu.toString();
      case 'disney+':
      case 'disney':
        return disneyPlus.toString();
      case 'apple tv+':
      case 'apple':
        return appleTvPlus.toString();
      case 'amc':
        return amc.toString();
      case 'hbo':
      case 'hbo max':
      case 'max':
        // Return multiple IDs with pipe for OR semantics if needed
        return hboMaxAlternatives.join('|');
      default:
        return '';
    }
  }

  /// Get network ID for TV network filtering (where applicable).
  /// Most streaming platforms are queried using watch_providers, but some have network IDs.
  static int? getNetworkIdForName(String name) {
    switch (name.toLowerCase()) {
      case 'netflix':
        return TvNetworkIds.netflix;
      case 'amazon prime video':
      case 'amazon':
        return TvNetworkIds.amazonPrimeVideo;
      case 'hulu':
        return TvNetworkIds.hulu;
      case 'disney+':
      case 'disney':
        return TvNetworkIds.disneyPlus;
      case 'apple tv+':
      case 'apple':
        return TvNetworkIds.appleTvPlus;
      case 'amc':
        return TvNetworkIds.amc;
      case 'hbo':
      case 'hbo max':
      case 'max':
        return TvNetworkIds.hbo;
      default:
        return null;
    }
  }
}

/// TMDB region for watch-provider queries.
/// This is centralized to ensure consistency across the application.
const String tmdbWatchRegion = 'US';

/// TMDB monetization type for watch-provider queries.
/// 'flatrate' means subscription-based services (most common).
const String tmdbWatchMonetizationType = 'flatrate';
