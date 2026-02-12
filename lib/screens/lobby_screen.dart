import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/game_room.dart';
import '../services/game_service.dart';
import 'game_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({
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
            body: const Center(child: Text('La sala no existe.')),
          );
        }

        if (!room.isInLobby) {
          return GameScreen(roomCode: roomCode, gameService: gameService);
        }

        final me = FirebaseAuth.instance.currentUser?.uid;
        final amIHost = room.hostId == me;

        return Scaffold(
          appBar: AppBar(title: Text('Sala $roomCode')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jugadores conectados: ${room.players.length}'),
                const SizedBox(height: 12),
                ...room.players.map(
                  (playerId) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      playerId == me ? 'Tú' : playerId.substring(0, 8),
                    ),
                    trailing: playerId == room.hostId
                        ? const Chip(label: Text('Host'))
                        : null,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: amIHost && room.players.length > 1
                        ? () => gameService.startGame(roomCode)
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar partida'),
                  ),
                ),
                if (amIHost && room.players.length <= 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Necesitas al menos 2 jugadores para iniciar.'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
