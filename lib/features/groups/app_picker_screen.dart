import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import '../apps/widgets/app_icon.dart';

/// Full-screen group editor (kept for convenience / accessibility).
///
/// This screen no longer reloads installed apps from the platform side.
/// It reuses the global `appsControllerProvider` cache, which removes a large
/// chunk of perceived slowness when editing groups.
class AppPickerScreen extends ConsumerStatefulWidget {
  final String groupId;
  const AppPickerScreen({super.key, required this.groupId});

  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  String _query = '';
  final Set<String> _selected = <String>{};
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final groupsState = ref.watch(groupsControllerProvider);
    final appsState = ref.watch(appsControllerProvider);

    final group = groupsState.groups.where((g) => g.id == widget.groupId).firstOrNull;

    if (!_seeded && group != null) {
      _selected
        ..clear()
        ..addAll(group.packageNames);
      _seeded = true;
    }

    final apps = appsState.apps;
    final filtered = apps.where((a) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return a.label.toLowerCase().contains(q) ||
          a.packageName.toLowerCase().contains(q);
    }).toList();

    return NeumorphicBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
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
                      group == null ? 'Edit apps' : 'Edit “${group.name}”',
                      style: AppTypography.title(p.onBackground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: (appsState.loading || group == null)
                        ? null
                        : () async {
                            await ref
                                .read(groupsControllerProvider.notifier)
                                .setGroupApps(widget.groupId, _selected.toList());
                            if (mounted) Navigator.pop(context);
                          },
                    style: NeumorphicStyle(
                      color: p.primaryContainer,
                      depth: 2,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(14),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text('Save', style: AppTypography.button(p.onBackground)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search apps…',
                ),
              ),
            ),
            Expanded(
              child: appsState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No apps found',
                            style: AppTypography.body(p.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final app = filtered[i];
                            final selected = _selected.contains(app.packageName);
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
                                            style: AppTypography.subtitle(p.onBackground),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            app.packageName,
                                            style: AppTypography.bodySmall(p.onSurfaceVariant),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    NeumorphicButton(
                                      onPressed: () {
                                        setState(() {
                                          if (selected) {
                                            _selected.remove(app.packageName);
                                          } else {
                                            _selected.add(app.packageName);
                                          }
                                        });
                                      },
                                      style: NeumorphicStyle(
                                        color: selected ? p.primaryContainer : p.surfaceVariant,
                                        depth: 2,
                                        boxShape: const NeumorphicBoxShape.circle(),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        selected ? Icons.check_rounded : Icons.add_rounded,
                                        color: p.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
