import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';

/// A universal image widget that renders both Remote Network URLs (http/https)
/// and Local File Paths (e.g. photos captured from camera or chosen from gallery).
class AppImageView extends StatelessWidget {
  final String imageUrlOrPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImageView({
    super.key,
    required this.imageUrlOrPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isNetwork =>
      imageUrlOrPath.startsWith('http://') ||
      imageUrlOrPath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrlOrPath.isEmpty) {
      imageWidget = _buildFallback(context);
    } else if (_isNetwork) {
      imageWidget = Image.network(
        imageUrlOrPath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: context.colors.fill,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      // Local file
      final file = File(imageUrlOrPath);
      imageWidget = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildFallback(BuildContext context) {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: context.colors.fill,
          child: Center(
            child: AppIcon(
              Icons.image_outlined,
              size: (width != null && width! < 40) ? 18 : 28,
              color: context.colors.textMuted,
            ),
          ),
        );
  }
}
