// Our own tiny user class, so screens never need to import firebase_auth.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  const AppUser({required this.uid, this.email, this.displayName});

 
  String get friendlyName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim().split(' ').first; // first name only
    }
    if (email != null && email!.contains('@')) {
      final prefix = email!.split('@').first;
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }
    return 'there';
  }
}