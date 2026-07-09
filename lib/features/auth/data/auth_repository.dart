import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    print('🌐 [AuthRepository] signInWithGoogle() called. Opening browser...');
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'moneylog://login-callback',
      );
      print('✅ [AuthRepository] OAuth flow initiated successfully.');
    } catch (e) {
      print('❌ [AuthRepository] Error during signInWithGoogle: $e');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }
}
