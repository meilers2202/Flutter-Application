import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  UpdateService._();

  static final UpdateService instance = UpdateService._();

  static const String _updateInfoUrl =
      'https://raw.githubusercontent.com/meilers2202/Flutter-Application/main/Updates/update.json';

  bool _checked = false;

  Future<void> checkAndPrompt(BuildContext context) async {
    if (_checked) return;
    _checked = true;

    final info = await _fetchUpdateInfo();
    if (info == null) return;

    final package = await PackageInfo.fromPlatform();
    final currentVersion = package.version.trim();
    if (_compareVersions(currentVersion, info.version) >= 0) return;
    if (!context.mounted) return;

    await _showUpdateDialog(context, info, currentVersion);
  }

  Future<_UpdateInfo?> _fetchUpdateInfo() async {
    final uri = _withCacheBuster(Uri.parse(_updateInfoUrl));
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final version = (data['version'] as String?)?.trim() ?? '';
    if (version.isEmpty) return null;

    final rawUrl = (data['apkUrl'] as String?)?.trim();
    final downloadUrl = rawUrl == null ? null : _withCacheBuster(Uri.parse(rawUrl)).toString();
    if (downloadUrl == null || downloadUrl.isEmpty) return null;

    return _UpdateInfo(
      version: _normalizeVersion(version),
      downloadUrl: downloadUrl,
      notes: (data['notes'] as String?)?.trim() ?? '',
    );
  }

  String _normalizeVersion(String tag) {
    final trimmed = tag.trim();
    if (trimmed.startsWith('v') || trimmed.startsWith('V')) {
      return trimmed.substring(1);
    }
    return trimmed;
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

  Uri _withCacheBuster(Uri uri) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final params = Map<String, String>.from(uri.queryParameters);
    params['ts'] = now;
    return uri.replace(queryParameters: params);
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    _UpdateInfo info,
    String currentVersion,
  ) async {
    final message = StringBuffer()
      ..writeln('Aktuell: $currentVersion')
      ..writeln('Neu: ${info.version}')
      ..writeln('')
      ..writeln('Das Update wird ueber den System-Installer gestartet.');

    if (info.notes.isNotEmpty) {
      message
        ..writeln('')
        ..writeln(info.notes);
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Update verfuegbar'),
        content: Text(message.toString().trim()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Spaeter'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final url = Uri.parse(info.downloadUrl);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: const Text('Herunterladen'),
          ),
        ],
      ),
    );
  }
}

class _UpdateInfo {
  _UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.notes,
  });

  final String version;
  final String downloadUrl;
  final String notes;
}
