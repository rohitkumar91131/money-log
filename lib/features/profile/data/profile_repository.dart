import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? getUserData() {
    print('🕵️ [ProfileRepository] Fetching currentUser...');
    final user = _supabase.auth.currentUser;

    if (user == null) {
      print('❌ [ProfileRepository] currentUser is NULL!');
      return null;
    }

    print('✅ [ProfileRepository] User found!');
    print('🆔 [ProfileRepository] User ID: ${user.id}');
    print('📧 [ProfileRepository] User Email: ${user.email}');
    print('📋 [ProfileRepository] Raw Metadata: ${user.userMetadata}');

    final metadata = user.userMetadata;

    return {
      'email': user.email ?? 'No Email',
      'name': metadata?['full_name'] ?? 'Unknown User',
      'avatar_url': metadata?['avatar_url'] ?? '',
    };
  }

  Future<void> signOut() async {
    print('🚪 [ProfileRepository] Signing out...');
    await _supabase.auth.signOut();
    print('✅ [ProfileRepository] Sign out complete!');
  }
}
