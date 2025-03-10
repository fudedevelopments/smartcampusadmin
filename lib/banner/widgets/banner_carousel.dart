import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartcampusadmin/banner/models/banner_image.dart';
import 'package:smartcampusadmin/banner/services/banner_service.dart';
import 'package:smartcampusadmin/banner/widgets/image_display.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerImage> bannerImages;
  final Function(int) onPageChanged;
  final int currentPage;

  const BannerCarousel({
    super.key,
    required this.bannerImages,
    required this.onPageChanged,
    required this.currentPage,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage);
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the page actually changed and controller is attached
    if (oldWidget.currentPage != widget.currentPage &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigate to previous page
  void _goToPreviousPage() {
    final int targetPage = widget.currentPage > 0
        ? widget.currentPage - 1
        : widget.bannerImages.length - 1;

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Navigate to next page
  void _goToNextPage() {
    final int targetPage = widget.currentPage < widget.bannerImages.length - 1
        ? widget.currentPage + 1
        : 0;

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerImages.isEmpty) {
      return Center(
        child: Text(
          'No banners available',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Banner PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: widget.onPageChanged,
            itemCount: widget.bannerImages.length,
            itemBuilder: (context, index) {
              final banner = widget.bannerImages[index];
              // Use the already fetched imageUrl instead of fetching it again
              return Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                // Use cacheWidth and cacheHeight for better performance
                cacheWidth: MediaQuery.of(context).size.width.toInt(),
                // Use memory cache to prevent refetching
                cacheHeight: 300,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('Failed to load image'),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              );
            },
          ),

          // Left navigation arrow
          if (widget.bannerImages.length > 1)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _goToPreviousPage,
                  ),
                ),
              ),
            ),

          // Right navigation arrow
          if (widget.bannerImages.length > 1)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _goToNextPage,
                  ),
                ),
              ),
            ),

          // Banner counter
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${widget.currentPage + 1}/${widget.bannerImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.bannerImages.length,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: widget.currentPage == index ? 12 : 8,
                    height: widget.currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
