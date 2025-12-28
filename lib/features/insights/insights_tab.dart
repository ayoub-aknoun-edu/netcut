import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final direct = ref.watch(directBlocksControllerProvider).blocked.length;
    final groups = ref.watch(groupsControllerProvider).groups;
    final enabledGroups = groups.where((g) => g.enabled).toList();
    final enabledGroupApps = <String>{};
    for (final g in enabledGroups) {
      enabledGroupApps.addAll(g.packageNames);
    }

    return ListView(
      children: [
        Text('Overview', style: AppTypography.headline(p.onBackground)),
        const SizedBox(height: 12),

        _MetricCard(
          title: 'Directly blocked apps',
          value: '$direct',
          subtitle: 'Apps you toggled in the Apps tab',
        ),
        const SizedBox(height: 10),
        _MetricCard(
          title: 'Enabled groups',
          value: '${enabledGroups.length}',
          subtitle: 'Groups currently enforcing blocks',
        ),
        const SizedBox(height: 10),
        _MetricCard(
          title: 'Apps blocked by groups',
          value: '${enabledGroupApps.length}',
          subtitle: 'Unique apps across enabled groups',
        ),
        const SizedBox(height: 14),

        Text('Enabled groups', style: AppTypography.title(p.onBackground)),
        const SizedBox(height: 10),
        if (enabledGroups.isEmpty)
          Text(
            'No enabled groups.',
            style: AppTypography.body(p.onSurfaceVariant),
          )
        else
          ...enabledGroups.map((g) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Neumorphic(
                style: NeumorphicStyle(
                  color: p.surface,
                  depth: 2,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.name,
                        style: AppTypography.subtitle(p.onBackground),
                      ),
                    ),
                    Text(
                      '${g.packageNames.length}',
                      style: AppTypography.subtitle(p.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle(p.onBackground)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(p.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(value, style: AppTypography.display(p.primary)),
        ],
      ),
    );
  }
}
