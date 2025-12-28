import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';

class AppsTab extends ConsumerStatefulWidget {
  const AppsTab({super.key});

  @override
  ConsumerState<AppsTab> createState() => _AppsTabState();
}

class _AppsTabState extends ConsumerState<AppsTab> {
  String _q = '';
  bool _blockedOnly = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final appsState = ref.watch(appsControllerProvider);
    final direct = ref.watch(directBlocksControllerProvider);
    final groupsState = ref.watch(groupsControllerProvider);

    final allApps = appsState.apps;

    final filtered = allApps.where((a) {
      if (_q.trim().isNotEmpty) {
        final q = _q.toLowerCase();
        final hit =
            a.label.toLowerCase().contains(q) ||
            a.packageName.toLowerCase().contains(q);
        if (!hit) return false;
      }
      if (_blockedOnly && !direct.blocked.contains(a.packageName)) return false;
      return true;
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Neumorphic(
                style: NeumorphicStyle(
                  color: p.surface,
                  depth: 2,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: p.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MaterialHost(
                        child: TextField(
                          onChanged: (v) => setState(() => _q = v),
                          cursorColor: p.primary,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Search apps…',
                            hintStyle: AppTypography.body(p.onSurfaceVariant),
                          ),
                          style: AppTypography.body(p.onBackground),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            NeumorphicButton(
              onPressed: () => setState(() => _blockedOnly = !_blockedOnly),
              style: NeumorphicStyle(
                color: _blockedOnly ? p.primaryContainer : p.surface,
                depth: 2,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(14),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                'Blocked',
                style: AppTypography.button(p.onBackground),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: appsState.loading
              ? const Center(child: Text('Loading…'))
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    final isDirectBlocked = direct.blocked.contains(
                      app.packageName,
                    );

                    final appGroups = groupsState.groups
                        .where((g) => g.packageNames.contains(app.packageName))
                        .toList();

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
                            _AppIcon(iconPng: app.iconPng),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.label,
                                    style: AppTypography.subtitle(
                                      p.onBackground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    app.packageName,
                                    style: AppTypography.bodySmall(
                                      p.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (appGroups.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: appGroups.map((g) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: p.surfaceVariant,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            g.name,
                                            style: AppTypography.label(
                                              p.onBackground,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                NeumorphicSwitch(
                                  value: isDirectBlocked,
                                  onChanged: (v) {
                                    ref
                                        .read(
                                          directBlocksControllerProvider
                                              .notifier,
                                        )
                                        .setBlocked(app.packageName, v);
                                  },
                                ),
                                const SizedBox(height: 8),
                                NeumorphicButton(
                                  onPressed: () => _openGroupsSheet(
                                    context,
                                    app.packageName,
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
                              ],
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

  void _openGroupsSheet(BuildContext context, String pkg) {
    final p = context.palette;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer(
          builder: (context, ref, __) {
            final groups = ref.watch(groupsControllerProvider).groups;

            return DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.35,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: p.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Add to groups',
                                style: AppTypography.title(p.onBackground),
                              ),
                            ),
                            NeumorphicButton(
                              onPressed: () => Navigator.pop(context),
                              style: NeumorphicStyle(
                                color: p.surfaceVariant,
                                depth: 1,
                                boxShape: const NeumorphicBoxShape.circle(),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.close_rounded,
                                color: p.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: groups.isEmpty
                            ? Center(
                                child: Text(
                                  'Create a group first.',
                                  style: AppTypography.body(p.onSurfaceVariant),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  18,
                                ),
                                itemCount: groups.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final g = groups[i];
                                  final inGroup = g.packageNames.contains(pkg);

                                  return NeumorphicButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                            groupsControllerProvider.notifier,
                                          )
                                          .setAppInGroup(
                                            groupId: g.id,
                                            packageName: pkg,
                                            inGroup: !inGroup,
                                          );
                                    },
                                    style: NeumorphicStyle(
                                      color: inGroup
                                          ? p.primaryContainer
                                          : p.surfaceVariant,
                                      depth: 2,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(14),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            g.name,
                                            style: AppTypography.subtitle(
                                              p.onBackground,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          inGroup
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          color: inGroup
                                              ? p.secondary
                                              : p.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Invisible Material ancestor for Material widgets (TextField, etc).
/// TextField requires a Material widget ancestor. :contentReference[oaicite:1]{index=1}
class _MaterialHost extends StatelessWidget {
  final Widget child;
  const _MaterialHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(type: MaterialType.transparency, child: child);
  }
}

class _AppIcon extends StatelessWidget {
  final Uint8List? iconPng;
  const _AppIcon({required this.iconPng});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Neumorphic(
      style: NeumorphicStyle(
        color: p.surfaceVariant,
        depth: 2,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(14)),
      ),
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 38,
        height: 38,
        child: iconPng == null
            ? Icon(Icons.apps_rounded, color: p.onBackground)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(iconPng!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
