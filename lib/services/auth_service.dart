import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../offline/database_helper.dart';

/// Authentication Service handling Supabase Auth & read-only local profile caching.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Returns the current signed in user ID or null.
  String? get currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Registers a new user with Supabase Auth.
  /// Passes all user profile attributes in `data` (meta_data) which triggers
  /// automated creation of `public.profiles` in Postgres.
  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String phoneNumber,
    required String region,
    required String currency,
    required String accountType,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'phone_number': phoneNumber.trim(),
        'region': region,
        'currency': currency,
        'account_type': accountType,
      },
    );

    // If registration succeeded and returned a user, fetch profile & cache locally (read-only)
    if (response.user != null) {
      final userModel = UserModel(
        id: response.user!.id,
        firstname: firstname.trim(),
        lastname: lastname.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        region: region,
        currency: currency,
        accountType: accountType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await cacheUserProfileLocally(userModel);
    }

    return response;
  }

  /// Caches the user profile in SQLite as a read-only local reference for offline viewing.
  Future<void> cacheUserProfileLocally(UserModel user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'local_profiles',
        {
          'id': user.id,
          'first_name': user.firstname,
          'last_name': user.lastname,
          'email': user.email,
          'updated_at': user.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Local profile caching warning: $e');
      }
    }
  }

  /// Fetches the read-only cached user profile from SQLite when offline.
  Future<UserModel?> getCachedUserProfile(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'local_profiles',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        return UserModel(
          id: map['id'] as String,
          firstname: map['first_name'] as String? ?? '',
          lastname: map['last_name'] as String? ?? '',
          email: map['email'] as String? ?? '',
          region: 'Africa',
          currency: 'NGN',
          accountType: 'individual',
          updatedAt: map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'].toString())
              : null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Error reading cached user profile: $e');
      }
    }
    return null;
  }

  /// Verifies email OTP token sent to user's email.
  Future<AuthResponse> verifyEmailOTP({
    required String email,
    required String token,
  }) async {
    return await _supabaseClient.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.signup,
    );
  }

  /// Resends email OTP token to user's email.
  Future<void> resendOTP({required String email}) async {
    await _supabaseClient.auth.resend(
      email: email.trim(),
      type: OtpType.signup,
    );
  }

  /// Signs in a user with email & password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      final profile = await getUserProfile(response.user!.id);
      if (profile != null) {
        await cacheUserProfileLocally(profile);
      }
    }

    return response;
  }

  /// Fetches profile from Supabase profiles table, falling back to local SQLite cache if offline.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final userModel = UserModel.fromMap(data);
        await cacheUserProfileLocally(userModel);
        return userModel;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Supabase fetch error, attempting local cache: $e');
      }
    }

    return await getCachedUserProfile(userId);
  }

  /// Creates a new business account in `public.business_accounts` and updates user profile `account_type` to `'business'`.
  Future<void> createBusinessAccount({
    required String businessName,
    String? businessEmail,
    String? businessPhoneNumber,
    String? certificateOfRegistration,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to create a business account.');
    }

    // 1. Insert into business_accounts table
    await _supabaseClient.from('business_accounts').insert({
      'owner_id': userId,
      'business_name': businessName.trim(),
      'business_email': businessEmail?.trim(),
      'business_phone_number': businessPhoneNumber?.trim(),
      'certificate_of_registration': certificateOfRegistration?.trim(),
      'status': 'active',
    });

    // 2. Update profiles table account_type to 'business'
    await _supabaseClient.from('profiles').update({
      'account_type': 'business',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// Updates current user profile details in Supabase profiles table, user metadata, and SQLite local cache.
  Future<UserModel> updateUserProfile({
    required String firstname,
    required String lastname,
    String? phoneNumber,
    String? profileImage,
    required String region,
    required String currency,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User must be logged in to update profile information.');
    }

    final updatedAt = DateTime.now();

    // 1. Update Supabase public.profiles table
    try {
      await _supabaseClient.from('profiles').update({
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'phone_number': phoneNumber?.trim(),
        if (profileImage != null) 'profile_image': profileImage,
        'region': region,
        'currency': currency,
        'updated_at': updatedAt.toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Supabase profiles update warning/error: $e');
      }
    }

    // 2. Update Supabase Auth user metadata
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'firstname': firstname.trim(),
            'lastname': lastname.trim(),
            'phone_number': phoneNumber?.trim(),
            'region': region,
            'currency': currency,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Supabase Auth metadata update warning: $e');
      }
    }

    // 3. Build updated UserModel & cache locally in SQLite
    final currentUser = _supabaseClient.auth.currentUser;
    final updatedModel = UserModel(
      id: userId,
      firstname: firstname.trim(),
      lastname: lastname.trim(),
      email: currentUser?.email ?? '',
      phoneNumber: phoneNumber?.trim(),
      profileImage: profileImage,
      region: region,
      currency: currency,
      accountType: 'individual',
      updatedAt: updatedAt,
    );

    await cacheUserProfileLocally(updatedModel);

    return updatedModel;
  }

  /// Uploads profile avatar image file to Supabase Storage bucket 'avatars' (or returns local file path if offline/fallback).
  Future<String> uploadProfileAvatar(File imageFile) async {
    try {
      final userId = currentUserId;
      if (userId == null) return imageFile.path;

      final fileBytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final path = '$userId/avatar.$fileExt';

      await _supabaseClient.storage.from('avatars').uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(
          upsert: true,
        ),
      );

      final publicUrl = _supabaseClient.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('[AuthService] Supabase avatar storage upload warning: $e');
      }
      return imageFile.path;
    }
  }

  /// Signs out current user session.
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
