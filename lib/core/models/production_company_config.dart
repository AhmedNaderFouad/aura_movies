/// Production Company configuration for TMDB filtering.
/// These are studios/production companies used with the with_companies parameter.
class ProductionCompanyConfig {
  final int id;
  final String name;

  const ProductionCompanyConfig({required this.id, required this.name});

  @override
  String toString() => name;
}

/// Centralized production companies configuration for Aura Movies.
class ProductionCompanies {
  static const ProductionCompanyConfig twentyCenturyFoxCompany =
      ProductionCompanyConfig(id: 25, name: '20th Century Fox');

  static const ProductionCompanyConfig marvelStudios = ProductionCompanyConfig(
    id: 420,
    name: 'Marvel Studios',
  );

  static const ProductionCompanyConfig paramountPictures =
      ProductionCompanyConfig(id: 4, name: 'Paramount Pictures');

  static const ProductionCompanyConfig pixarAnimationStudios =
      ProductionCompanyConfig(id: 3, name: 'Pixar Animation Studios');

  static const ProductionCompanyConfig waltDisneyPictures =
      ProductionCompanyConfig(id: 2, name: 'Walt Disney Pictures');

  static const ProductionCompanyConfig warnerBrosPictures =
      ProductionCompanyConfig(id: 174, name: 'Warner Bros. Pictures');

  /// All configured production companies in display order.
  static const List<ProductionCompanyConfig> all = [
    twentyCenturyFoxCompany,
    marvelStudios,
    paramountPictures,
    pixarAnimationStudios,
    waltDisneyPictures,
    warnerBrosPictures,
  ];

  /// Get a production company by ID.
  static ProductionCompanyConfig? getById(int id) {
    try {
      return all.firstWhere((company) => company.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if an ID is a valid production company ID.
  static bool isValidCompanyId(int id) => getById(id) != null;
}
