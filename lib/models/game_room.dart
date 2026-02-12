import 'package:cloud_firestore/cloud_firestore.dart';

class GameRoom {
  GameRoom({
    required this.id,
    required this.hostId,
    required this.players,
    required this.status,
    required this.currentRound,
    required this.maxRounds,
    required this.currentFlag,
    required this.options,
    required this.scores,
    required this.lastUpdated,
  });

  final String id;
  final String hostId;
  final List<String> players;
  final String status;
  final int currentRound;
  final int maxRounds;
  final String currentFlag;
  final List<String> options;
  final Map<String, int> scores;
  final Timestamp lastUpdated;

  factory GameRoom.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final scoreMap = Map<String, dynamic>.from(data['scores'] ?? <String, dynamic>{});

    return GameRoom(
      id: snapshot.id,
      hostId: data['hostId'] as String? ?? '',
      players: List<String>.from(data['players'] ?? <String>[]),
      status: data['status'] as String? ?? 'lobby',
      currentRound: data['currentRound'] as int? ?? 0,
      maxRounds: data['maxRounds'] as int? ?? 5,
      currentFlag: data['currentFlag'] as String? ?? '',
      options: List<String>.from(data['options'] ?? <String>[]),
      scores: scoreMap.map((key, value) => MapEntry(key, (value as num).toInt())),
      lastUpdated: data['lastUpdated'] as Timestamp? ?? Timestamp.now(),
    );
  }

  bool get isFinished => status == 'finished';
  bool get isInLobby => status == 'lobby';
}
