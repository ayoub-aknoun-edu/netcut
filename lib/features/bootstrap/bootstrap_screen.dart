import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_providers.dart';
import '../../theme/palette_ext.dart';
import '../../theme/app_typography.dart';
import '../home/home_screen.dart';
import '../setup/setup_screen.dart';

class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsControllerProvider);

    if (perms.loading) {
      return const _SplashScreen();
    }

    return perms.requiredOk ? const HomeScreen() : const SetupScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.primary, p.secondary, p.accent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated shield icon
                Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: 80,
                          color: p.primary,
                        ),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1, 1),
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 40),

                // App name with animation
                Text(
                      'NetCut',
                      style: AppTypography.display(Colors.white).copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 12),

                Text(
                      'Control Your Internet',
                      style: AppTypography.body(Colors.white.withOpacity(0.9))
                          .copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 60),

                // Loading indicator
                SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 1500.ms,
                      color: Colors.white.withOpacity(0.5),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
