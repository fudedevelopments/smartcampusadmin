import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Import our new components
import 'package:smartcampusadmin/banner/models/banner_image.dart';
import 'package:smartcampusadmin/banner/services/banner_service.dart';
import 'package:smartcampusadmin/banner/widgets/banner_carousel.dart';
import 'package:smartcampusadmin/banner/widgets/banner_list_item.dart';
import 'package:smartcampusadmin/banner/widgets/file_picker_box.dart';
import 'package:smartcampusadmin/banner/controllers/banner_controller.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  // List to store banner images with their order
  List<BannerImage> bannerImages = [];
  int _currentPage = 0;
  late PageController _pageController;
  bool isLoading = false;
  List<File> selectedFiles = [];
  List<Map<String, String>> uploadedFiles = [];
  bool hasUploadedFiles = false;

  // Banner controller
  final BannerController _bannerController = BannerController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    // Load existing banners
    _loadBanners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method to handle page changes from the carousel
  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _loadBanners() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the controller to load banners
      final loadedBanners = await _bannerController.loadBannerImages();

      setState(() {
        bannerImages = loadedBanners;
      });
    } catch (e) {
      print('Error loading banners: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading banners: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Handle file uploads and update banner list
  void _handleFilesUpdated(List<Map<String, String>> files) {
    setState(() {
      uploadedFiles = files;
      hasUploadedFiles = files.isNotEmpty;
    });
  }

  // Add a new banner with the uploaded file
  Future<void> _addNewBanner() async {
    if (!hasUploadedFiles) {
      // Don't add a banner if no files were uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      for (var file in uploadedFiles) {
        // Find the next available order number
        int nextOrder = 1;
        if (bannerImages.isNotEmpty) {
          nextOrder =
              bannerImages.map((b) => b.order).reduce((a, b) => a > b ? a : b) +
                  1;
        }

        String? storagePath = file['url'];
        if (storagePath != null) {
          // Add the storage path to the database using the controller
          await _bannerController.addBannerImage(storagePath);

          // Get the S3 URL for the image
          final imageUrl =
              await _bannerController.getBannerImageUrl(storagePath);

          // Add the new banner with the next order
          bannerImages.add(
            BannerImage(
              id: const Uuid().v4(),
              imageUrl: imageUrl,
              storagePath: storagePath,
              order: nextOrder,
            ),
          );
        }
      }

      // Sort banners by order
      bannerImages = BannerService.reorderBanners(bannerImages);

      // Clear uploaded files after adding
      selectedFiles.clear();
      uploadedFiles.clear();
      hasUploadedFiles = false;
    } catch (e) {
      print('Error adding banner: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding banner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete a banner
  Future<void> _deleteBanner(String id) async {
    // Find the banner to delete
    final bannerToDelete = bannerImages.firstWhere((banner) => banner.id == id);

    setState(() {
      isLoading = true;
    });

    try {
      // If it has a storage path, delete using the controller
      if (bannerToDelete.storagePath != null) {
        await _bannerController.removeBannerImage(bannerToDelete.storagePath!);
      }

      setState(() {
        // Remove from the list
        bannerImages.removeWhere((banner) => banner.id == id);

        // Reorder remaining banners
        bannerImages = BannerService.reorderBanners(bannerImages);
      });
    } catch (e) {
      print('Delete failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting banner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showBannerDialog({BannerImage? existingBanner}) {
    // Reset state for new upload
    selectedFiles = [];
    uploadedFiles = [];
    hasUploadedFiles = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(existingBanner == null ? 'Add New Banner' : 'Update Banner'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilePickerBoxUI(
                selectfiles: selectedFiles,
                onFilesUpdated: _handleFilesUpdated,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (existingBanner == null) {
                _addNewBanner();
              } else {
                // Update existing banner logic would go here
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Move banner up in order
  void _moveBannerUp(int index) {
    if (index > 0) {
      setState(() {
        // Swap order values
        int tempOrder = bannerImages[index].order;
        bannerImages[index].order = bannerImages[index - 1].order;
        bannerImages[index - 1].order = tempOrder;

        // Sort the list by order
        bannerImages = BannerService.reorderBanners(bannerImages);
      });
    }
  }

  // Move banner down in order
  void _moveBannerDown(int index) {
    if (index < bannerImages.length - 1) {
      setState(() {
        // Swap order values
        int tempOrder = bannerImages[index].order;
        bannerImages[index].order = bannerImages[index + 1].order;
        bannerImages[index + 1].order = tempOrder;

        // Sort the list by order
        bannerImages = BannerService.reorderBanners(bannerImages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner preview
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: BannerCarousel(
                      bannerImages: bannerImages,
                      currentPage: _currentPage,
                      onPageChanged: _handlePageChanged,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Banners',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showBannerDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Banner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: bannerImages.isEmpty
                        ? Center(
                            child: Text(
                              'No banners added yet. Click "Add Banner" to get started.',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: bannerImages.length,
                            itemBuilder: (context, index) {
                              return BannerListItem(
                                banner: bannerImages[index],
                                index: index,
                                totalBanners: bannerImages.length,
                                onMoveUp: _moveBannerUp,
                                onMoveDown: _moveBannerDown,
                                onEdit: (banner) =>
                                    _showBannerDialog(existingBanner: banner),
                                onDelete: _deleteBanner,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
