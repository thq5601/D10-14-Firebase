import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/auth/cubit/auth_cubit.dart';
import 'package:firebase_app/auth/cubit/auth_state.dart';
import 'package:firebase_app/auth/repository/auth_repository.dart';
import 'package:firebase_app/firebase_options.dart';
import 'package:firebase_app/note/cubit/note_cubit.dart';
import 'package:firebase_app/note/repository/note_repository.dart';
import 'package:firebase_app/screens/home_screen.dart';
import 'package:firebase_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final noteRepo = NoteRepository(FirebaseFirestore.instance);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
        BlocProvider<NoteCubit>(create: (_) => NoteCubit(noteRepo)),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
