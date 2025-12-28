import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';

class DirectBlocksState {
  final Set<String> blocked;
  const DirectBlocksState(this.blocked);
  static const initial = DirectBlocksState({});
}

class DirectBlocksController extends Notifier<DirectBlocksState> {
  static const _key = 'direct_blocks.v1';

  @override
  DirectBlocksState build() {
    _load();
    return DirectBlocksState.initial;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPrefsAsyncProvider);
    final raw = await prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      state = const DirectBlocksState({});
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).map((e) => e.toString()).toSet();
      state = DirectBlocksState(list);
    } catch (_) {
      state = const DirectBlocksState({});
    }
    ref.read(firewallControllerProvider.notifier).syncFromRules();
  }

  Future<void> _save(Set<String> set) async {
    state = DirectBlocksState(set);
    final prefs = ref.read(sharedPrefsAsyncProvider);
    await prefs.setString(_key, jsonEncode(set.toList()..sort()));
    ref.read(firewallControllerProvider.notifier).syncFromRules();
  }

  Future<void> setBlocked(String packageName, bool blocked) async {
    final next = state.blocked.toSet();
    if (blocked) {
      next.add(packageName);
    } else {
      next.remove(packageName);
    }
    await _save(next);
  }

  bool isBlocked(String packageName) => state.blocked.contains(packageName);
}
