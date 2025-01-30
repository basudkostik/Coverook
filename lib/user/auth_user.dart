import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  final String? name;
  final String? userName;
  final DateTime? accountCreationTime;
  final String? photoUrl;
  final bool? isSeller;
  final int? followingCount;
  final int? followerCount;
  final int? booksCount;
  final int? likesCount;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.name,
    this.userName,
    this.accountCreationTime,
    this.photoUrl,
    this.isSeller,
    this.followingCount,
    this.followerCount,
    this.booksCount,
    this.likesCount,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
        id: user.uid, isEmailVerified: user.emailVerified, email: user.email!);
  }
}
