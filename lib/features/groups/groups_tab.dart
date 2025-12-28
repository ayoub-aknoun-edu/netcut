import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
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
                        Icons.create_new_folder_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Create Group',
                        style: AppTypography.headline(p.onBackground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: c,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'e.g., Social Media',
                    filled: true,
                    fillColor: p.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: AppTypography.body(p.onBackground),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (c.text.trim().isEmpty) return;
                      await ref
                          .read(groupsControllerProvider.notifier)
                          .createGroup(c.text);
                      if (context.mounted) Navigator.pop(context);
                    },
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
                      'Create Group',
                      style: AppTypography.button(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final state = ref.watch(groupsControllerProvider);

    if (state.loading) {
      return Center(child: CircularProgressIndicator(color: p.primary));
    }

    return Column(
      children: [
        // Header with create button
        Row(
          children: [
            Expanded(
              child: Text(
                'App Groups',
                style: AppTypography.headline(p.onBackground),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [p.primary, p.secondary]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: p.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _createDialog(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Groups list
        Expanded(
          child: state.groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 80,
                        color: p.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No groups yet',
                        style: AppTypography.subtitle(p.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a group to organize your apps',
                        style: AppTypography.bodySmall(p.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: state.groups.length,
                  itemBuilder: (_, i) {
                    final g = state.groups[i];
                    return _GroupCard(
                          group: g,
                          onTap: () {
                            Navigator.of(context).push(
                              NeumorphicPageRoute(
                                builder: (_) =>
                                    GroupDetailScreen(groupId: g.id),
                              ),
                            );
                          },
                          onEdit: () =>
                              GroupAppsEditorSheet.show(context, groupId: g.id),
                          onToggle: (v) => ref
                              .read(groupsControllerProvider.notifier)
                              .toggleGroup(g.id, v),
                          palette: p,
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
                  },
                ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final dynamic group;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final ColorPalette palette;

  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: group.enabled
              ? palette.primary.withOpacity(0.3)
              : palette.outline,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: group.enabled
                ? palette.primary.withOpacity(0.15)
                : palette.shadow,
            blurRadius: group.enabled ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Group icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: group.enabled
                        ? LinearGradient(
                            colors: [palette.primary, palette.secondary],
                          )
                        : null,
                    color: group.enabled ? null : palette.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    group.enabled
                        ? Icons.folder_rounded
                        : Icons.folder_outlined,
                    color: group.enabled
                        ? Colors.white
                        : palette.onSurfaceVariant,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Group info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: AppTypography.subtitle(palette.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.apps_rounded,
                            size: 14,
                            color: palette.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.packageNames.length} apps',
                            style: AppTypography.bodySmall(
                              palette.onSurfaceVariant,
                            ),
                          ),
                          if (group.enabled) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: AppTypography.label(
                                  Colors.green,
                                ).copyWith(fontSize: 9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Edit button
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, size: 22),
                  color: palette.onSurfaceVariant,
                  style: IconButton.styleFrom(
                    backgroundColor: palette.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Toggle
                GestureDetector(
                  onTap: () => onToggle(!group.enabled),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: group.enabled
                          ? LinearGradient(
                              colors: [palette.primary, palette.secondary],
                            )
                          : null,
                      color: group.enabled ? null : palette.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: group.enabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
