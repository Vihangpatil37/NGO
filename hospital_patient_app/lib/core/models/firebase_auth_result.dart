class FirebaseAuthResult {
  final String sessionToken;
  final bool isNewPatient;

  FirebaseAuthResult({
    required this.sessionToken,
    required this.isNewPatient,
  });

  factory FirebaseAuthResult.fromJson(Map<String, dynamic> json) {
    return FirebaseAuthResult(
      sessionToken: json['sessionToken'] ?? '',
      isNewPatient: json['isNewPatient'] == true,
    );
  }
}
