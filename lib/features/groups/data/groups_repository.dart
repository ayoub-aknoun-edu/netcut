import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_group.dart';

abstract class GroupsRepository {
  Future<List<AppGroup>> load();
  Future<void> save(List<AppGroup> groups);
}

class GroupsRepositoryPrefs implements GroupsRepository {
  static const _key = 'groups.v2';
  final SharedPreferencesAsync _prefs;
  GroupsRepositoryPrefs(this._prefs);

  @override
  Future<List<AppGroup>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      return AppGroup.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> save(List<AppGroup> groups) async {
    await _prefs.setString(_key, AppGroup.encodeList(groups));
  }
}
