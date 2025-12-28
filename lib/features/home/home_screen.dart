import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // ensure initial loads
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

    final title = switch (_tab) {
      0 => 'Apps',
      1 => 'Groups',
      _ => 'Insights',
    };

    return NeumorphicBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'NetCut • $title',
                      style: AppTypography.title(p.onBackground),
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        NeumorphicPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    style: NeumorphicStyle(
                      color: p.surface,
                      depth: 2,
                      boxShape: const NeumorphicBoxShape.circle(),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.settings_rounded, color: p.onBackground),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FirewallCard(
                enabled: firewall.enabled,
                running: firewall.running,
                starting: firewall.starting,
                blockedCount: firewall.blockedPackages.length,
                requiredOk: perms.requiredOk,
                onToggle: (v) async {
                  if (!perms.requiredOk) {
                    // Force setup screen by refreshing permission state.
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
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _NeumorphicTabs(
                index: _tab,
                labels: const ['Apps', 'Groups', 'Insights'],
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: switch (_tab) {
                  0 => const AppsTab(),
                  1 => const GroupsTab(),
                  _ => const InsightsTab(),
                },
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
      backgroundColor: p.surface,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What “Blocking” means',
                style: AppTypography.title(p.onBackground),
              ),
              const SizedBox(height: 8),
              Text(
                'NetCut uses a local VPN to route only the selected apps into a virtual network interface, then drops their packets.\n\n'
                'Result: those apps have no internet (Wi-Fi & mobile data), while other apps keep normal connectivity.',
                style: AppTypography.body(p.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              NeumorphicButton(
                onPressed: () => Navigator.pop(context),
                style: NeumorphicStyle(
                  color: p.primaryContainer,
                  depth: 2,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Got it',
                    style: AppTypography.button(p.onBackground),
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

class _FirewallCard extends StatelessWidget {
  final bool enabled;
  final bool running;
  final bool starting;
  final int blockedCount;
  final bool requiredOk;
  final ValueChanged<bool> onToggle;
  final VoidCallback onInfo;

  const _FirewallCard({
    required this.enabled,
    required this.running,
    required this.starting,
    required this.blockedCount,
    required this.requiredOk,
    required this.onToggle,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final statusText = !requiredOk
        ? 'Setup needed'
        : starting
        ? 'Starting…'
        : enabled && running
        ? 'Firewall ON • $blockedCount apps blocked'
        : !enabled && running
        ? 'Stopping… (VPN still active)'
        : enabled
        ? 'Enabled • not running'
        : 'Firewall OFF';

    return Neumorphic(
      style: NeumorphicStyle(
        color: p.surface,
        depth: 3,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local VPN Firewall',
                  style: AppTypography.subtitle(p.onBackground),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: AppTypography.bodySmall(p.onSurfaceVariant),
                ),
              ],
            ),
          ),
          NeumorphicButton(
            onPressed: onInfo,
            style: NeumorphicStyle(
              color: p.surfaceVariant,
              depth: 2,
              boxShape: const NeumorphicBoxShape.circle(),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.info_outline_rounded, color: p.onBackground),
          ),
          const SizedBox(width: 10),
          NeumorphicSwitch(
            value: requiredOk && (enabled || running),
            onChanged: requiredOk ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

class _NeumorphicTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _NeumorphicTabs({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          Expanded(
            child: NeumorphicButton(
              onPressed: () => onChanged(i),
              style: NeumorphicStyle(
                color: i == index ? p.primaryContainer : p.surface,
                depth: i == index ? 1 : 2,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  labels[i],
                  style: AppTypography.button(p.onBackground),
                ),
              ),
            ),
          ),
          if (i != labels.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
