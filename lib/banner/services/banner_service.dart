import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:smartcampusadmin/banner/models/banner_image.dart';

class BannerService {
  // Cache for image URLs to prevent repeated API calls
  static final Map<String, String> _imageUrlCache = {};

  // Get image URL from S3 with caching
  static Future<String> getImageUrl(String storagePath) async {
    // Check if URL is already in cache
    if (_imageUrlCache.containsKey(storagePath)) {
      return _imageUrlCache[storagePath]!;
    }

    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(storagePath),
      ).result;

      // Cache the URL
      final url = result.url.toString();
      _imageUrlCache[storagePath] = url;

      return url;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  // Delete a banner from storage
  static Future<bool> deleteBannerFromStorage(String storagePath) async {
    try {
      await Amplify.Storage.remove(
        path: StoragePath.fromString(storagePath),
      ).result;

      // Remove from cache if exists
      _imageUrlCache.remove(storagePath);

      return true;
    } catch (e) {
      print('Delete failed: $e');
      return false;
    }
  }

  // Reorder banners after changes
  static List<BannerImage> reorderBanners(List<BannerImage> banners) {
    // Sort by order
    banners.sort((a, b) => a.order.compareTo(b.order));

    // Reassign order numbers sequentially
    for (int i = 0; i < banners.length; i++) {
      banners[i].order = i + 1;
    }

    return banners;
  }
}
