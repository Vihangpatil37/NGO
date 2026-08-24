export 'package:flutter/material.dart';

class TokenResult {
  final int tokenNumber;
  final String caseNumber;
  final int queuePosition;
  final String tokenId;
  final String registrationId;
  final String sessionToken;
  final String patientName;
  final bool alreadyRegistered;

  TokenResult({
    required this.tokenNumber,
    required this.caseNumber,
    required this.queuePosition,
    required this.tokenId,
    required this.registrationId,
    required this.sessionToken,
    required this.patientName,
    this.alreadyRegistered = false,
  });

  factory TokenResult.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] ?? {};
    return TokenResult(
      tokenNumber: json['tokenNumber'] ?? 0,
      caseNumber: json['caseNumber'] ?? '',
      queuePosition: json['queuePosition'] ?? 0,
      tokenId: json['tokenId'] ?? '',
      registrationId: json['registrationId'] ?? '',
      sessionToken: json['sessionToken'] ?? '',
      patientName: patient['name'] ?? '',
      alreadyRegistered: json['alreadyRegistered'] ?? false,
    );
  }
}
