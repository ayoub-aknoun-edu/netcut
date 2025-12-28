import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
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

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, size: 26),
                      color: p.onBackground,
                      style: IconButton.styleFrom(
                        backgroundColor: p.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Settings',
                      style: AppTypography.headline(p.onBackground),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // Appearance Section
            _SectionHeader(
              icon: Icons.palette_rounded,
              title: 'Appearance',
              palette: p,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            const SizedBox(height: 12),

            _SettingsCard(
                  palette: p,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [p.primary, p.secondary],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.brightness_6_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Theme Mode',
                            style: AppTypography.subtitle(p.onBackground),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ThemeChip(
                              label: 'System',
                              icon: Icons.phone_android_rounded,
                              selected: theme.mode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeControllerProvider.notifier)
                                  .setMode(ThemeMode.system),
                              palette: p,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Light',
                              icon: Icons.light_mode_rounded,
                              selected: theme.mode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeControllerProvider.notifier)
                                  .setMode(ThemeMode.light),
                              palette: p,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Dark',
                              icon: Icons.dark_mode_rounded,
                              selected: theme.mode == ThemeMode.dark,
                              onTap: () => ref
                                  .read(themeControllerProvider.notifier)
                                  .setMode(ThemeMode.dark),
                              palette: p,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // System Section
            _SectionHeader(
              icon: Icons.admin_panel_settings_rounded,
              title: 'Permissions & System',
              palette: p,
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

            const SizedBox(height: 12),

            _SettingsCard(
                  palette: p,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PermissionRow(
                        icon: Icons.vpn_key_rounded,
                        label: 'VPN Permission',
                        ok: perms.vpnGranted,
                        required: true,
                        palette: p,
                      ),
                      const SizedBox(height: 14),
                      Divider(color: p.outline, height: 1),
                      const SizedBox(height: 14),
                      _PermissionRow(
                        icon: Icons.notifications_rounded,
                        label: 'Notifications',
                        ok:
                            !perms.notificationsRequired ||
                            perms.notificationsGranted,
                        required: perms.notificationsRequired,
                        note: perms.notificationsRequired
                            ? 'Required on Android 13+'
                            : 'Not required',
                        palette: p,
                      ),
                      const SizedBox(height: 14),
                      Divider(color: p.outline, height: 1),
                      const SizedBox(height: 14),
                      _PermissionRow(
                        icon: Icons.battery_charging_full_rounded,
                        label: 'Battery Unrestricted',
                        ok: perms.ignoringBatteryOptimizations,
                        required: false,
                        note: 'Recommended for reliability',
                        palette: p,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(permissionsControllerProvider.notifier)
                                  .refresh(),
                              icon: Icon(Icons.refresh_rounded, size: 20),
                              label: Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.surfaceVariant,
                                foregroundColor: p.onBackground,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(permissionsControllerProvider.notifier)
                                  .openBatterySettings(),
                              icon: Icon(Icons.settings_rounded, size: 20),
                              label: Text('Battery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // About Section
            _SectionHeader(
              icon: Icons.info_rounded,
              title: 'About NetCut',
              palette: p,
            ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

            const SizedBox(height: 12),

            _SettingsCard(
                  palette: p,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [p.primary, p.secondary],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: p.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NetCut',
                                  style: AppTypography.headline(
                                    p.onBackground,
                                  ).copyWith(fontSize: 20),
                                ),
                                Text(
                                  'Version 1.0.0',
                                  style: AppTypography.bodySmall(
                                    p.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'NetCut blocks internet for selected apps using a local VPN. '
                          'All processing happens on-device. Your privacy is protected.',
                          style: AppTypography.body(p.onBackground),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.security_rounded,
                        label: 'Privacy First',
                        value: 'No data collection',
                        palette: p,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.speed_rounded,
                        label: 'Performance',
                        value: 'Minimal battery impact',
                        palette: p,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.lock_rounded,
                        label: 'No Root Required',
                        value: 'Works on all devices',
                        palette: p,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorPalette palette;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: palette.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.headline(
            palette.onBackground,
          ).copyWith(fontSize: 18),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final ColorPalette palette;

  const _SettingsCard({required this.child, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ColorPalette palette;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [palette.primary, palette.secondary])
              : null,
          color: selected ? null : palette.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: palette.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : palette.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.label(
                selected ? Colors.white : palette.onBackground,
              ).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ok;
  final bool required;
  final String? note;
  final ColorPalette palette;

  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.ok,
    required this.required,
    this.note,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ok ? Colors.green.withOpacity(0.15) : palette.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: ok ? Colors.green : palette.error, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: AppTypography.subtitle(palette.onBackground),
                  ),
                  if (required) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'REQUIRED',
                        style: AppTypography.label(
                          palette.error,
                        ).copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ],
              ),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  note!,
                  style: AppTypography.bodySmall(palette.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ok ? Colors.green.withOpacity(0.15) : palette.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            ok ? Icons.check_rounded : Icons.close_rounded,
            color: ok ? Colors.green : palette.error,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorPalette palette;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: palette.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTypography.body(palette.onBackground)),
        ),
        Text(value, style: AppTypography.bodySmall(palette.onSurfaceVariant)),
      ],
    );
  }
}
