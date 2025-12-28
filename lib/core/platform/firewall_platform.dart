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

  /// Returns the list of launchable apps.
  ///
  /// ⚡️ Performance note:
  /// - If [includeIcons] is true, the platform call may be slow on devices with
  ///   many apps (icons are large binary payloads).
  /// - If [includeIcons] is false, Flutter will try `listAppsMeta` (label +
  ///   package only). This is much faster *if* you implement `listAppsMeta` on
  ///   the Android side. If it doesn't exist, we fall back to `listApps`.
  static Future<List<InstalledApp>> listLaunchableApps({
    bool includeIcons = true,
  }) async {
    List<dynamic>? raw;
    if (!includeIcons) {
      try {
        raw = await _channel.invokeMethod<List<dynamic>>('listAppsMeta');
      } on MissingPluginException {
        raw = null;
      } on PlatformException {
        raw = null;
      }
    }

    raw ??= await _channel.invokeMethod<List<dynamic>>(
      includeIcons ? 'listApps' : 'listApps',
    );

    final list = raw ?? const [];
    final apps = list
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return InstalledApp(
            packageName: (m['packageName'] as String?) ?? '',
            label: (m['label'] as String?) ?? '',
            iconPng: m['icon'] as Uint8List?,
          );
        })
        .where((a) => a.packageName.isNotEmpty)
        .toList();

    apps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return apps;
  }

  /// Best-effort icon fetch. Requires Android-side implementation of
  /// `getAppIcon` that returns PNG bytes.
  static Future<Uint8List?> getAppIconPng(String packageName) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('getAppIcon', {
        'packageName': packageName,
      });
      return bytes;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
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
