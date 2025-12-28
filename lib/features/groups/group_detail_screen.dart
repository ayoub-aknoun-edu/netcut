import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
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

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern app bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
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
                  Expanded(
                    child: Text(
                      g.name,
                      style: AppTypography.headline(p.onBackground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        GroupAppsEditorSheet.show(context, groupId: g.id),
                    icon: Icon(Icons.edit_rounded, size: 22),
                    color: p.onBackground,
                    style: IconButton.styleFrom(
                      backgroundColor: p.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await _showDeleteConfirmation(
                        context,
                        p,
                      );
                      if (confirmed == true) {
                        await ref
                            .read(groupsControllerProvider.notifier)
                            .deleteGroup(g.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.delete_rounded, size: 22),
                    color: p.error,
                    style: IconButton.styleFrom(
                      backgroundColor: p.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Status card
                  Container(
                    decoration: BoxDecoration(
                      gradient: g.enabled
                          ? LinearGradient(
                              colors: [
                                p.primary.withOpacity(0.1),
                                p.secondary.withOpacity(0.08),
                              ],
                            )
                          : null,
                      color: g.enabled ? null : p.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: g.enabled
                            ? p.primary.withOpacity(0.3)
                            : p.outline,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: g.enabled
                              ? p.primary.withOpacity(0.15)
                              : p.shadow,
                          blurRadius: g.enabled ? 16 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: g.enabled
                                ? LinearGradient(
                                    colors: [p.primary, p.secondary],
                                  )
                                : null,
                            color: g.enabled ? null : p.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            g.enabled
                                ? Icons.shield_rounded
                                : Icons.shield_outlined,
                            color: g.enabled
                                ? Colors.white
                                : p.onSurfaceVariant,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.enabled
                                    ? 'Group Blocking Active'
                                    : 'Group Blocking Disabled',
                                style: AppTypography.subtitle(p.onBackground),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                g.enabled
                                    ? 'All apps in this group are blocked'
                                    : 'Toggle to block all apps',
                                style: AppTypography.bodySmall(
                                  p.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref
                              .read(groupsControllerProvider.notifier)
                              .toggleGroup(g.id, !g.enabled),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: g.enabled
                                  ? LinearGradient(
                                      colors: [p.primary, p.secondary],
                                    )
                                  : null,
                              color: g.enabled ? null : p.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: g.enabled
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
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Apps section header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Apps in this group',
                          style: AppTypography.headline(
                            p.onBackground,
                          ).copyWith(fontSize: 18),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${g.packageNames.length}',
                          style: AppTypography.button(
                            p.primary,
                          ).copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Apps list
                  if (g.packageNames.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.apps_outlined,
                            size: 64,
                            color: p.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No apps yet',
                            style: AppTypography.subtitle(p.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the edit button to add apps',
                            style: AppTypography.bodySmall(p.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...g.packageNames.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pkg = entry.value;
                      final app = appsByPackage[pkg];
                      final label = app?.label ?? pkg;

                      return _AppInGroupCard(
                            packageName: pkg,
                            label: label,
                            iconPng: app?.iconPng,
                            onRemove: () {
                              final next = g.packageNames
                                  .where((x) => x != pkg)
                                  .toList();
                              ref
                                  .read(groupsControllerProvider.notifier)
                                  .setGroupApps(g.id, next);
                            },
                            palette: p,
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                          .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
                    }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, ColorPalette p) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: p.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete Group?',
              style: AppTypography.headline(p.onBackground),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete the group. Apps will not be affected.',
          style: AppTypography.body(p.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button(p.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Delete', style: AppTypography.button(Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AppInGroupCard extends StatelessWidget {
  final String packageName;
  final String label;
  final Uint8List? iconPng;
  final VoidCallback onRemove;
  final ColorPalette palette;

  const _AppInGroupCard({
    required this.packageName,
    required this.label,
    required this.iconPng,
    required this.onRemove,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AppIcon(
              packageName: packageName,
              iconPng: iconPng,
              size: 56,
              radius: 16,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.subtitle(palette.onBackground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    packageName,
                    style: AppTypography.bodySmall(palette.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, size: 22),
              color: palette.error,
              style: IconButton.styleFrom(
                backgroundColor: palette.errorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
