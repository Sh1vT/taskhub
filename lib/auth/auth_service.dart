import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
