import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);
  static const initial = ThemeState(ThemeMode.system);
}

class ThemeController extends Notifier<ThemeState> {
  static const _key = 'theme_mode.v1';

  @override
  ThemeState build() {
    _load();
    return ThemeState.initial;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPrefsAsyncProvider);
    final raw = await prefs.getString(_key);
    state = ThemeState(_decode(raw));
  }

  ThemeMode _decode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _encode(ThemeMode m) {
    return switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = ThemeState(mode);
    final prefs = ref.read(sharedPrefsAsyncProvider);
    await prefs.setString(_key, _encode(mode));
  }
}
