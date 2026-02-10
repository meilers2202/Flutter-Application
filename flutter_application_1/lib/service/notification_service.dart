import 'package:http/http.dart' as http;
import 'package:pewpew_connect/service/imports.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _topicAllUsers = 'all_users';
  static const _prefKeyEnabled = 'notifications_enabled';
  static const _channelId = 'field_updates';
  static const _channelName = 'Field Updates';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _initLocalNotifications();

    FirebaseMessaging.onMessage.listen((message) async {
      await _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageData(message.data);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _handleMessageData(initial.data);
    }

    final enabled = await isEnabled();
    if (enabled) {
      await FirebaseMessaging.instance.subscribeToTopic(_topicAllUsers);
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (!enabled) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(_topicAllUsers);
      await prefs.setBool(_prefKeyEnabled, false);
      return false;
    }

    final settings = await _requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await FirebaseMessaging.instance.subscribeToTopic(_topicAllUsers);
      await prefs.setBool(_prefKeyEnabled, true);
      return true;
    }
    await prefs.setBool(_prefKeyEnabled, false);
    return false;
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_prefKeyEnabled);
    if (current == null) {
      await prefs.setBool(_prefKeyEnabled, true);
      return true;
    }
    return current;
  }

  Future<NotificationSettings> _requestPermission() {
    return FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Benachrichtigungen bei neuen Spielfeldern',
      importance: Importance.high,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'Neues Spielfeld verfuegbar';
    final body = notification?.body ?? 'Ein neues Spielfeld wurde freigegeben.';
    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(0, title, body, details, payload: payload);
  }

  Future<void> _handlePayload(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      await _handleMessageData(data);
    } catch (_) {
      // ignore invalid payload
    }
  }

  Future<void> _handleMessageData(Map<String, dynamic> data) async {
    final rawId = data['field_id']?.toString();
    if (rawId == null || rawId.isEmpty) return;
    final fieldId = int.tryParse(rawId);
    if (fieldId == null) return;

    final field = await _fetchFieldById(fieldId);
    if (field == null) return;

    final nav = NavigationService.navigatorKey.currentState;
    if (nav == null) return;
    nav.push(
      MaterialPageRoute(builder: (_) => FieldReviewPage2(field: field)),
    );
  }

  Future<Fields2?> _fetchFieldById(int fieldId) async {
    final url = Uri.parse('$ipAddress/get_field_by_id.php');
    try {
      final response = await http.post(url, body: {'field_id': fieldId.toString()});
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['field'] is Map<String, dynamic>) {
        return Fields2.fromJson(data['field'] as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
