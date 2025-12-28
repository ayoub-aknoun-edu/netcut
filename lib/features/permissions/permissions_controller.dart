import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/platform/firewall_platform.dart';

class PermissionsState {
  final bool loading;
  final int sdkInt;
  final bool vpnGranted;
  final bool notificationsGranted; // required only on 33+
  final bool ignoringBatteryOptimizations;

  const PermissionsState({
    required this.loading,
    required this.sdkInt,
    required this.vpnGranted,
    required this.notificationsGranted,
    required this.ignoringBatteryOptimizations,
  });

  static const initial = PermissionsState(
    loading: true,
    sdkInt: 0,
    vpnGranted: false,
    notificationsGranted: false,
    ignoringBatteryOptimizations: false,
  );

  bool get notificationsRequired => sdkInt >= 33;
  bool get requiredOk =>
      vpnGranted && (!notificationsRequired || notificationsGranted);
}

class PermissionsController extends Notifier<PermissionsState> {
  @override
  PermissionsState build() {
    refresh();
    return PermissionsState.initial;
  }

  Future<void> refresh() async {
    if (!FirewallPlatform.isAndroid) {
      state = const PermissionsState(
        loading: false,
        sdkInt: 0,
        vpnGranted: true,
        notificationsGranted: true,
        ignoringBatteryOptimizations: true,
      );
      return;
    }

    final sdk = await FirewallPlatform.getSdkInt();
    final vpn = await FirewallPlatform.hasVpnPermission();

    bool notifGranted = true;
    if (sdk >= 33) {
      final st = await Permission.notification.status;
      notifGranted = st.isGranted;
    }

    final batt = await FirewallPlatform.isIgnoringBatteryOptimizations();

    state = PermissionsState(
      loading: false,
      sdkInt: sdk,
      vpnGranted: vpn,
      notificationsGranted: notifGranted,
      ignoringBatteryOptimizations: batt,
    );
  }

  Future<bool> requestVpn() async {
    final ok = await FirewallPlatform.requestVpnPermission();
    await refresh();
    return ok;
  }

  Future<bool> requestNotificationsIfNeeded() async {
    if (!state.notificationsRequired) return true;
    final st = await Permission.notification.request();
    await refresh();
    return st.isGranted;
  }

  Future<void> openBatterySettings() async {
    await FirewallPlatform.openBatteryOptimizationSettings();
    await refresh();
  }

  Future<void> requestIgnoreBattery() async {
    await FirewallPlatform.requestIgnoreBatteryOptimizations();
    await refresh();
  }
}
