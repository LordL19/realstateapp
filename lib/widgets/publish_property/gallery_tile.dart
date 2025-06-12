import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realestate_app/models/gallery_item.dart';
import 'package:realestate_app/widgets/publish_property/loader_verlay.dart';
import 'error_overlay.dart';

class GalleryTile extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  const GalleryTile({
    super.key,
    required this.item,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (item.remoteUrl != null) {
      img = Image.network(item.remoteUrl!, fit: BoxFit.cover);
    } else if (kIsWeb) {
      img = Image.network(item.localPath!, fit: BoxFit.cover);
    } else {
      img = Image.file(File(item.localPath!), fit: BoxFit.cover);
    }

    return Stack(
      children: [
        Hero(
          tag: item.key,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 120,
              height: 120,
              child: img,
            ),
          ),
        ),
        if (item.remoteUrl == null && !item.error) const LoaderOverlay(),
        if (item.error) const ErrorOverlay(),
        Positioned(
          top: 2,
          right: 2,
          child: CircleAvatar(
            maxRadius: 16,
            child: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onRemove,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        ),
      ],
    );
  }
}
