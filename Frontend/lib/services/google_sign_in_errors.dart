/// Typed failures from [obtainGoogleIdToken] / Google Sign-In setup (localize in UI).
enum GoogleSignInFailureKind {
  webClientIdMissing,
  idTokenMissing,
  signInError,
}

class GoogleSignInFailure implements Exception {
  const GoogleSignInFailure(this.kind, {this.detail});

  final GoogleSignInFailureKind kind;
  final String? detail;

  @override
  String toString() => 'GoogleSignInFailure($kind, detail: $detail)';
}
