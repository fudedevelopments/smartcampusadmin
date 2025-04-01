import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:smartcampusadmin/models/ModelProvider.dart';
import 'package:smartcampusadmin/banner/models/banner_image.dart';
import 'package:smartcampusadmin/banner/services/banner_service.dart';
import 'package:uuid/uuid.dart';


Map<String, String> _imageUrlCache = {};


Future<List<BannerImage>> getBannerimagesurl() async {
  try {
    // Fetch the banner images record from the database
    final request = ModelQueries.get(
        BannerImages.classType,
        BannerImagesModelIdentifier(
            id: "91998b40-fa36-427a-8fa7-0dffab723741"));
    final response = await Amplify.API.query(request: request).response;

    final bannerImagesData = response.data;
    if (bannerImagesData == null) {
      print('No banner images found');
      return [];
    }

    // Get the list of image paths from the response
    final List<String> imagePaths = bannerImagesData.bannerimage ?? [];
    List<BannerImage> bannerImages = [];

    // Convert each path to a BannerImage object with S3 URL
    int order = 1;
    for (String path in imagePaths) {
      try {
        // Check if URL is already in cache
        String imageUrl;
        if (_imageUrlCache.containsKey(path)) {
          imageUrl = _imageUrlCache[path]!;
        } else {
          // Get the S3 URL for the image and cache it
          imageUrl = await BannerService.getImageUrl(path);
          _imageUrlCache[path] = imageUrl;
        }

        // Create a BannerImage object
        bannerImages.add(
          BannerImage(
            id: const Uuid().v4(),
            imageUrl: imageUrl,
            storagePath: path,
            order: order++,
          ),
        );
      } catch (e) {
        print('Error getting URL for image $path: $e');
      }
    }

    return bannerImages;
  } catch (e) {
    print('Error fetching banner images: $e');
    return [];
  }
}

// Update the banner images in the database
Future<bool> updateBannerImages(List<String> imagePaths) async {
  try {
    // Get the existing record
    final getRequest = ModelQueries.get(
        BannerImages.classType,
        BannerImagesModelIdentifier(
            id: "91998b40-fa36-427a-8fa7-0dffab723741"));
    final getResponse = await Amplify.API.query(request: getRequest).response;

    final existingData = getResponse.data;
    if (existingData == null) {
      print('No banner images record found to update');
      return false;
    }

    // Create updated record with new image paths
    final updatedBannerImages = existingData.copyWith(
      bannerimage: imagePaths,
    );

    // Update the record in the database
    final updateRequest = ModelMutations.update(updatedBannerImages);
    final updateResponse =
        await Amplify.API.mutate(request: updateRequest).response;

    if (updateResponse.errors.isNotEmpty) {
      print('Errors updating banner images: ${updateResponse.errors}');
      return false;
    }

    print('Successfully updated banner images');
    return true;
  } catch (e) {
    print('Error updating banner images: $e');
    return false;
  }
}

// Add a new image path to the banner images
Future<bool> addBannerImage(String imagePath) async {
  try {
    // Get the existing record
    final getRequest = ModelQueries.get(
        BannerImages.classType,
        BannerImagesModelIdentifier(
            id: "91998b40-fa36-427a-8fa7-0dffab723741"));
    final getResponse = await Amplify.API.query(request: getRequest).response;

    final existingData = getResponse.data;
    if (existingData == null) {
      print('No banner images record found to update');
      return false;
    }

    // Get existing image paths and add the new one
    List<String> updatedPaths =
        List<String>.from(existingData.bannerimage ?? []);
    updatedPaths.add(imagePath);

    // Create updated record with new image paths
    final updatedBannerImages = existingData.copyWith(
      bannerimage: updatedPaths,
    );

    // Update the record in the database
    final updateRequest = ModelMutations.update(updatedBannerImages);
    final updateResponse =
        await Amplify.API.mutate(request: updateRequest).response;

    if (updateResponse.errors.isNotEmpty) {
      print('Errors adding banner image: ${updateResponse.errors}');
      return false;
    }

    print('Successfully added banner image');
    return true;
  } catch (e) {
    print('Error adding banner image: $e');
    return false;
  }
}

// Remove an image path from the banner images
Future<bool> removeBannerImage(String imagePath) async {
  try {
    // Get the existing record
    final getRequest = ModelQueries.get(
        BannerImages.classType,
        BannerImagesModelIdentifier(
            id: "91998b40-fa36-427a-8fa7-0dffab723741"));
    final getResponse = await Amplify.API.query(request: getRequest).response;

    final existingData = getResponse.data;
    if (existingData == null) {
      print('No banner images record found to update');
      return false;
    }

    // Get existing image paths and remove the specified one
    List<String> updatedPaths =
        List<String>.from(existingData.bannerimage ?? []);
    updatedPaths.remove(imagePath);

    // Create updated record with new image paths
    final updatedBannerImages = existingData.copyWith(
      bannerimage: updatedPaths,
    );

    // Update the record in the database
    final updateRequest = ModelMutations.update(updatedBannerImages);
    final updateResponse =
        await Amplify.API.mutate(request: updateRequest).response;

    if (updateResponse.errors.isNotEmpty) {
      print('Errors removing banner image: ${updateResponse.errors}');
      return false;
    }

    print('Successfully removed banner image');
    return true;
  } catch (e) {
    print('Error removing banner image: $e');
    return false;
  }
}
