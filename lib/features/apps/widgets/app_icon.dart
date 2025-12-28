import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_providers.dart';
import '../../../theme/palette_ext.dart';

/// Modern app icon with proper image loading
class AppIcon extends ConsumerWidget {
  final String packageName;
  final Uint8List? iconPng;
  final double size;
  final double radius;

  const AppIcon({
    super.key,
    required this.packageName,
    required this.iconPng,
    this.size = 56,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    // Try to get icon from provider if not provided
    final Uint8List? effectiveIcon =
        iconPng ??
        ref
            .watch(appIconPngProvider(packageName))
            .whenOrNull(data: (data) => data);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: effectiveIcon == null
            ? Center(
                child: Icon(
                  Icons.apps_rounded,
                  color: p.onSurfaceVariant,
                  size: size * 0.5,
                ),
              )
            : Image.memory(
                effectiveIcon,
                fit: BoxFit.cover,
                width: size,
                height: size,
                cacheWidth: (size * 2).toInt(),
                cacheHeight: (size * 2).toInt(),
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.apps_rounded,
                      color: p.onSurfaceVariant,
                      size: size * 0.5,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
