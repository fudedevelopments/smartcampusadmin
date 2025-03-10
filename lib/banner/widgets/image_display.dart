import 'package:flutter/material.dart';

// Widget to display images from S3
class ImageDisplay extends StatelessWidget {
  final Future<String> imageUrlFuture;
  final double? height; // Optional height
  final double? width; // Optional width
  final BoxFit fit; // Control how the image fits
  final Widget? loadingWidget; // Custom loading widget
  final Widget? errorWidget; // Custom error widget

  const ImageDisplay({
    super.key,
    required this.imageUrlFuture,
    this.height,
    this.width,
    this.fit = BoxFit.cover, // Default to cover
    this.loadingWidget = const CircularProgressIndicator(), // Default loading
    this.errorWidget = const Text('Failed to load image'), // Default error
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: height,
              width: width,
              child: loadingWidget,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: SizedBox(
              height: height,
              width: width,
              child: errorWidget,
            ),
          );
        } else if (snapshot.hasData) {
          return Image.network(
            snapshot.data!,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => errorWidget!,
          );
        } else {
          return Center(
            child: SizedBox(
              height: height,
              width: width,
              child: const Text('No image URL found'),
            ),
          );
        }
      },
    );
  }
}
