// Model class for banner images
class BannerImage {
  final String id;
  final String imageUrl;
  String? storagePath;
  int order;

  BannerImage({
    required this.id,
    required this.imageUrl,
    this.storagePath,
    required this.order,
  });
}
