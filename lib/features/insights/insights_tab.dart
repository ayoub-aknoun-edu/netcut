import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final direct = ref.watch(directBlocksControllerProvider);
    final groups = ref.watch(groupsControllerProvider);
    final firewall = ref.watch(firewallControllerProvider);

    final totalApps = ref.watch(appsControllerProvider).apps.length;
    final blockedApps = direct.blocked.length;
    final activeGroups = groups.groups.where((g) => g.enabled).length;
    final totalGroups = groups.groups.length;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Text('Overview', style: AppTypography.headline(p.onBackground)),
        const SizedBox(height: 16),

        // Stats grid
        Row(
          children: [
            Expanded(
              child:
                  _StatCard(
                        icon: Icons.shield_rounded,
                        label: 'Protection',
                        value: firewall.enabled ? 'Active' : 'Inactive',
                        color: firewall.enabled
                            ? Colors.green
                            : p.onSurfaceVariant,
                        palette: p,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOut,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  _StatCard(
                        icon: Icons.block_rounded,
                        label: 'Blocked Apps',
                        value: blockedApps.toString(),
                        color: p.primary,
                        palette: p,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOut,
                      ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child:
                  _StatCard(
                        icon: Icons.folder_rounded,
                        label: 'Active Groups',
                        value: '$activeGroups/$totalGroups',
                        color: p.secondary,
                        palette: p,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 200.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOut,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  _StatCard(
                        icon: Icons.apps_rounded,
                        label: 'Total Apps',
                        value: totalApps.toString(),
                        color: p.accent,
                        palette: p,
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOut,
                      ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text('Quick Actions', style: AppTypography.headline(p.onBackground)),
        const SizedBox(height: 16),

        _ActionCard(
              icon: Icons.security_rounded,
              title: 'How NetCut Works',
              description: 'Learn about VPN-based blocking',
              color: p.primary,
              onTap: () => _showHowItWorks(context, p),
              palette: p,
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: 400.ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 12),

        _ActionCard(
              icon: Icons.tips_and_updates_rounded,
              title: 'Tips & Best Practices',
              description: 'Get the most out of NetCut',
              color: p.secondary,
              onTap: () => _showTips(context, p),
              palette: p,
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: 500.ms)
            .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),
      ],
    );
  }

  void _showHowItWorks(BuildContext context, ColorPalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InfoBottomSheet(
        title: 'How NetCut Works',
        icon: Icons.security_rounded,
        items: [
          _InfoItem(
            icon: Icons.vpn_key_rounded,
            title: 'VPN Technology',
            description:
                'NetCut uses Android\'s VPN service to intercept network traffic',
          ),
          _InfoItem(
            icon: Icons.filter_alt_rounded,
            title: 'Selective Filtering',
            description:
                'Only traffic from selected apps is routed through the VPN',
          ),
          _InfoItem(
            icon: Icons.block_rounded,
            title: 'Traffic Blocking',
            description:
                'Filtered traffic is dropped, effectively blocking internet',
          ),
          _InfoItem(
            icon: Icons.security_rounded,
            title: 'Privacy First',
            description:
                'All blocking happens locally. No data leaves your device',
          ),
        ],
        palette: p,
      ),
    );
  }

  void _showTips(BuildContext context, ColorPalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InfoBottomSheet(
        title: 'Tips & Best Practices',
        icon: Icons.tips_and_updates_rounded,
        items: [
          _InfoItem(
            icon: Icons.group_work_rounded,
            title: 'Use Groups',
            description:
                'Organize similar apps into groups for easier management',
          ),
          _InfoItem(
            icon: Icons.battery_saver_rounded,
            title: 'Battery Impact',
            description:
                'VPN services use minimal battery. No significant impact',
          ),
          _InfoItem(
            icon: Icons.speed_rounded,
            title: 'Performance',
            description:
                'Unblocked apps maintain full speed as traffic isn\'t routed',
          ),
          _InfoItem(
            icon: Icons.restart_alt_rounded,
            title: 'Reboot Safe',
            description: 'Settings persist across device reboots automatically',
          ),
        ],
        palette: p,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ColorPalette palette;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headline(
              palette.onBackground,
            ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall(palette.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final ColorPalette palette;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.subtitle(palette.onBackground),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodySmall(
                          palette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _InfoBottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;
  final ColorPalette palette;

  const _InfoBottomSheet({
    required this.title,
    required this.icon,
    required this.items,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.primary, palette.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headline(palette.onBackground),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded),
                  color: palette.onSurfaceVariant,
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final item = items[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: palette.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.subtitle(palette.onBackground),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: AppTypography.body(palette.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
