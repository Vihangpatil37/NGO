enum QueueState { waiting, almostTurn, yourTurn, completed, skipped }

class TokenStatus {
  final int tokenNumber;
  final String status;
  final int queuePosition;
  final int? currentlyServing;
  final String patientName;
  final String caseNumber;

  TokenStatus({
    required this.tokenNumber,
    required this.status,
    required this.queuePosition,
    this.currentlyServing,
    required this.patientName,
    required this.caseNumber,
  });

  QueueState get queueState {
    if (status == 'skipped') return QueueState.skipped;
    if (status == 'called' || status == 'in_consultation') return QueueState.yourTurn;
    if (status == 'completed') return QueueState.completed;
    
    // Status is 'active'
    if (queuePosition <= 2) return QueueState.almostTurn;
    return QueueState.waiting;
  }

  factory TokenStatus.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? {};
    final patient = json['patient'] ?? {};
    return TokenStatus(
      tokenNumber: token['tokenNumber'] ?? 0,
      status: token['status'] ?? 'unknown',
      queuePosition: json['queuePosition'] ?? 0,
      currentlyServing: json['currentlyServing'],
      patientName: patient['name'] ?? '',
      caseNumber: patient['caseNumber'] ?? '',
    );
  }
}
