import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../home/home_screen.dart';
import '../setup/setup_screen.dart';

class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsControllerProvider);

    if (perms.loading) {
      return const _Splash();
    }

    return perms.requiredOk ? const HomeScreen() : const SetupScreen();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loading…'));
  }
}
