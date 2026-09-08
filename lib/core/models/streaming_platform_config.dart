/// Streaming platform configuration for TMDB filtering.
/// Separates watch provider IDs (used with with_watch_providers for streaming availability)
/// from TV network IDs (used with with_networks for TV shows produced/broadcast by the network).
class StreamingPlatformConfig {
  final String name;

  /// Watch provider IDs for this platform (used with with_watch_providers for both movies and TV).
  /// Multiple IDs support legacy/regional variants of the same service.
  final List<int> watchProviderIds;

  /// TV network IDs for this platform (used with with_networks for TV shows).
  /// Some platforms may have associated network IDs.
  final List<int> tvNetworkIds;

  const StreamingPlatformConfig({
    required this.name,
    required this.watchProviderIds,
    required this.tvNetworkIds,
  });

  /// Primary watch provider ID (first in the list).
  int? get primaryWatchProviderId =>
      watchProviderIds.isNotEmpty ? watchProviderIds.first : null;

  /// Primary TV network ID (first in the list).
  int? get primaryTvNetworkId =>
      tvNetworkIds.isNotEmpty ? tvNetworkIds.first : null;

  /// Format watch provider IDs as TMDB pipe-separated string (OR semantics).
  String get watchProviderIdsString => watchProviderIds.join('|');

  /// Format TV network IDs as TMDB pipe-separated string (OR semantics).
  String get tvNetworkIdsString => tvNetworkIds.join('|');

  @override
  String toString() => name;
}

/// Centralized streaming platform configuration for Aura Movies.
/// These platforms are used for filtering both movies and TV shows by streaming availability
/// and/or network association.
class StreamingPlatforms {
  static const StreamingPlatformConfig amazonPrimeVideo =
      StreamingPlatformConfig(
        name: 'Amazon Prime Video',
        watchProviderIds: [
          9,
        ], // TMDB watch provider ID for Amazon Prime Video movies/TV
        tvNetworkIds: [1024], // TMDB TV network ID for Amazon Prime Video
      );

  static const StreamingPlatformConfig amcPlus = StreamingPlatformConfig(
    name: 'AMC',
    watchProviderIds: [80], // AMC+ watch provider ID (may vary by region)
    tvNetworkIds: [
      174,
    ], // Note: 174 is also Warner Bros company ID - different namespace
  );

  static const StreamingPlatformConfig appleTvPlus = StreamingPlatformConfig(
    name: 'Apple TV+',
    watchProviderIds: [350], // TMDB watch provider ID for Apple TV+
    tvNetworkIds: [2552], // TMDB TV network ID for Apple TV+
  );

  static const StreamingPlatformConfig disneyPlus = StreamingPlatformConfig(
    name: 'Disney+',
    watchProviderIds: [337], // TMDB watch provider ID for Disney+
    tvNetworkIds: [2739], // TMDB TV network ID for Disney+
  );

  static const StreamingPlatformConfig hbo = StreamingPlatformConfig(
    name: 'HBO',
    // HBO Max/Max has multiple provider IDs depending on region and service
    // 1899 is a known HBO Max provider ID; there may be others
    watchProviderIds: [1899, 384], // Multiple IDs to cover regional variants
    tvNetworkIds: [49], // HBO TV network ID
  );

  static const StreamingPlatformConfig hulu = StreamingPlatformConfig(
    name: 'Hulu',
    watchProviderIds: [15], // TMDB watch provider ID for Hulu
    tvNetworkIds: [453], // TMDB TV network ID for Hulu
  );

  static const StreamingPlatformConfig netflix = StreamingPlatformConfig(
    name: 'Netflix',
    watchProviderIds: [8], // TMDB watch provider ID for Netflix
    tvNetworkIds: [213], // TMDB TV network ID for Netflix
  );

  /// All configured streaming platforms in display order.
  static const List<StreamingPlatformConfig> all = [
    amazonPrimeVideo,
    amcPlus,
    appleTvPlus,
    disneyPlus,
    hbo,
    hulu,
    netflix,
  ];

  /// Get a streaming platform by watch provider ID.
  static StreamingPlatformConfig? getByWatchProviderId(int id) {
    try {
      return all.firstWhere(
        (platform) => platform.watchProviderIds.contains(id),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get a streaming platform by TV network ID.
  static StreamingPlatformConfig? getByTvNetworkId(int id) {
    try {
      return all.firstWhere((platform) => platform.tvNetworkIds.contains(id));
    } catch (e) {
      return null;
    }
  }

  /// Check if an ID is a valid watch provider ID for any platform.
  static bool isValidWatchProviderId(int id) =>
      getByWatchProviderId(id) != null;

  /// Check if an ID is a valid TV network ID for any platform.
  static bool isValidTvNetworkId(int id) => getByTvNetworkId(id) != null;
}
