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
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({"app_theme": "light"});
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero, // luôn lấy dữ liệu mới
    ),
  );
  await remoteConfig.fetchAndActivate();

  // final remoteConfig = FirebaseRemoteConfig.instance;
  // await remoteConfig.setDefaults({"app_theme": "light"});
  // await remoteConfig.fetchAndActivate();


  runApp(MainApp(remoteConfig: remoteConfig));
}

class MainApp extends StatelessWidget {
  final FirebaseRemoteConfig remoteConfig;
  const MainApp({super.key, required this.remoteConfig});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final noteRepo = NoteRepository(FirebaseFirestore.instance);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
        BlocProvider<NoteCubit>(create: (_) => NoteCubit(noteRepo)),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(remoteConfig)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // theme: themeState.themeData, // đổi theme ở đây
            theme: themeState is ThemeDark ? ThemeData.dark() : ThemeData.light(),
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
