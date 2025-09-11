import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Welcome ${state.user.displayName}"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.read<AuthCubit>().logout(),
                ),
              ],
            ),
            body: Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(state.user.photoURL ?? ""),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: Text("Not logged in")));
      },
    );
  }
}
