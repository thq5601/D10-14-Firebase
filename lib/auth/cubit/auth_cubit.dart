import 'package:firebase_app/auth/cubit/auth_state.dart';
import 'package:firebase_app/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial()) {
    print("AuthCubit khởi tạo");
    _checkSavedLogin();

    // Lắng nghe stream Firebase để đồng bộ realtime
    _repository.user.listen((user) async {
      if (user != null) {
        print("Firebase stream trả về user: ${user.uid}");
        await _saveToken(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        print("Firebase stream: user null → logout");
        emit(AuthLoggedOut());
      }
    });
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    print("Check SharedPreferences: uid: $uid");
    if (uid != null) {
      final currentUser = _repository.getCurrentUser();
      if (currentUser != null) {
        print("Tìm thấy user hiện tại: ${currentUser.uid}");
        emit(AuthAuthenticated(currentUser));
      } else {
        print("Không tìm thấy user trong Firebase mặc dù có uid saved");
        emit(AuthLoggedOut());
      }
      
    }
    else {
      print("Không có uid trong SharedPreferences");
    }
  }

  Future<void> _saveToken(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    print("Đã lưu uid: $uid vào SharedPreferences");
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    print("Đã xóa uid khỏi SharedPreferences");
  }

  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());
      print("Đang đăng nhập bằng Google...");
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        await _saveToken(user.uid);
        print("Google login thành công: ${user.email}");
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError("Google Sign-in Cancelled"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      emit(AuthLoading());
      final user = await _repository.signInWithFacebook();
      if (user != null) {
        await _saveToken(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError("Facebook sign-in cancelled"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    await _clearToken();
    emit(AuthLoggedOut());
  }
}
