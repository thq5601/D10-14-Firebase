import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/auth/cubit/auth_cubit.dart';
import 'package:firebase_app/auth/cubit/auth_state.dart';
import 'package:firebase_app/auth/repository/auth_repository.dart';
import 'package:firebase_app/firebase_options.dart';
import 'package:firebase_app/note/cubit/note_cubit.dart';
import 'package:firebase_app/note/repository/note_repository.dart';
import 'package:firebase_app/screens/home_screen.dart';
import 'package:firebase_app/screens/login_screen.dart';
import 'package:firebase_app/theme/cubit/theme_cubit.dart';
import 'package:firebase_app/theme/cubit/theme_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage remoteMessage,
) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 Background message: ${remoteMessage.messageId}');
}

// 🔑 Tạo navigatorKey global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, //Cho phep cache offline
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, //Khong gioi han cache
  );

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({"app_theme": "light"});
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ),
  );
  try {
  await remoteConfig.fetchAndActivate();
} catch (e) {
  print("Remote Config offline, cache: $e");
}

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MainApp(remoteConfig: remoteConfig));
}

class MainApp extends StatefulWidget {
  final FirebaseRemoteConfig remoteConfig;
  const MainApp({super.key, required this.remoteConfig});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? _token;

  @override
  void initState() {
    _initFCM();
    super.initState();
  }

  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    _token = await messaging.getToken();
    print("📱 Device FCM Token: $_token");

    // App đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification!.title ?? "No title";
      final body = message.notification!.body ?? "Body";
      print("🔔 Foreground message: ${message.notification?.title}");
      if (message.notification != null) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$title\n$body")));
        }
      }
    });

    // App chạy ngầm (click notification mở app)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📂 Notification clicked: ${message.notification?.title}");
    });

    // App mở từ trạng thái terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
        "📥 App opened from terminated: ${initialMessage.notification?.title}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final noteRepo = NoteRepository(FirebaseFirestore.instance);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
        BlocProvider<NoteCubit>(create: (_) => NoteCubit(noteRepo)),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(widget.remoteConfig),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: themeState is ThemeDark
                ? ThemeData.dark()
                : ThemeData.light(),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
