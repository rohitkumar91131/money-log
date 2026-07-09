import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moneylog/features/auth/data/auth_repository.dart';

// --- STATES ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- CUBIT ---
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial()) {
    print('🎧 [AuthCubit] Started listening to Supabase Auth Changes');
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('🔔 [AuthCubit Listener] Event received: ${data.event}');
      if (data.event == AuthChangeEvent.signedIn) {
        print('🎉 [AuthCubit Listener] User signed in! Emitting AuthSuccess()');
        emit(AuthSuccess());
      }
    });
  }

  Future<void> signInWithGoogle() async {
    print('⏳ [AuthCubit] Emitting AuthLoading()');
    emit(AuthLoading());
    try {
      await _repository.signInWithGoogle();
      print(
        '⏳ [AuthCubit] Waiting for deep link listener to catch signedIn event...',
      );
    } catch (e) {
      print('❌ [AuthCubit] Caught error: $e');
      emit(AuthError('Failed to sign in: ${e.toString()}'));
    }
  }
}
