import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  static const _keyMaintenance = 'maintenance_message';
  static const _keyShowMapButton = 'show_map_button';
  static const _keyMinAppVersion = 'min_app_version';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final remote = FirebaseRemoteConfig.instance;
    await remote.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 3),
        minimumFetchInterval: const Duration(minutes: 15),
      ),
    );
    await remote.setDefaults({
      _keyMaintenance: '',
      _keyShowMapButton: true,
      _keyMinAppVersion: '0.0.0',
    });
    _initialized = true;
    // Fetch in background
    remote.fetchAndActivate();
  }

  Future<void> refresh() async {
    final remote = FirebaseRemoteConfig.instance;
    await remote.fetchAndActivate();
  }

  String get maintenanceMessage {
    return FirebaseRemoteConfig.instance.getString(_keyMaintenance).trim();
  }

  bool get showMapButton {
    return FirebaseRemoteConfig.instance.getBool(_keyShowMapButton);
  }

  String get minAppVersion {
    return FirebaseRemoteConfig.instance.getString(_keyMinAppVersion).trim();
  }

  bool isUpdateRequired(String currentVersion) {
    final minVersion = minAppVersion;
    if (minVersion.isEmpty) return false;
    return _compareVersions(currentVersion, minVersion) < 0;
  }

  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).map((v) => v ?? 0).toList();
    final bParts = b.split('.').map(int.tryParse).map((v) => v ?? 0).toList();
    final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;
    while (aParts.length < maxLen) {
      aParts.add(0);
    }
    while (bParts.length < maxLen) {
      bParts.add(0);
    }
    for (var i = 0; i < maxLen; i++) {
      if (aParts[i] != bParts[i]) return aParts[i].compareTo(bParts[i]);
    }
    return 0;
  }
}
