import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'app_palette.dart';

extension PaletteX on BuildContext {
  AppPalette get palette =>
      NeumorphicTheme.isUsingDark(this) ? AppPalette.dark : AppPalette.light;

  bool get isDark => NeumorphicTheme.isUsingDark(this);
}
