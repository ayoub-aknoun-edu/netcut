import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/platform/firewall_platform.dart';

class AppsState {
  final bool loading;
  final List<InstalledApp> apps;

  const AppsState({required this.loading, required this.apps});
  static const initial = AppsState(loading: true, apps: []);
}

class AppsController extends Notifier<AppsState> {
  @override
  AppsState build() {
    _load();
    return AppsState.initial;
  }

  Future<void> _load() async {
    if (!FirewallPlatform.isAndroid) {
      state = const AppsState(loading: false, apps: []);
      return;
    }
    final apps = await FirewallPlatform.listLaunchableApps();
    state = AppsState(loading: false, apps: apps);
  }

  InstalledApp? byPackage(String pkg) {
    for (final a in state.apps) {
      if (a.packageName == pkg) return a;
    }
    return null;
  }
}
