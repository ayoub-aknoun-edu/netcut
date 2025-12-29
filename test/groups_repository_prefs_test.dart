import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:netcut/features/groups/data/groups_repository.dart';
import 'package:netcut/features/groups/domain/app_group.dart';

void main() {
  setUp(() {
    // In-memory SharedPreferencesAsync for unit tests.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('GroupsRepositoryPrefs saves then loads groups', () async {
    final prefs = SharedPreferencesAsync();
    final repo = GroupsRepositoryPrefs(prefs);

    final groups = <AppGroup>[
      const AppGroup(
        id: '1',
        name: 'Focus',
        enabled: true,
        packageNames: ['com.twitter.android', 'com.instagram.android'],
      ),
    ];

    await repo.save(groups);
    final loaded = await repo.load();

    expect(
      loaded.map((g) => g.toMap()).toList(),
      equals(groups.map((g) => g.toMap()).toList()),
    );
  });

  test('GroupsRepositoryPrefs returns empty list on corrupted data', () async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString('groups.v2', 'not-json');

    final repo = GroupsRepositoryPrefs(prefs);
    final loaded = await repo.load();

    expect(loaded, isEmpty);
  });
}
