class AddressRegion {
  const AddressRegion({
    this.province,
    this.district,
    this.locality,
  });

  final String? province;
  final String? district;
  final String? locality;

  bool get isEmpty => province == null && district == null && locality == null;
}
