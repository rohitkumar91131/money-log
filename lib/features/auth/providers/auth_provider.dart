import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

// --- STATES ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- CUBIT (The Logic) ---
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> loginWithGoogle() async {
    emit(AuthLoading()); // Tells the UI to show a loading spinner

    try {
      await _repository.signInWithGoogle();
      emit(AuthSuccess()); // Tells the UI to navigate to Home
    } catch (e) {
      emit(AuthError(e.toString())); // Tells the UI to show a snackbar error
    }
  }
}
