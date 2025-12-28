import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/apps/apps_controller.dart';
import 'features/direct_blocks/direct_blocks_controller.dart';
import 'features/firewall/firewall_controller.dart';
import 'features/groups/data/groups_repository.dart';
import 'features/groups/groups_controller.dart';
import 'features/permissions/permissions_controller.dart';
import 'features/settings/theme_controller.dart';

final sharedPrefsAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepositoryPrefs(ref.read(sharedPrefsAsyncProvider));
});

final appsControllerProvider = NotifierProvider<AppsController, AppsState>(
  AppsController.new,
);

final groupsControllerProvider =
    NotifierProvider<GroupsController, GroupsState>(GroupsController.new);

final directBlocksControllerProvider =
    NotifierProvider<DirectBlocksController, DirectBlocksState>(
      DirectBlocksController.new,
    );

final permissionsControllerProvider =
    NotifierProvider<PermissionsController, PermissionsState>(
      PermissionsController.new,
    );

final firewallControllerProvider =
    NotifierProvider<FirewallController, FirewallState>(FirewallController.new);

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);
