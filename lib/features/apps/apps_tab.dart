import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import 'widgets/app_icon.dart';

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

    // Build a reverse index once per build (package -> list of group names).
    // This avoids scanning all groups for every visible app row.
    final appToGroups = <String, List<String>>{};
    for (final g in groupsState.groups) {
      for (final pkg in g.packageNames) {
        (appToGroups[pkg] ??= <String>[]).add(g.name);
      }
    }

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
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  cacheExtent: 1400,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    final isDirectBlocked = direct.blocked.contains(
                      app.packageName,
                    );

                    final groupNames =
                        appToGroups[app.packageName] ?? const <String>[];

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
                              packageName: app.packageName,
                              iconPng: app.iconPng,
                            ),
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
                                  if (groupNames.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _GroupChips(groupNames: groupNames),
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
/// TextField requires a Material widget ancestor.
class _MaterialHost extends StatelessWidget {
  final Widget child;
  const _MaterialHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(type: MaterialType.transparency, child: child);
  }
}

class _GroupChips extends StatelessWidget {
  final List<String> groupNames;
  const _GroupChips({required this.groupNames});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Showing too many chips increases build cost; keep it tight.
    const maxShown = 2;
    final shown = groupNames.take(maxShown).toList();
    final remaining = groupNames.length - shown.length;

    List<Widget> chip(String text) => [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.surfaceVariant,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.outlineVariant, width: 1),
            ),
            child: Text(
              text,
              style: AppTypography.label(p.onBackground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];

    final widgets = <Widget>[];
    for (final name in shown) {
      widgets.addAll(chip(name));
    }
    if (remaining > 0) {
      widgets.addAll(chip('+$remaining'));
    }

    return Wrap(spacing: 6, runSpacing: 6, children: widgets);
  }
}
