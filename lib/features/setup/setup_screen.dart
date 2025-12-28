import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final perms = ref.watch(permissionsControllerProvider);

    return NeumorphicBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text('Setup', style: AppTypography.headline(p.onBackground)),
            const SizedBox(height: 6),
            Text(
              'To block apps reliably, NetCut needs a few permissions.',
              style: AppTypography.body(p.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            _StepCard(
              title: 'VPN permission (required)',
              subtitle: perms.vpnGranted
                  ? 'Granted'
                  : 'Required to route selected apps into a local VPN and drop their traffic.',
              ok: perms.vpnGranted,
              buttonLabel: perms.vpnGranted ? 'Granted' : 'Grant',
              onPressed: perms.vpnGranted
                  ? null
                  : () async {
                      await ref
                          .read(permissionsControllerProvider.notifier)
                          .requestVpn();
                    },
            ),

            const SizedBox(height: 12),

            _StepCard(
              title: perms.notificationsRequired
                  ? 'Notifications (required on Android 13+)'
                  : 'Notifications (optional)',
              subtitle: perms.notificationsRequired
                  ? (perms.notificationsGranted
                        ? 'Granted'
                        : 'Required to show the ongoing “VPN active” notification.')
                  : 'Not required on your Android version.',
              ok: !perms.notificationsRequired || perms.notificationsGranted,
              buttonLabel:
                  (!perms.notificationsRequired || perms.notificationsGranted)
                  ? 'OK'
                  : 'Grant',
              onPressed:
                  (!perms.notificationsRequired || perms.notificationsGranted)
                  ? null
                  : () async {
                      await ref
                          .read(permissionsControllerProvider.notifier)
                          .requestNotificationsIfNeeded();
                    },
            ),

            const SizedBox(height: 12),

            _StepCard(
              title: 'Battery optimization (recommended)',
              subtitle: perms.ignoringBatteryOptimizations
                  ? 'Already unrestricted (good)'
                  : 'Recommended: set Battery to “Unrestricted” so the VPN is less likely to be killed.',
              ok: perms.ignoringBatteryOptimizations,
              buttonLabel: 'Open settings',
              onPressed: () => ref
                  .read(permissionsControllerProvider.notifier)
                  .openBatterySettings(),
              secondaryLabel: 'Request ignore',
              onSecondaryPressed: () => ref
                  .read(permissionsControllerProvider.notifier)
                  .requestIgnoreBattery(),
            ),

            const SizedBox(height: 20),

            NeumorphicButton(
              onPressed: perms.requiredOk
                  ? () => ref
                        .read(permissionsControllerProvider.notifier)
                        .refresh()
                  : null,
              style: NeumorphicStyle(
                color: perms.requiredOk ? p.primary : p.surfaceVariant,
                depth: perms.requiredOk ? 3 : 0,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  perms.requiredOk ? 'Continue' : 'Complete required steps',
                  style: AppTypography.button(
                    perms.requiredOk ? p.onPrimary : p.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            NeumorphicButton(
              onPressed: () =>
                  ref.read(permissionsControllerProvider.notifier).refresh(),
              style: NeumorphicStyle(
                color: p.surface,
                depth: 2,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Refresh status',
                  style: AppTypography.button(p.onBackground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool ok;
  final String buttonLabel;
  final VoidCallback? onPressed;

  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.ok,
    required this.buttonLabel,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Neumorphic(
      style: NeumorphicStyle(
        color: p.surface,
        depth: 3,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.subtitle(p.onBackground),
                ),
              ),
              _StatusDot(ok: ok),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.bodySmall(p.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: onPressed,
                  style: NeumorphicStyle(
                    color: onPressed == null
                        ? p.surfaceVariant
                        : p.primaryContainer,
                    depth: onPressed == null ? 0 : 2,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      buttonLabel,
                      style: AppTypography.button(p.onBackground),
                    ),
                  ),
                ),
              ),
              if (secondaryLabel != null && onSecondaryPressed != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: onSecondaryPressed,
                    style: NeumorphicStyle(
                      color: p.surfaceVariant,
                      depth: 2,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        secondaryLabel!,
                        style: AppTypography.button(p.onBackground),
                      ),
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

class _StatusDot extends StatelessWidget {
  final bool ok;
  const _StatusDot({required this.ok});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: ok ? p.secondary : p.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
