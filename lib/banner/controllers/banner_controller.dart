import 'package:smartcampusadmin/banner/models/banner_image.dart';
import 'package:smartcampusadmin/banner/services/banner_service.dart';
import 'package:smartcampusadmin/banner/apicall.dart' as BannerApi;

class BannerController {
  // Singleton instance
  static final BannerController _instance = BannerController._internal();

  factory BannerController() {
    return _instance;
  }

  BannerController._internal();

  // Load banner images from the database
  Future<List<BannerImage>> loadBannerImages() async {
    try {
      return await BannerApi.getBannerimagesurl();
    } catch (e) {
      print('Error in controller loading banners: $e');
      return [];
    }
  }

  // Add a new banner image
  Future<bool> addBannerImage(String storagePath) async {
    try {
      return await BannerApi.addBannerImage(storagePath);
    } catch (e) {
      print('Error in controller adding banner: $e');
      return false;
    }
  }

  // Remove a banner image
  Future<bool> removeBannerImage(String storagePath) async {
    try {
      // Remove from database
      bool dbResult = await BannerApi.removeBannerImage(storagePath);

      // Remove from S3 storage
      bool storageResult =
          await BannerService.deleteBannerFromStorage(storagePath);

      return dbResult && storageResult;
    } catch (e) {
      print('Error in controller removing banner: $e');
      return false;
    }
  }

  // Update the order of banner images
  Future<bool> updateBannerOrder(List<String> orderedPaths) async {
    try {
      return await BannerApi.updateBannerImages(orderedPaths);
    } catch (e) {
      print('Error in controller updating banner order: $e');
      return false;
    }
  }

  // Get the URL for a banner image
  Future<String> getBannerImageUrl(String storagePath) async {
    try {
      return await BannerService.getImageUrl(storagePath);
    } catch (e) {
      print('Error in controller getting image URL: $e');
      return '';
    }
  }
}
