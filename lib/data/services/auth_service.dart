import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:moneyboys/data/Models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthService {
  /// Google Sign-In
  static Future<UserModel?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User hủy login

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final userModel = UserModel(
      id: userCredential.user!.uid,
      email: userCredential.user!.email!,
      passwordHash: '', // social login, không cần password
      name: userCredential.user!.displayName,
      createdAt: DateTime.now(),
    );

    await saveUserToSupabase(userModel);
    return userModel;
  }

  /// Facebook Sign-In
  static Future<UserModel?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;

    final facebookCredential = FacebookAuthProvider.credential(
      result.accessToken!.token,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      facebookCredential,
    );

    final userModel = UserModel(
      id: userCredential.user!.uid,
      email: userCredential.user!.email!,
      passwordHash: '',
      name: userCredential.user!.displayName,
      createdAt: DateTime.now(),
    );

    await saveUserToSupabase(userModel);
    return userModel;
  }

  /// Lưu UserModel vào Supabase
  static Future<void> saveUserToSupabase(UserModel user) async {
    await supabase.from('users').upsert(user.toMap());
  }
}
