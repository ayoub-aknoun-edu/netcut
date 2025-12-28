import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import '../apps/apps_tab.dart';
import '../groups/groups_tab.dart';
import '../insights/insights_tab.dart';
import '../settings/settings_screen.dart';
import '../../routing/neumorphic_page_route.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(appsControllerProvider.notifier);
      ref.read(groupsControllerProvider.notifier);
      ref.read(directBlocksControllerProvider.notifier);
      await ref.read(permissionsControllerProvider.notifier).refresh();
      await ref.read(firewallControllerProvider.notifier).syncFromRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final firewall = ref.watch(firewallControllerProvider);
    final perms = ref.watch(permissionsControllerProvider);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern app bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  // App icon + title
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [p.primary, p.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NetCut',
                          style: AppTypography.headline(
                            p.onBackground,
                          ).copyWith(fontSize: 22),
                        ),
                        Text(
                          'Internet Firewall',
                          style: AppTypography.bodySmall(p.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  // Settings button
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        NeumorphicPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings_rounded, size: 26),
                    color: p.onSurfaceVariant,
                    style: IconButton.styleFrom(
                      backgroundColor: p.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Firewall status card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:
                  _FirewallCard(
                        enabled: firewall.enabled,
                        running: firewall.running,
                        starting: firewall.starting,
                        blockedCount: firewall.blockedPackages.length,
                        requiredOk: perms.requiredOk,
                        onToggle: (v) async {
                          if (!perms.requiredOk) {
                            await ref
                                .read(permissionsControllerProvider.notifier)
                                .refresh();
                            return;
                          }
                          await ref
                              .read(firewallControllerProvider.notifier)
                              .setEnabled(v);
                        },
                        onInfo: () => _showWhatBlockingMeans(context),
                        palette: p,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
            ),

            const SizedBox(height: 20),

            // Modern tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ModernTabs(
                index: _tab,
                labels: const ['Apps', 'Groups', 'Insights'],
                onChanged: (i) => setState(() => _tab = i),
                palette: p,
              ),
            ),

            const SizedBox(height: 20),

            // Tab content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: switch (_tab) {
                    0 => const AppsTab(key: ValueKey('apps')),
                    1 => const GroupsTab(key: ValueKey('groups')),
                    _ => const InsightsTab(key: ValueKey('insights')),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWhatBlockingMeans(BuildContext context) {
    final p = context.palette;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [p.primary, p.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.info_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'How It Works',
                      style: AppTypography.headline(p.onBackground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoPoint(
                icon: Icons.vpn_lock_rounded,
                title: 'Local VPN Technology',
                description:
                    'NetCut creates a secure local VPN tunnel on your device',
                palette: p,
              ),
              const SizedBox(height: 16),
              _InfoPoint(
                icon: Icons.block_rounded,
                title: 'Selective Blocking',
                description:
                    'Only selected apps are routed through the VPN and blocked',
                palette: p,
              ),
              const SizedBox(height: 16),
              _InfoPoint(
                icon: Icons.check_circle_rounded,
                title: 'Other Apps Normal',
                description:
                    'All other apps continue with regular internet access',
                palette: p,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Got it',
                    style: AppTypography.button(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Info point widget
class _InfoPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorPalette palette;

  const _InfoPoint({
    required this.icon,
    required this.title,
    required this.description,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: palette.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.subtitle(palette.onBackground)),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall(palette.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Modern firewall card
class _FirewallCard extends StatelessWidget {
  final bool enabled;
  final bool running;
  final bool starting;
  final int blockedCount;
  final bool requiredOk;
  final ValueChanged<bool> onToggle;
  final VoidCallback onInfo;
  final ColorPalette palette;

  const _FirewallCard({
    required this.enabled,
    required this.running,
    required this.starting,
    required this.blockedCount,
    required this.requiredOk,
    required this.onToggle,
    required this.onInfo,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = requiredOk && (enabled || running);

    final statusText = !requiredOk
        ? 'Setup needed'
        : starting
        ? 'Starting…'
        : enabled && running
        ? 'Active'
        : !enabled && running
        ? 'Stopping…'
        : enabled
        ? 'Ready'
        : 'Inactive';

    final statusColor = !requiredOk
        ? Colors.orange
        : isActive
        ? Colors.green
        : palette.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.primary.withOpacity(0.1),
                  palette.secondary.withOpacity(0.08),
                ],
              )
            : null,
        color: isActive ? null : palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? palette.primary.withOpacity(0.3) : palette.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? palette.primary.withOpacity(0.2) : palette.shadow,
            blurRadius: isActive ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onToggle(!isActive),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Status indicator with animation
                    Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      palette.primary,
                                      palette.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isActive ? null : palette.surfaceVariant,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: palette.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isActive
                                ? Icons.shield_rounded
                                : Icons.shield_outlined,
                            color: isActive
                                ? Colors.white
                                : palette.onSurfaceVariant,
                            size: 40,
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              isActive ? controller.repeat() : null,
                        )
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

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'VPN Firewall',
                                style: AppTypography.headline(
                                  palette.onBackground,
                                ).copyWith(fontSize: 20),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isActive)
                                      Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                          .animate(
                                            onPlay: (controller) =>
                                                controller.repeat(),
                                          )
                                          .fadeOut(duration: 1000.ms)
                                          .then()
                                          .fadeIn(duration: 1000.ms),
                                    if (isActive) const SizedBox(width: 6),
                                    Text(
                                      statusText.toUpperCase(),
                                      style: AppTypography.label(
                                        statusColor,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (isActive)
                            Row(
                              children: [
                                Icon(
                                  Icons.block_rounded,
                                  size: 16,
                                  color: palette.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$blockedCount apps blocked',
                                  style: AppTypography.bodySmall(
                                    palette.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'Tap to enable protection',
                              style: AppTypography.bodySmall(
                                palette.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Info button
                    IconButton(
                      onPressed: onInfo,
                      icon: Icon(Icons.info_outline_rounded, size: 24),
                      color: palette.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        backgroundColor: palette.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern tabs
class _ModernTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;
  final ColorPalette palette;

  const _ModernTabs({
    required this.index,
    required this.labels,
    required this.onChanged,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: i == index
                        ? LinearGradient(
                            colors: [palette.primary, palette.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: palette.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style:
                          AppTypography.button(
                            i == index
                                ? Colors.white
                                : palette.onSurfaceVariant,
                          ).copyWith(
                            fontWeight: i == index
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
