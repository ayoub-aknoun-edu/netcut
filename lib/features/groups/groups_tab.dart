import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import 'group_detail_screen.dart';
import '../../routing/neumorphic_page_route.dart';
import 'group_apps_editor_sheet.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final p = context.palette;
    final c = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: p.surface,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create group', style: AppTypography.title(p.onBackground)),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                decoration: const InputDecoration(
                  hintText: 'e.g., Social media',
                ),
              ),
              const SizedBox(height: 12),
              NeumorphicButton(
                onPressed: () async {
                  await ref
                      .read(groupsControllerProvider.notifier)
                      .createGroup(c.text);
                  if (context.mounted) Navigator.pop(context);
                },
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
                    'Create',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(groupsControllerProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Groups',
                style: AppTypography.headline(p.onBackground),
              ),
            ),
            NeumorphicButton(
              onPressed: () => _createDialog(context, ref),
              style: NeumorphicStyle(
                color: p.primaryContainer,
                depth: 2,
                boxShape: const NeumorphicBoxShape.circle(),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.add_rounded, color: p.onBackground),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: state.groups.isEmpty
              ? Center(
                  child: Text(
                    'No groups yet.',
                    style: AppTypography.body(p.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (_, i) {
                    final g = state.groups[i];
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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    NeumorphicPageRoute(
                                      builder: (_) =>
                                          GroupDetailScreen(groupId: g.id),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.name,
                                      style: AppTypography.subtitle(
                                        p.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${g.packageNames.length} apps',
                                      style: AppTypography.bodySmall(
                                        p.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            NeumorphicButton(
                              onPressed: () => GroupAppsEditorSheet.show(
                                context,
                                groupId: g.id,
                              ),
                              style: NeumorphicStyle(
                                color: p.surfaceVariant,
                                depth: 2,
                                boxShape:
                                    const NeumorphicBoxShape.circle(),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.playlist_add_rounded,
                                color: p.onBackground,
                              ),
                            ),
                            const SizedBox(width: 10),
                            NeumorphicSwitch(
                              value: g.enabled,
                              onChanged: (v) => ref
                                  .read(groupsControllerProvider.notifier)
                                  .toggleGroup(g.id, v),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
