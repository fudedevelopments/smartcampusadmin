import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartcampusadmin/banner/models/banner_image.dart';
import 'package:smartcampusadmin/banner/services/banner_service.dart';
import 'package:smartcampusadmin/banner/widgets/image_display.dart';

class BannerListItem extends StatelessWidget {
  final BannerImage banner;
  final int index;
  final int totalBanners;
  final Function(int) onMoveUp;
  final Function(int) onMoveDown;
  final Function(BannerImage) onEdit;
  final Function(String) onDelete;

  const BannerListItem({
    super.key,
    required this.banner,
    required this.index,
    required this.totalBanners,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: banner.storagePath != null
                ? ImageDisplay(
                    imageUrlFuture:
                        BannerService.getImageUrl(banner.storagePath!),
                    fit: BoxFit.cover,
                    loadingWidget: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Image.file(
                    File(banner.imageUrl),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text('Banner ${banner.order}'),
        subtitle: Text('ID: ${banner.id}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: index > 0 ? () => onMoveUp(index) : null,
              tooltip: 'Move Up',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed:
                  index < totalBanners - 1 ? () => onMoveDown(index) : null,
              tooltip: 'Move Down',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(banner),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(banner.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
