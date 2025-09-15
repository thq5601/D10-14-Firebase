import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final FirebaseRemoteConfig remoteConfig;

  ThemeCubit(this.remoteConfig) : super(ThemeLight()) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final theme = remoteConfig.getString("app_theme");
    if (theme == "light") {
      emit(ThemeLight());
    } else {
      emit(ThemeDark());
    }
  }

  Future<void> refreshTheme() async {
    await remoteConfig.fetchAndActivate();
    loadTheme();
  }
}
