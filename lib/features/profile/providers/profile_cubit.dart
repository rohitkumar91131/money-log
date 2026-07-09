import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneylog/features/profile/data/profile_repository.dart';

// --- STATES ---
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  ProfileLoaded(this.userData);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// --- CUBIT ---
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileLoading());

  Future<void> loadProfile() async {
    print(
      '⏳ [ProfileCubit] loadProfile() started. Emitting ProfileLoading()...',
    );
    emit(ProfileLoading());

    // Deep link hone ke turant baad metadata aane me time lagta hai
    print(
      '⏲️ [ProfileCubit] Waiting 1 second to ensure Supabase session is saved...',
    );
    await Future.delayed(const Duration(seconds: 1));

    print('🔍 [ProfileCubit] Asking repository for user data...');
    final data = _repository.getUserData();

    if (data != null) {
      print('🎯 [ProfileCubit] Data received successfully: $data');
      emit(ProfileLoaded(data));
    } else {
      print('❌ [ProfileCubit] Data was null after waiting!');
      emit(
        ProfileError("Could not load user data. Please try logging in again."),
      );
    }
  }

  Future<void> logOut() async {
    print('🛑 [ProfileCubit] logOut() called');
    await _repository.signOut();
  }
}
