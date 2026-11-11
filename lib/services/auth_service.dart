
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  // Mengambil data pengguna yang sedang login
  User? get currentUser => _client.auth.currentUser;

  // Mengambil session pengguna
  Session? get currentSession => _client.auth.currentSession;

  // Memeriksa status login pengguna
  bool get isLoggedIn => currentSession != null;

  // Registrasi pengguna dengan nama dan role
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );
  }

  // Login pengguna
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout pengguna
  Future<void> logout() {
    return _client.auth.signOut();
  }
}
