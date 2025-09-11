import 'package:firebase_app/auth/cubit/auth_state.dart';
import 'package:firebase_app/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepository _repository;

  AuthCubit(this._repository):super(AuthInitial()){
    _repository.user.listen((user){
      if(user != null){
        emit(AuthAuthenticated(user));
      }
      else{
        emit(AuthLoggedOut());
      }
    });
  }

  Future<void> loginWithGoogle() async{
    try{
      emit(AuthLoading());
      final user = await _repository.signInWithGoogle();
      if (user != null){
        emit(AuthAuthenticated(user));
      }
      else{
        emit(AuthError("Google Sign-in Cancelled"));
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    emit(AuthLoggedOut());
  }
}