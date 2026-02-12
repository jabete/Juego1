import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/game_room.dart';
import 'flag_service.dart';

class GameService {
  GameService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlagService? flagService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _flagService = flagService ?? FlagService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlagService _flagService;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  Future<String> getOrCreateUser() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }
    final credentials = await _auth.signInAnonymously();
    return credentials.user!.uid;
  }

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String> createRoom({int maxRounds = 5}) async {
    final uid = await getOrCreateUser();
    final code = generateRoomCode();

    await _rooms.doc(code).set({
      'hostId': uid,
      'players': [uid],
      'status': 'lobby',
      'currentRound': 0,
      'maxRounds': maxRounds,
      'currentFlag': '',
      'correctAnswer': '',
      'options': <String>[],
      'scores': {uid: 0},
      'lastUpdated': FieldValue.serverTimestamp(),
      'roundAnswers': <String, String>{},
    });

    return code;
  }

  Future<void> joinRoom(String code) async {
    final uid = await getOrCreateUser();
    final roomRef = _rooms.doc(code);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) {
        throw Exception('La sala no existe');
      }

      final data = snapshot.data()!;
      final players = List<String>.from(data['players'] ?? <String>[]);
      if (!players.contains(uid)) {
        players.add(uid);
      }

      final scores = Map<String, dynamic>.from(data['scores'] ?? <String, dynamic>{});
      scores[uid] = (scores[uid] as num?)?.toInt() ?? 0;

      transaction.update(roomRef, {
        'players': players,
        'scores': scores,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> startGame(String code) async {
    final question = _flagService.generateQuestion();

    await _rooms.doc(code).update({
      'status': 'playing',
      'currentRound': 1,
      'currentFlag': question.emoji,
      'correctAnswer': question.answer,
      'options': question.options,
      'roundAnswers': <String, String>{},
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitAnswer({
    required String code,
    required String answer,
  }) async {
    final uid = await getOrCreateUser();
    final roomRef = _rooms.doc(code);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      final data = snapshot.data();
      if (data == null) {
        throw Exception('Sala no encontrada');
      }

      final answers = Map<String, dynamic>.from(data['roundAnswers'] ?? <String, dynamic>{});
      answers[uid] = answer;

      transaction.update(roomRef, {
        'roundAnswers': answers,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> nextRound(String code) async {
    final roomRef = _rooms.doc(code);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);
      final data = snapshot.data();
      if (data == null) {
        throw Exception('Sala no encontrada');
      }

      final correctAnswer = data['correctAnswer'] as String? ?? '';
      final answers = Map<String, dynamic>.from(data['roundAnswers'] ?? <String, dynamic>{});
      final scores = Map<String, dynamic>.from(data['scores'] ?? <String, dynamic>{});

      answers.forEach((uid, value) {
        if (value == correctAnswer) {
          scores[uid] = ((scores[uid] as num?) ?? 0) + 1;
        }
      });

      final currentRound = (data['currentRound'] as num?)?.toInt() ?? 0;
      final maxRounds = (data['maxRounds'] as num?)?.toInt() ?? 5;

      if (currentRound >= maxRounds) {
        transaction.update(roomRef, {
          'status': 'finished',
          'scores': scores,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return;
      }

      final question = _flagService.generateQuestion();

      transaction.update(roomRef, {
        'scores': scores,
        'currentRound': currentRound + 1,
        'currentFlag': question.emoji,
        'correctAnswer': question.answer,
        'options': question.options,
        'roundAnswers': <String, String>{},
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<GameRoom?> watchRoom(String code) {
    return _rooms.doc(code).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return GameRoom.fromSnapshot(snapshot);
    });
  }
}
