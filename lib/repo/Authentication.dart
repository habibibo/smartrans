import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<void> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      //print(user);
    } catch (error) {
      throw Exception('Error signing in with Google: $error');
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      throw Exception('Error signing out from Google: $error');
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    GoogleSignInAccount? user = await _googleSignIn.signIn();
    return user;
  }
}
