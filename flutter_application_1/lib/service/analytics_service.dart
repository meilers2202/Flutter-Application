import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:pewpew_connect/service/consent_service.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver observer() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  Future<void> setCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    final allowed = await ConsentService.instance.isAllowed();
    if (!allowed) return;
    if (parameters == null) {
      await _analytics.logEvent(name: name);
      return;
    }

    final sanitized = <String, Object>{};
    parameters.forEach((key, value) {
      if (value != null) sanitized[key] = value;
    });

    await _analytics.logEvent(
      name: name,
      parameters: sanitized.isEmpty ? null : sanitized,
    );
  }

  Future<void> logAppStart() async {
    await logEvent('app_start');
  }
}
