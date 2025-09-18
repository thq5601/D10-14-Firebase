import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final FirebaseRemoteConfig remoteConfig;

  ThemeCubit(this.remoteConfig) : super(ThemeLight()) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      //Doc tu cache truoc
      final theme = remoteConfig.getString("app_theme");
      emit(theme == "dark" ? ThemeDark() : ThemeLight());

      //Fetch online
      await remoteConfig.fetchAndActivate();
      final newTheme = remoteConfig.getString("app_theme");
      emit(newTheme == "dark" ? ThemeDark() : ThemeLight());
    } catch (e) {
      print("Remote config offline, dung gia tri cu: $e");
    }
  }

  Future<void> refreshTheme() async {
    await remoteConfig.fetchAndActivate();
    loadTheme();
  }
}
