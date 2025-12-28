// import 'package:flutter/widgets.dart';
// import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../app_providers.dart';
// import '../../theme/app_typography.dart';
// import '../../theme/palette_ext.dart';

// class SetupScreen extends ConsumerWidget {
//   const SetupScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final p = context.palette;
//     final perms = ref.watch(permissionsControllerProvider);

//     return NeumorphicBackground(
//       child: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
//           children: [
//             Text('Setup', style: AppTypography.headline(p.onBackground)),
//             const SizedBox(height: 6),
//             Text(
//               'To block apps reliably, NetCut needs a few permissions.',
//               style: AppTypography.body(p.onSurfaceVariant),
//             ),
//             const SizedBox(height: 16),

//             _StepCard(
//               title: 'VPN permission (required)',
//               subtitle: perms.vpnGranted
//                   ? 'Granted'
//                   : 'Required to route selected apps into a local VPN and drop their traffic.',
//               ok: perms.vpnGranted,
//               buttonLabel: perms.vpnGranted ? 'Granted' : 'Grant',
//               onPressed: perms.vpnGranted
//                   ? null
//                   : () async {
//                       await ref
//                           .read(permissionsControllerProvider.notifier)
//                           .requestVpn();
//                     },
//             ),

//             const SizedBox(height: 12),

//             _StepCard(
//               title: perms.notificationsRequired
//                   ? 'Notifications (required on Android 13+)'
//                   : 'Notifications (optional)',
//               subtitle: perms.notificationsRequired
//                   ? (perms.notificationsGranted
//                         ? 'Granted'
//                         : 'Required to show the ongoing “VPN active” notification.')
//                   : 'Not required on your Android version.',
//               ok: !perms.notificationsRequired || perms.notificationsGranted,
//               buttonLabel:
//                   (!perms.notificationsRequired || perms.notificationsGranted)
//                   ? 'OK'
//                   : 'Grant',
//               onPressed:
//                   (!perms.notificationsRequired || perms.notificationsGranted)
//                   ? null
//                   : () async {
//                       await ref
//                           .read(permissionsControllerProvider.notifier)
//                           .requestNotificationsIfNeeded();
//                     },
//             ),

//             const SizedBox(height: 12),

//             _StepCard(
//               title: 'Battery optimization (recommended)',
//               subtitle: perms.ignoringBatteryOptimizations
//                   ? 'Already unrestricted (good)'
//                   : 'Recommended: set Battery to “Unrestricted” so the VPN is less likely to be killed.',
//               ok: perms.ignoringBatteryOptimizations,
//               buttonLabel: 'Open settings',
//               onPressed: () => ref
//                   .read(permissionsControllerProvider.notifier)
//                   .openBatterySettings(),
//               secondaryLabel: 'Request ignore',
//               onSecondaryPressed: () => ref
//                   .read(permissionsControllerProvider.notifier)
//                   .requestIgnoreBattery(),
//             ),

//             const SizedBox(height: 20),

//             NeumorphicButton(
//               onPressed: perms.requiredOk
//                   ? () => ref
//                         .read(permissionsControllerProvider.notifier)
//                         .refresh()
//                   : null,
//               style: NeumorphicStyle(
//                 color: perms.requiredOk ? p.primary : p.surfaceVariant,
//                 depth: perms.requiredOk ? 3 : 0,
//                 boxShape: NeumorphicBoxShape.roundRect(
//                   BorderRadius.circular(14),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               child: Center(
//                 child: Text(
//                   perms.requiredOk ? 'Continue' : 'Complete required steps',
//                   style: AppTypography.button(
//                     perms.requiredOk ? p.onPrimary : p.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),
//             NeumorphicButton(
//               onPressed: () =>
//                   ref.read(permissionsControllerProvider.notifier).refresh(),
//               style: NeumorphicStyle(
//                 color: p.surface,
//                 depth: 2,
//                 boxShape: NeumorphicBoxShape.roundRect(
//                   BorderRadius.circular(14),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               child: Center(
//                 child: Text(
//                   'Refresh status',
//                   style: AppTypography.button(p.onBackground),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StepCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final bool ok;
//   final String buttonLabel;
//   final VoidCallback? onPressed;

//   final String? secondaryLabel;
//   final VoidCallback? onSecondaryPressed;

//   const _StepCard({
//     required this.title,
//     required this.subtitle,
//     required this.ok,
//     required this.buttonLabel,
//     required this.onPressed,
//     this.secondaryLabel,
//     this.onSecondaryPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final p = context.palette;

//     return Neumorphic(
//       style: NeumorphicStyle(
//         color: p.surface,
//         depth: 3,
//         boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: AppTypography.subtitle(p.onBackground),
//                 ),
//               ),
//               _StatusDot(ok: ok),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(subtitle, style: AppTypography.bodySmall(p.onSurfaceVariant)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: NeumorphicButton(
//                   onPressed: onPressed,
//                   style: NeumorphicStyle(
//                     color: onPressed == null
//                         ? p.surfaceVariant
//                         : p.primaryContainer,
//                     depth: onPressed == null ? 0 : 2,
//                     boxShape: NeumorphicBoxShape.roundRect(
//                       BorderRadius.circular(12),
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Center(
//                     child: Text(
//                       buttonLabel,
//                       style: AppTypography.button(p.onBackground),
//                     ),
//                   ),
//                 ),
//               ),
//               if (secondaryLabel != null && onSecondaryPressed != null) ...[
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: NeumorphicButton(
//                     onPressed: onSecondaryPressed,
//                     style: NeumorphicStyle(
//                       color: p.surfaceVariant,
//                       depth: 2,
//                       boxShape: NeumorphicBoxShape.roundRect(
//                         BorderRadius.circular(12),
//                       ),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Center(
//                       child: Text(
//                         secondaryLabel!,
//                         style: AppTypography.button(p.onBackground),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatusDot extends StatelessWidget {
//   final bool ok;
//   const _StatusDot({required this.ok});

//   @override
//   Widget build(BuildContext context) {
//     final p = context.palette;
//     return Container(
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(
//         color: ok ? p.secondary : p.error,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final perms = ref.watch(permissionsControllerProvider);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            // Hero section
            Column(
              children: [
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [p.primary, p.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: p.primary.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOut)
                    .fadeIn(),
                const SizedBox(height: 20),
                Text(
                      'Welcome to NetCut',
                      style: AppTypography.display(
                        p.onBackground,
                      ).copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 12),
                Text(
                      'To block apps reliably, we need a few permissions',
                      style: AppTypography.body(p.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              ],
            ),

            const SizedBox(height: 32),

            // Setup steps
            _SetupStep(
                  stepNumber: 1,
                  icon: Icons.vpn_key_rounded,
                  title: 'VPN Permission',
                  description:
                      'Required to route and block selected app traffic',
                  status: perms.vpnGranted ? 'Granted' : 'Required',
                  isGranted: perms.vpnGranted,
                  isRequired: true,
                  buttonLabel: perms.vpnGranted
                      ? 'Granted ✓'
                      : 'Grant Permission',
                  onPressed: perms.vpnGranted
                      ? null
                      : () async {
                          await ref
                              .read(permissionsControllerProvider.notifier)
                              .requestVpn();
                        },
                  palette: p,
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 16),

            _SetupStep(
                  stepNumber: 2,
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  description: perms.notificationsRequired
                      ? 'Required on Android 13+ to show VPN active notification'
                      : 'Not required on your Android version',
                  status:
                      (!perms.notificationsRequired ||
                          perms.notificationsGranted)
                      ? 'OK'
                      : 'Required',
                  isGranted:
                      !perms.notificationsRequired ||
                      perms.notificationsGranted,
                  isRequired: perms.notificationsRequired,
                  buttonLabel:
                      (!perms.notificationsRequired ||
                          perms.notificationsGranted)
                      ? 'OK ✓'
                      : 'Grant Permission',
                  onPressed:
                      (!perms.notificationsRequired ||
                          perms.notificationsGranted)
                      ? null
                      : () async {
                          await ref
                              .read(permissionsControllerProvider.notifier)
                              .requestNotificationsIfNeeded();
                        },
                  palette: p,
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 16),

            _SetupStep(
                  stepNumber: 3,
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Battery Optimization',
                  description:
                      'Recommended: disable battery optimization for reliability',
                  status: perms.ignoringBatteryOptimizations
                      ? 'Unrestricted'
                      : 'Recommended',
                  isGranted: perms.ignoringBatteryOptimizations,
                  isRequired: false,
                  buttonLabel: 'Open Settings',
                  onPressed: () => ref
                      .read(permissionsControllerProvider.notifier)
                      .openBatterySettings(),
                  secondaryLabel: 'Request',
                  onSecondaryPressed: () => ref
                      .read(permissionsControllerProvider.notifier)
                      .requestIgnoreBattery(),
                  palette: p,
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 32),

            // Action buttons
            SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: perms.requiredOk
                        ? () => ref
                              .read(permissionsControllerProvider.notifier)
                              .refresh()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: perms.requiredOk
                          ? p.primary
                          : p.surfaceVariant,
                      foregroundColor: perms.requiredOk
                          ? Colors.white
                          : p.onSurfaceVariant,
                      disabledBackgroundColor: p.surfaceVariant,
                      disabledForegroundColor: p.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      shadowColor: perms.requiredOk
                          ? p.primary.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          perms.requiredOk
                              ? 'Continue to NetCut'
                              : 'Complete Required Steps',
                          style: AppTypography.button(
                            perms.requiredOk
                                ? Colors.white
                                : p.onSurfaceVariant,
                          ).copyWith(fontSize: 16),
                        ),
                        if (perms.requiredOk) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 700.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(permissionsControllerProvider.notifier).refresh(),
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Refresh Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.onBackground,
                side: BorderSide(color: p.outline, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final int stepNumber;
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final bool isGranted;
  final bool isRequired;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final ColorPalette palette;

  const _SetupStep({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.isGranted,
    required this.isRequired,
    required this.buttonLabel,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isGranted
              ? Colors.green.withOpacity(0.3)
              : isRequired
              ? palette.error.withOpacity(0.3)
              : palette.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isGranted ? Colors.green.withOpacity(0.1) : palette.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Step number
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isGranted
                      ? LinearGradient(
                          colors: [Colors.green, Colors.green.shade600],
                        )
                      : LinearGradient(
                          colors: [palette.primary, palette.secondary],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isGranted
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : Text(
                          stepNumber.toString(),
                          style: AppTypography.button(Colors.white),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Icon and title
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isGranted
                      ? Colors.green.withOpacity(0.15)
                      : palette.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isGranted ? Colors.green : palette.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.subtitle(palette.onBackground),
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'REQUIRED',
                              style: AppTypography.label(
                                palette.error,
                              ).copyWith(fontSize: 9),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isGranted
                            ? Colors.green.withOpacity(0.15)
                            : palette.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: AppTypography.label(
                          isGranted ? Colors.green : palette.onSurfaceVariant,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: AppTypography.body(
              palette.onSurfaceVariant,
            ).copyWith(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onPressed == null
                        ? palette.surfaceVariant
                        : palette.primaryContainer,
                    foregroundColor: onPressed == null
                        ? palette.onSurfaceVariant
                        : palette.onPrimary,
                    disabledBackgroundColor: palette.surfaceVariant,
                    disabledForegroundColor: palette.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: AppTypography.button(
                      onPressed == null
                          ? palette.onSurfaceVariant
                          : palette.onPrimary,
                    ).copyWith(fontSize: 13),
                  ),
                ),
              ),
              if (secondaryLabel != null && onSecondaryPressed != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondaryPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.primary,
                      side: BorderSide(
                        color: palette.outline.withOpacity(0.5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      secondaryLabel!,
                      style: AppTypography.button(
                        palette.primary,
                      ).copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
