import 'dart:convert';

/// Represents a user profile matching the Supabase `public.profiles` database schema.
class UserModel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String region;
  final String currency;
  final String accountType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    required this.region,
    required this.currency,
    required this.accountType,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create a UserModel from a Map (e.g. Supabase DB or SQLite row).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      firstname: map['firstname'] as String? ?? '',
      lastname: map['lastname'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phone_number'] as String?,
      profileImage: map['profile_image'] as String?,
      region: map['region'] as String? ?? 'Africa',
      currency: map['currency'] as String? ?? 'NGN',
      accountType: map['account_type'] as String? ?? 'individual',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Converts UserModel to a Map for SQLite caching or JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'region': region,
      'currency': currency,
      'account_type': accountType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  UserModel copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? region,
    String? currency,
    String? accountType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      region: region ?? this.region,
      currency: currency ?? this.currency,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
