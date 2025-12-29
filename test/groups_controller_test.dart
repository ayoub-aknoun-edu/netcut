import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:netcut/app_providers.dart';
import 'package:netcut/features/firewall/firewall_controller.dart';
import 'package:netcut/features/groups/data/groups_repository.dart';
import 'package:netcut/features/groups/domain/app_group.dart';
import 'package:netcut/features/groups/groups_controller.dart';

class MemoryGroupsRepository implements GroupsRepository {
  List<AppGroup> _store;
  int saveCalls = 0;

  MemoryGroupsRepository([List<AppGroup>? initial]) : _store = initial ?? [];

  @override
  Future<List<AppGroup>> load() async => _store;

  @override
  Future<void> save(List<AppGroup> groups) async {
    saveCalls++;
    _store = List<AppGroup>.from(groups);
  }
}

class SpyFirewallController extends FirewallController {
  int syncCalls = 0;

  @override
  FirewallState build() => FirewallState.initial;

  @override
  Future<void> syncFromRules() async {
    syncCalls++;
  }
}

void main() {
  test(
    'createGroup trims name, persists, and triggers firewall sync',
    () async {
      final repo = MemoryGroupsRepository();
      final container = ProviderContainer.test(
        overrides: [
          groupsRepositoryProvider.overrideWithValue(repo),
          firewallControllerProvider.overrideWith(SpyFirewallController.new),
        ],
      );
      addTearDown(container.dispose);

      // Trigger provider init (starts async load).
      container.read(groupsControllerProvider);

      // Let the async load complete.
      await pumpEventQueue();

      await container
          .read(groupsControllerProvider.notifier)
          .createGroup('  Social  ');

      final state = container.read(groupsControllerProvider);
      expect(state.groups, hasLength(1));
      expect(state.groups.single.name, 'Social');

      expect(repo.saveCalls, 1);

      final firewall =
          container.read(firewallControllerProvider.notifier)
              as SpyFirewallController;
      expect(firewall.syncCalls, 1);
    },
  );

  test('setGroupApps dedups + sorts before persisting', () async {
    final repo = MemoryGroupsRepository([
      const AppGroup(id: 'g1', name: 'G', enabled: false, packageNames: []),
    ]);

    final container = ProviderContainer.test(
      overrides: [
        groupsRepositoryProvider.overrideWithValue(repo),
        firewallControllerProvider.overrideWith(SpyFirewallController.new),
      ],
    );
    addTearDown(container.dispose);

    container.read(groupsControllerProvider);
    await pumpEventQueue();

    await container.read(groupsControllerProvider.notifier).setGroupApps('g1', [
      'b',
      'a',
      'a',
      'c',
    ]);

    final g1 = container.read(groupsControllerProvider).groups.single;
    expect(g1.packageNames, equals(['a', 'b', 'c']));
  });
}
