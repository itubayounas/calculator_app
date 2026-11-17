// Our own tiny user class, so screens never need to import firebase_auth.
class AppUser {
  final String uid;
  final String? email;

  const AppUser({required this.uid, this.email});
}
