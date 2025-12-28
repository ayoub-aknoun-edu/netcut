import 'package:flutter/material.dart';
import 'app_neumorphic_theme.dart';

extension PaletteExt on BuildContext {
  ColorPalette get palette {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.light
        ? AppNeumorphicTheme.light()
        : AppNeumorphicTheme.dark();
  }
}
