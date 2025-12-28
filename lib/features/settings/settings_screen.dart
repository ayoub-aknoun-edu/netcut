import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final perms = ref.watch(permissionsControllerProvider);
    final theme = ref.watch(themeControllerProvider);

    return NeumorphicBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Row(
              children: [
                NeumorphicButton(
                  onPressed: () => Navigator.pop(context),
                  style: NeumorphicStyle(
                    color: p.surfaceVariant,
                    depth: 2,
                    boxShape: const NeumorphicBoxShape.circle(),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_rounded, color: p.onBackground),
                ),
                const SizedBox(width: 10),
                Text('Settings', style: AppTypography.title(p.onBackground)),
              ],
            ),
            const SizedBox(height: 16),

            Text('Appearance', style: AppTypography.subtitle(p.onBackground)),
            const SizedBox(height: 10),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme mode',
                    style: AppTypography.subtitle(p.onBackground),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ThemeChip(
                        label: 'System',
                        selected: theme.mode == ThemeMode.system,
                        onTap: () => ref
                            .read(themeControllerProvider.notifier)
                            .setMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: 'Light',
                        selected: theme.mode == ThemeMode.light,
                        onTap: () => ref
                            .read(themeControllerProvider.notifier)
                            .setMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: 'Dark',
                        selected: theme.mode == ThemeMode.dark,
                        onTap: () => ref
                            .read(themeControllerProvider.notifier)
                            .setMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text('System', style: AppTypography.subtitle(p.onBackground)),
            const SizedBox(height: 10),
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusRow(label: 'VPN permission', ok: perms.vpnGranted),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Notifications',
                    ok:
                        !perms.notificationsRequired ||
                        perms.notificationsGranted,
                    note: perms.notificationsRequired
                        ? 'Required on Android 13+'
                        : 'Not required',
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    label: 'Battery unrestricted',
                    ok: perms.ignoringBatteryOptimizations,
                    note: 'Recommended',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => ref
                              .read(permissionsControllerProvider.notifier)
                              .refresh(),
                          style: NeumorphicStyle(
                            color: p.surfaceVariant,
                            depth: 2,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(14),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Refresh',
                              style: AppTypography.button(p.onBackground),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => ref
                              .read(permissionsControllerProvider.notifier)
                              .openBatterySettings(),
                          style: NeumorphicStyle(
                            color: p.surfaceVariant,
                            depth: 2,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(14),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Battery settings',
                              style: AppTypography.button(p.onBackground),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text('About', style: AppTypography.subtitle(p.onBackground)),
            const SizedBox(height: 10),
            _Section(
              child: Text(
                'NetCut blocks internet for selected apps using a local VPN.\n'
                'All processing can be kept on-device.',
                style: AppTypography.body(p.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: NeumorphicButton(
        onPressed: onTap,
        style: NeumorphicStyle(
          color: selected ? p.primaryContainer : p.surface,
          depth: 2,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(label, style: AppTypography.button(p.onBackground)),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Neumorphic(
      style: NeumorphicStyle(
        color: p.surface,
        depth: 2,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ok;
  final String? note;

  const _StatusRow({required this.label, required this.ok, this.note});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.subtitle(p.onBackground)),
              if (note != null) ...[
                const SizedBox(height: 2),
                Text(note!, style: AppTypography.bodySmall(p.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        Icon(
          ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          color: ok ? p.secondary : p.error,
        ),
      ],
    );
  }
}
