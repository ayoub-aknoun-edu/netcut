import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import 'domain/app_group.dart';

class GroupsState {
  final bool loading;
  final List<AppGroup> groups;

  const GroupsState({required this.loading, required this.groups});
  static const initial = GroupsState(loading: true, groups: []);

  GroupsState copyWith({bool? loading, List<AppGroup>? groups}) => GroupsState(
    loading: loading ?? this.loading,
    groups: groups ?? this.groups,
  );
}

class GroupsController extends Notifier<GroupsState> {
  @override
  GroupsState build() {
    _load();
    return GroupsState.initial;
  }

  Future<void> _load() async {
    final repo = ref.read(groupsRepositoryProvider);
    final groups = await repo.load();
    state = state.copyWith(loading: false, groups: groups);
  }

  Future<void> _persist(List<AppGroup> groups) async {
    state = state.copyWith(groups: groups);
    await ref.read(groupsRepositoryProvider).save(groups);
    ref.read(firewallControllerProvider.notifier).syncFromRules();
  }

  Future<void> createGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final next = [
      ...state.groups,
      AppGroup(id: id, name: trimmed, enabled: false, packageNames: const []),
    ];
    await _persist(next);
  }

  Future<void> deleteGroup(String id) async {
    await _persist(state.groups.where((g) => g.id != id).toList());
  }

  Future<void> toggleGroup(String id, bool enabled) async {
    final next = state.groups
        .map((g) => g.id == id ? g.copyWith(enabled: enabled) : g)
        .toList();
    await _persist(next);
  }

  Future<void> renameGroup(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final next = state.groups
        .map((g) => g.id == id ? g.copyWith(name: trimmed) : g)
        .toList();
    await _persist(next);
  }

  Future<void> setGroupApps(String id, List<String> packageNames) async {
    final dedup = packageNames.toSet().toList()..sort();
    final next = state.groups
        .map((g) => g.id == id ? g.copyWith(packageNames: dedup) : g)
        .toList();
    await _persist(next);
  }

  /// Convenience: toggle membership of an app in a group
  Future<void> setAppInGroup({
    required String groupId,
    required String packageName,
    required bool inGroup,
  }) async {
    final next = state.groups.map((g) {
      if (g.id != groupId) return g;
      final set = g.packageNames.toSet();
      if (inGroup) {
        set.add(packageName);
      } else {
        set.remove(packageName);
      }
      final list = set.toList()..sort();
      return g.copyWith(packageNames: list);
    }).toList();
    await _persist(next);
  }

  List<AppGroup> groupsContaining(String packageName) {
    return state.groups
        .where((g) => g.packageNames.contains(packageName))
        .toList();
  }

  AppGroup? byId(String id) {
    for (final g in state.groups) {
      if (g.id == id) return g;
    }
    return null;
  }
}
