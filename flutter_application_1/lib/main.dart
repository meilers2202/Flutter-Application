import 'package:pewpew_connect/service/imports.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final consentAllowed = await ConsentService.instance.isAllowed();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(consentAllowed);
  await AnalyticsService.instance.setCollectionEnabled(consentAllowed);
  await PerformanceService.instance.setCollectionEnabled(consentAllowed);

  RemoteConfigService.instance.initialize();
  await NotificationService.instance.initialize();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _prompted = false;

  Future<void> _promptConsentOnce() async {
    if (_prompted) return;
    _prompted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Use the Navigator overlay context so MaterialLocalizations are available.
      final navContext = NavigationService.navigatorKey.currentState?.overlay?.context;
      if (navContext == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final retryContext = NavigationService.navigatorKey.currentState?.overlay?.context;
          if (retryContext == null) return;
          await _runConsentFlow(retryContext);
        });
        return;
      }
      await _runConsentFlow(navContext);
    });
  }

  Future<void> _runConsentFlow(BuildContext navContext) async {
    await ConsentService.instance.maybePrompt(navContext);
    final allowed = await ConsentService.instance.isAllowed();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(allowed);
    await AnalyticsService.instance.setCollectionEnabled(allowed);
    await PerformanceService.instance.setCollectionEnabled(allowed);
    await AnalyticsService.instance.logAppStart();
    if (!navContext.mounted) return;
    await UpdateService.instance.checkAndPrompt(navContext);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      navigatorObservers: [AnalyticsService.instance.observer()],
      builder: (context, child) {
        _promptConsentOnce();
        return child ?? const SizedBox.shrink();
      },
      themeMode: appState.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green, 
          iconTheme: IconThemeData(color: Colors.white)
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green, 
          iconTheme: IconThemeData(color: Colors.white)
        ),
      ),
      
      home: appState.isAutoLoggedIn 
          ? MainPage(
              toggleTheme: appState.toggleTheme,
              userRole: appState.role,
              userTeam: appState.team,
              currentUsername: appState.username,
              onTeamChange: appState.setUserData,
            )
          : WelcomePage(
              toggleTheme: appState.toggleTheme,
              setUserData: appState.setUserData,
            ),

      routes: {
        '/login': (context) => WelcomePage(
              toggleTheme: appState.toggleTheme,
              setUserData: appState.setUserData,
            ),
        '/register': (context) => RegisterPage(toggleTheme: appState.toggleTheme),
        '/main': (context) => MainPage(
              toggleTheme: appState.toggleTheme,
              userRole: appState.role,
              userTeam: appState.team,
              currentUsername: appState.username,
              onTeamChange: appState.setUserData,
            ),
        '/profile': (context) => ProfilePage(
              toggleTheme: appState.toggleTheme,
              username: appState.username,
            ),
        '/settings': (context) => SettingsPage(toggleTheme: appState.toggleTheme),
        '/admin': (context) => const AdminPage(),
        // Admin subpages
        '/admin/users': (context) => const UserManagementPage(),
        '/admin/fieldowners': (context) => const FieldOwnerList(),
        '/admin/fields': (context) => const FieldList(),
        '/admin/blocklist': (context) => const BlocklistPage(),
        '/admin/teams': (context) => const TeamsManagementPage(),
        // General pages
        '/allTeams': (context) => const AllTeams(),
        '/fieldslist': (context) => const FieldListPage(),
        '/teamDetails': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TeamDetailsPage2(
            teamName: args?['teamName'] ?? '',
            currentUsername: args?['username'] ?? args?['currentUsername'] ?? '',
            userCurrentTeam: args?['userCurrentTeam'],
          );
        },
        '/fieldownerlogin': (context) => FieldOwnerLogin(
              toggleTheme: appState.toggleTheme,
              setUserData: appState.setUserData,
            ),
        '/fieldownerregister': (context) => RegisterFieldOwnerPage(toggleTheme: appState.toggleTheme),
        '/fieldownermain': (context) => FieldOwnerMainPage(currentUsername: appState.username),
        '/fieldcreate': (context) => CreateField(currentUsername: appState.username),
        '/fielddetails': (context) {
          final field = ModalRoute.of(context)?.settings.arguments;
          if (field is Field) return FieldDetailsPage(field: field);
          return _errorPage("Feld-Daten fehlen");
        },
        '/editfield': (context) {
          final fieldToEdit = ModalRoute.of(context)?.settings.arguments;
          if (fieldToEdit is Field) return EditFieldPage(field: fieldToEdit);
          return _errorPage("Edit-Daten fehlen");
        },
        '/registerpolicy': (context) => const RegisterPolicy(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/joinTeam') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => JoinTeam(
              teamName: args?['teamName'] ?? '',
              currentUsername: args?['currentUsername'] ?? appState.username,
              userCurrentTeam: args?['userCurrentTeam'],
            ),
          );
        }
        return null;
      },
    );
  }

  static Widget _errorPage(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fehler")),
      body: Center(child: Text(message)),
    );
  }
}