import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netcut/core/platform/firewall_platform.dart';
import 'package:netcut/theme/app_neumorphic_theme.dart';
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

    // Build reverse index
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
        // Modern search bar
        _ModernSearchBar(
          query: _q,
          onQueryChanged: (v) => setState(() => _q = v),
          blockedOnly: _blockedOnly,
          onBlockedToggle: () => setState(() => _blockedOnly = !_blockedOnly),
          palette: p,
        ),

        const SizedBox(height: 16),

        // Apps list
        Expanded(
          child: appsState.loading
              ? _LoadingShimmer(palette: p)
              : filtered.isEmpty
              ? _EmptyState(
                  message: _q.isEmpty ? 'No apps installed' : 'No apps found',
                  palette: p,
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final app = filtered[i];
                    final isDirectBlocked = direct.blocked.contains(
                      app.packageName,
                    );
                    final groupNames =
                        appToGroups[app.packageName] ?? const <String>[];

                    return _ModernAppCard(
                          app: app,
                          isBlocked: isDirectBlocked,
                          groupNames: groupNames,
                          onToggle: (v) => ref
                              .read(directBlocksControllerProvider.notifier)
                              .setBlocked(app.packageName, v),
                          onAddToGroup: () =>
                              _openGroupsSheet(context, app.packageName),
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

  void _openGroupsSheet(BuildContext context, String pkg) {
    final p = context.palette;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer(
          builder: (context, ref, __) {
            final groups = ref.watch(groupsControllerProvider).groups;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add to Groups',
                            style: AppTypography.headline(p.onBackground),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: p.onSurfaceVariant,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: p.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: groups.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: _EmptyState(
                              message: 'Create a group first',
                              palette: p,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: groups.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final g = groups[i];
                              final inGroup = g.packageNames.contains(pkg);

                              return _GroupOption(
                                name: g.name,
                                isSelected: inGroup,
                                onTap: () => ref
                                    .read(groupsControllerProvider.notifier)
                                    .setAppInGroup(
                                      groupId: g.id,
                                      packageName: pkg,
                                      inGroup: !inGroup,
                                    ),
                                palette: p,
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
  }
}

// Modern search bar component
class _ModernSearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final bool blockedOnly;
  final VoidCallback onBlockedToggle;
  final ColorPalette palette;

  const _ModernSearchBar({
    required this.query,
    required this.onQueryChanged,
    required this.blockedOnly,
    required this.onBlockedToggle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: palette.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    onChanged: onQueryChanged,
                    cursorColor: palette.primary,
                    style: AppTypography.body(palette.onBackground),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search apps…',
                      hintStyle: AppTypography.body(palette.onSurfaceVariant),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  IconButton(
                    onPressed: () => onQueryChanged(''),
                    icon: Icon(Icons.close_rounded, size: 20),
                    color: palette.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onBlockedToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: blockedOnly
                  ? LinearGradient(
                      colors: [palette.primary, palette.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: blockedOnly ? null : palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: blockedOnly ? Colors.transparent : palette.outline,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: blockedOnly
                      ? palette.primary.withOpacity(0.3)
                      : palette.shadow,
                  blurRadius: blockedOnly ? 12 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(
                  blockedOnly
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  color: blockedOnly ? Colors.white : palette.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Blocked',
                  style: AppTypography.button(
                    blockedOnly ? Colors.white : palette.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Modern app card
class _ModernAppCard extends StatelessWidget {
  final InstalledApp app;
  final bool isBlocked;
  final List<String> groupNames;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddToGroup;
  final ColorPalette palette;

  const _ModernAppCard({
    required this.app,
    required this.isBlocked,
    required this.groupNames,
    required this.onToggle,
    required this.onAddToGroup,
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
          color: isBlocked ? palette.primary.withOpacity(0.3) : palette.outline,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isBlocked
                ? palette.primary.withOpacity(0.15)
                : palette.shadow,
            blurRadius: isBlocked ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onToggle(!isBlocked),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // App icon with glow
                Hero(
                  tag: 'app_icon_${app.packageName}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isBlocked
                          ? [
                              BoxShadow(
                                color: palette.primary.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        color: palette.surfaceVariant,
                        child: app.iconPng == null
                            ? Icon(
                                Icons.apps_rounded,
                                color: palette.onSurfaceVariant,
                                size: 32,
                              )
                            : Image.memory(
                                app.iconPng!,
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                cacheWidth: 128,
                                cacheHeight: 128,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // App info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.label,
                        style: AppTypography.subtitle(palette.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.packageName,
                        style: AppTypography.bodySmall(
                          palette.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (groupNames.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _GroupChips(groupNames: groupNames, palette: palette),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Controls
                Column(
                  children: [
                    // Toggle switch with animation
                    GestureDetector(
                      onTap: () => onToggle(!isBlocked),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: isBlocked
                              ? LinearGradient(
                                  colors: [palette.primary, palette.secondary],
                                )
                              : null,
                          color: isBlocked ? null : palette.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isBlocked
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

                    const SizedBox(height: 8),

                    // Add to group button
                    IconButton(
                      onPressed: onAddToGroup,
                      icon: Icon(Icons.playlist_add_rounded, size: 24),
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

// Group chips
class _GroupChips extends StatelessWidget {
  final List<String> groupNames;
  final ColorPalette palette;

  const _GroupChips({required this.groupNames, required this.palette});

  @override
  Widget build(BuildContext context) {
    const maxShown = 2;
    final shown = groupNames.take(maxShown).toList();
    final remaining = groupNames.length - shown.length;

    Widget chip(String text, {bool isCount = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isCount
              ? LinearGradient(colors: [palette.primary, palette.secondary])
              : null,
          color: isCount ? null : palette.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCount ? Colors.transparent : palette.outline,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTypography.label(
            isCount ? Colors.white : palette.onBackground,
          ).copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final widgets = <Widget>[];
    for (final name in shown) {
      widgets.add(chip(name));
    }
    if (remaining > 0) {
      widgets.add(chip('+$remaining', isCount: true));
    }

    return Wrap(spacing: 6, runSpacing: 6, children: widgets);
  }
}

// Group option in bottom sheet
class _GroupOption extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorPalette palette;

  const _GroupOption({
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [palette.primary, palette.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : palette.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.transparent : palette.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTypography.subtitle(
                  isSelected ? Colors.white : palette.onBackground,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? Colors.white : palette.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Loading shimmer
class _LoadingShimmer extends StatelessWidget {
  final ColorPalette palette;
  const _LoadingShimmer({required this.palette});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, i) {
        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 90,
              decoration: BoxDecoration(
                color: palette.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms, color: palette.surface);
      },
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  final String message;
  final ColorPalette palette;
  const _EmptyState({required this.message, required this.palette});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: palette.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.body(palette.onSurfaceVariant)),
        ],
      ),
    );
  }
}
