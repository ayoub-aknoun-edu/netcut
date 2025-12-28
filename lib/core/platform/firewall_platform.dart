import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class InstalledApp {
  final String packageName;
  final String label;
  final Uint8List? iconPng;

  const InstalledApp({
    required this.packageName,
    required this.label,
    required this.iconPng,
  });
}

class FirewallPlatform {
  FirewallPlatform._();
  static const _channel = MethodChannel('netcut/firewall');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<int> getSdkInt() async {
    final v = await _channel.invokeMethod<int>('getSdkInt');
    return v ?? 0;
  }

  static Future<bool> hasVpnPermission() async {
    final ok = await _channel.invokeMethod<bool>('hasVpnPermission');
    return ok ?? false;
  }

  static Future<bool> requestVpnPermission() async {
    final ok = await _channel.invokeMethod<bool>('requestVpnPermission');
    return ok ?? false;
  }

  static Future<List<InstalledApp>> listLaunchableApps() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('listApps');
    final list = raw ?? const [];
    return list
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return InstalledApp(
            packageName: (m['packageName'] as String?) ?? '',
            label: (m['label'] as String?) ?? '',
            iconPng: m['icon'] as Uint8List?,
          );
        })
        .where((a) => a.packageName.isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }

  static Future<bool> startBlocking({
    required List<String> blockedPackages,
  }) async {
    final ok = await _channel.invokeMethod<bool>('startVpn', {
      'blockedPackages': blockedPackages,
    });
    return ok ?? false;
  }

  static Future<void> stopBlocking() => _channel.invokeMethod<void>('stopVpn');

  static Future<bool> isBlockingActive() async {
    final ok = await _channel.invokeMethod<bool>('isVpnRunning');
    return ok ?? false;
  }

  static Future<void> openBatteryOptimizationSettings() =>
      _channel.invokeMethod<void>('openBatterySettings');

  static Future<void> requestIgnoreBatteryOptimizations() =>
      _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');

  static Future<bool> isIgnoringBatteryOptimizations() async {
    final ok = await _channel.invokeMethod<bool>(
      'isIgnoringBatteryOptimizations',
    );
    return ok ?? false;
  }
}
