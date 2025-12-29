import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/palette_ext.dart';
import '../apps/widgets/app_icon.dart';

class GroupAppsEditorSheet extends ConsumerStatefulWidget {
  final String groupId;
  const GroupAppsEditorSheet({super.key, required this.groupId});

  static Future<void> show(BuildContext context, {required String groupId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final p = sheetContext.palette;
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: GroupAppsEditorSheet(groupId: groupId),
            ),
          ),
        );
      },
    );
  }

  @override
  ConsumerState<GroupAppsEditorSheet> createState() =>
      _GroupAppsEditorSheetState();
}

class _GroupAppsEditorSheetState extends ConsumerState<GroupAppsEditorSheet> {
  String _query = '';
  final Set<String> _selected = <String>{};
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final groupsState = ref.watch(groupsControllerProvider);
    final appsState = ref.watch(appsControllerProvider);

    final group = groupsState.groups
        .where((g) => g.id == widget.groupId)
        .firstOrNull;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: p.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  group == null ? 'Edit apps' : 'Edit “${group.name}”',
                  style: AppTypography.title(p.onBackground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                child: Icon(Icons.close_rounded, color: p.onBackground),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search apps…',
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
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
                                  color: selected
                                      ? p.primaryContainer
                                      : p.surfaceVariant,
                                  depth: 2,
                                  boxShape: const NeumorphicBoxShape.circle(),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  selected
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeumorphicButton(
              onPressed: (group == null)
                  ? null
                  : () async {
                      await ref
                          .read(groupsControllerProvider.notifier)
                          .setGroupApps(widget.groupId, _selected.toList());
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
                  'Save',
                  style: AppTypography.button(p.onBackground),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
