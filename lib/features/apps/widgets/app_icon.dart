import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../theme/palette_ext.dart';

/// Small square icon used across the app list & group screens.
///
/// If [iconPng] is null, this widget will *optionally* try to lazy-load the icon
/// from the platform side via [appIconPngProvider].
class AppIcon extends ConsumerWidget {
  final String packageName;
  final Uint8List? iconPng;
  final double size;
  final double radius;

  const AppIcon({
    super.key,
    required this.packageName,
    required this.iconPng,
    this.size = 38,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    final lazy = iconPng == null
        ? ref
              .watch(appIconPngProvider(packageName))
              .whenData((data) => data)
              .value
        : iconPng;

    return Neumorphic(
      style: NeumorphicStyle(
        color: p.surfaceVariant,
        depth: 2,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
      ),
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: size,
        height: size,
        child: lazy == null
            ? Icon(Icons.apps_rounded, color: p.onBackground)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  lazy,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  // hint to decode smaller (helps memory) while still crisp.
                  cacheWidth: 96,
                  cacheHeight: 96,
                ),
              ),
      ),
    );
  }
}
