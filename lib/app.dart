import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'features/bootstrap/bootstrap_screen.dart';
import 'theme/app_neumorphic_theme.dart';

class NetCutApp extends ConsumerWidget {
  const NetCutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider).mode;

    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'NetCut',
      themeMode: themeMode,
      theme: AppNeumorphicTheme.lightTheme(),
      darkTheme: AppNeumorphicTheme.darkTheme(),
      home: const BootstrapScreen(),
    );
  }
}
