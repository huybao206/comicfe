import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    debugPrint('Reader imageUrl: $imageUrl');

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      clipBehavior: Clip.none,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, error, stackTrace) {
          debugPrint('Image load failed: $imageUrl');
          debugPrint('Error: $error');

          return Container(
            height: 260,
            alignment: Alignment.center,
            color: const Color(0xFF111827),
            child: const Text(
              'Không tải được ảnh',
              style: TextStyle(color: Colors.white54),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return SizedBox(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF5B8CFF),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
