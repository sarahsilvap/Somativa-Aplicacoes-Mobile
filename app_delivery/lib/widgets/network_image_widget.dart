import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    String processedUrl = imageUrl;
    
    // For Flutter Web, use CORS proxy if needed
    if (kIsWeb && imageUrl.isNotEmpty) {
      // Log the original URL for debugging
      debugPrint('[v0] Loading image: $imageUrl');
      
      // Check if URL needs CORS proxy (external domains)
      if (imageUrl.startsWith('http') && 
          !imageUrl.contains('localhost') && 
          !imageUrl.contains('127.0.0.1')) {
        // Use CORS proxy for external images on web
        // You can replace this with your own CORS proxy if needed
        processedUrl = 'https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}';
        debugPrint('[v0] Using CORS proxy: $processedUrl');
      }
    }

    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    return CachedNetworkImage(
      imageUrl: processedUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: const {
        'User-Agent': 'DeliveryApp/1.0',
        'Accept': 'image/*',
      },
      placeholder: (context, url) {
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
      errorWidget: (context, url, error) {
        debugPrint('[v0] Image load error for $url: $error');
        return errorWidget ?? _buildErrorWidget(context);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}
