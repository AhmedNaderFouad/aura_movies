class BrandEntity {
  final int id;
  final String name;
  final String logoPath;
  final int? networkId;
  final int? companyId;
  final bool isNetwork;

  const BrandEntity({
    required this.id,
    required this.name,
    required this.logoPath,
    this.networkId,
    this.companyId,
    this.isNetwork = false,
  });
}
