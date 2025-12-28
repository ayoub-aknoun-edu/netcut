import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/apps/apps_controller.dart';
import 'features/direct_blocks/direct_blocks_controller.dart';
import 'features/firewall/firewall_controller.dart';
import 'features/groups/data/groups_repository.dart';
import 'features/groups/groups_controller.dart';
import 'features/permissions/permissions_controller.dart';
import 'features/settings/theme_controller.dart';
import 'core/platform/firewall_platform.dart';

final sharedPrefsAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepositoryPrefs(ref.read(sharedPrefsAsyncProvider));
});

final appsControllerProvider = NotifierProvider<AppsController, AppsState>(
  AppsController.new,
);

/// Fast lookup map for installed apps.
final appsByPackageProvider = Provider<Map<String, InstalledApp>>((ref) {
  final apps = ref.watch(appsControllerProvider).apps;
  final map = <String, InstalledApp>{};
  for (final a in apps) {
    if (a.packageName.isNotEmpty) map[a.packageName] = a;
  }
  return map;
});

/// Optional per-app icon loader.
///
/// This is only used when the Android side implements `getAppIcon` (see
/// `FirewallPlatform.getAppIconPng`). If icons already exist in the app list,
/// you can ignore this provider.
final appIconPngProvider = FutureProvider.family<Uint8List?, String>((
  ref,
  packageName,
) async {
  // If we already have the icon from the list, return it.
  final existing = ref.read(appsByPackageProvider)[packageName]?.iconPng;
  if (existing != null) return existing;
  return FirewallPlatform.getAppIconPng(packageName);
});

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
