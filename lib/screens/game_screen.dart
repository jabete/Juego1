import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/game_room.dart';
import '../services/game_service.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.roomCode,
    required this.gameService,
  });

  final String roomCode;
  final GameService gameService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameRoom?>(
      stream: gameService.watchRoom(roomCode),
      builder: (context, snapshot) {
        final room = snapshot.data;
        if (room == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Sala no disponible')),
          );
        }

        final myUid = FirebaseAuth.instance.currentUser?.uid;
        final myAnswer = myUid == null ? null : room.scores[myUid];

        if (room.isFinished) {
          final ranking = room.scores.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Scaffold(
            appBar: AppBar(title: const Text('Resultados finales')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('🏁 Partida terminada', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                ...ranking.map(
                  (entry) => ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: Text(
                      entry.key == myUid ? 'Tú' : entry.key.substring(0, 8),
                    ),
                    trailing: Text('${entry.value} pts'),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Ronda ${room.currentRound}/${room.maxRounds}')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¿De qué país es esta bandera?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    room.currentFlag,
                    style: const TextStyle(fontSize: 88),
                  ),
                ),
                const SizedBox(height: 24),
                ...room.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonal(
                      onPressed: () => gameService.submitAnswer(
                        code: roomCode,
                        answer: option,
                      ),
                      child: Text(option),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu puntaje: ${myAnswer ?? 0}',
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (room.hostId == myUid)
                  ElevatedButton(
                    onPressed: () => gameService.nextRound(roomCode),
                    child: const Text('Siguiente ronda'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
