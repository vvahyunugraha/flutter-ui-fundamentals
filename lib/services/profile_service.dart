
import 'package:supabase_flutter/supabase_flutter.dart';

// Model untuk menyimpan informasi profil pengguna
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  // Mengubah data Map dari Supabase menjadi UserProfile
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'seeker',
    );
  }

  // Memeriksa role pengguna
  bool get isSeeker => role == 'seeker';

  bool get isOwner => role == 'owner';

  bool get isAdmin => role == 'admin';
}

// Service untuk mengambil data profil pengguna
class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  final SupabaseClient _client = Supabase.instance.client;

  // Mengambil profil pengguna yang sedang login
  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserProfile.fromMap(response);
  }
}
