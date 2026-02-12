import 'package:flutter/material.dart';

import '../services/game_service.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.gameService});

  final GameService gameService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _roomController = TextEditingController();
  bool _loading = false;

  Future<void> _createRoom() async {
    setState(() => _loading = true);
    try {
      final roomCode = await widget.gameService.createRoom();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomCode: roomCode,
            gameService: widget.gameService,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _joinRoom() async {
    final code = _roomController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showError('Ingresa un código de sala.');
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.gameService.joinRoom(code);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomCode: code,
            gameService: widget.gameService,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banderas Battle')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adivina banderas en tiempo real',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código de sala',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _joinRoom,
                  child: const Text('Unirme a sala'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _loading ? null : _createRoom,
                  child: const Text('Crear sala'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
