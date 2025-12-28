import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import '../apps/widgets/app_icon.dart';
import 'group_apps_editor_sheet.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final groups = ref.watch(groupsControllerProvider).groups;
    final g = groups.firstWhere((x) => x.id == groupId);

    final appsByPackage = ref.watch(appsByPackageProvider);

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
                Expanded(
                  child: Text(
                    g.name,
                    style: AppTypography.title(p.onBackground),
                  ),
                ),
                NeumorphicButton(
                  onPressed: () => GroupAppsEditorSheet.show(
                    context,
                    groupId: g.id,
                  ),
                  style: NeumorphicStyle(
                    color: p.surfaceVariant,
                    depth: 2,
                    boxShape: const NeumorphicBoxShape.circle(),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.playlist_add_rounded,
                    color: p.onBackground,
                  ),
                ),
                const SizedBox(width: 10),
                NeumorphicButton(
                  onPressed: () async {
                    await ref
                        .read(groupsControllerProvider.notifier)
                        .deleteGroup(g.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: NeumorphicStyle(
                    color: p.errorContainer,
                    depth: 2,
                    boxShape: const NeumorphicBoxShape.circle(),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: p.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Neumorphic(
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
                      g.enabled
                          ? 'Group blocking enabled'
                          : 'Group blocking disabled',
                      style: AppTypography.subtitle(p.onBackground),
                    ),
                  ),
                  NeumorphicSwitch(
                    value: g.enabled,
                    onChanged: (v) => ref
                        .read(groupsControllerProvider.notifier)
                        .toggleGroup(g.id, v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Apps in this group',
              style: AppTypography.headline(p.onBackground),
            ),
            const SizedBox(height: 10),
            if (g.packageNames.isEmpty)
              Text(
                'No apps yet.',
                style: AppTypography.body(p.onSurfaceVariant),
              )
            else
              ...g.packageNames.map((pkg) {
                final app = appsByPackage[pkg];
                final label = app?.label ?? pkg;

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
                        AppIcon(
                          packageName: pkg,
                          iconPng: app?.iconPng,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: AppTypography.subtitle(p.onBackground),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pkg,
                                style: AppTypography.bodySmall(
                                  p.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        NeumorphicButton(
                          onPressed: () {
                            final next = g.packageNames
                                .where((x) => x != pkg)
                                .toList();
                            ref
                                .read(groupsControllerProvider.notifier)
                                .setGroupApps(g.id, next);
                          },
                          style: NeumorphicStyle(
                            color: p.surfaceVariant,
                            depth: 2,
                            boxShape: const NeumorphicBoxShape.circle(),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.close_rounded,
                            color: p.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
