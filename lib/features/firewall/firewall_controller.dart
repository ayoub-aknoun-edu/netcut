import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../core/platform/firewall_platform.dart';

class FirewallState {
  final bool enabled;
  final bool starting;
  final bool running;
  final Set<String> blockedPackages;

  const FirewallState({
    required this.enabled,
    required this.starting,
    required this.running,
    required this.blockedPackages,
  });

  static const initial = FirewallState(
    enabled: false,
    starting: false,
    running: false,
    blockedPackages: {},
  );

  FirewallState copyWith({
    bool? enabled,
    bool? starting,
    bool? running,
    Set<String>? blockedPackages,
  }) {
    return FirewallState(
      enabled: enabled ?? this.enabled,
      starting: starting ?? this.starting,
      running: running ?? this.running,
      blockedPackages: blockedPackages ?? this.blockedPackages,
    );
  }
}

class FirewallController extends Notifier<FirewallState> {
  @override
  FirewallState build() {
    _refreshRunning();
    return FirewallState.initial;
  }

  Future<void> _refreshRunning() async {
    if (!FirewallPlatform.isAndroid) return;
    final r = await FirewallPlatform.isBlockingActive();
    state = state.copyWith(running: r);
  }

  Future<void> syncFromRules() async {
    final groups = ref.read(groupsControllerProvider).groups;
    final direct = ref.read(directBlocksControllerProvider).blocked;

    final blocked = <String>{...direct};
    for (final g in groups) {
      if (!g.enabled) continue;
      blocked.addAll(g.packageNames);
    }

    state = state.copyWith(blockedPackages: blocked);

    if (state.enabled) {
      await _applyNow();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (!FirewallPlatform.isAndroid) return;
    state = state.copyWith(enabled: enabled);

    if (!enabled) {
      await FirewallPlatform.stopBlocking();
      state = state.copyWith(running: false);
      return;
    }

    await _applyNow();
  }

  Future<void> _applyNow() async {
    if (!FirewallPlatform.isAndroid) return;

    final pkgs = state.blockedPackages.toList()..sort();
    if (pkgs.isEmpty) {
      await FirewallPlatform.stopBlocking();
      state = state.copyWith(running: false);
      return;
    }

    state = state.copyWith(starting: true);
    final ok = await FirewallPlatform.startBlocking(blockedPackages: pkgs);
    state = state.copyWith(starting: false, running: ok);

    if (!ok) {
      state = state.copyWith(enabled: false);
    }
  }
}
