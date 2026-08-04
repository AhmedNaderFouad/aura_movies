import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/app_cache_manager.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: AppCacheManager.instance,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error),
    );
  }
}
