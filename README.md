# Banderas Battle (Multijugador para Play Store)

Juego móvil multijugador para Android hecho con Flutter + Firebase donde los jugadores crean una sala, se unen con código y compiten adivinando banderas.

## Qué incluye este prototipo

- Crear sala con código único.
- Unirse a sala existente.
- Lobby con lista de jugadores conectados.
- Host inicia partida.
- Rondas de preguntas de banderas con 4 opciones.
- Puntuación en tiempo real y ranking final.

## Stack

- Flutter (UI multiplataforma)
- Firebase Auth (anónimo)
- Cloud Firestore (sincronización en tiempo real)

## Configuración rápida

1. Instala Flutter y Android Studio.
2. Crea un proyecto Firebase.
3. Habilita:
   - Authentication → Anonymous
   - Cloud Firestore
4. Ejecuta:

```bash
flutterfire configure
```

5. Asegúrate de inicializar Firebase en `main.dart`.
6. Corre la app:

```bash
flutter pub get
flutter run
```

## Estructura

- `lib/main.dart`: arranque de la app.
- `lib/services/game_service.dart`: lógica multijugador con Firestore.
- `lib/services/flag_service.dart`: banco de banderas y preguntas.
- `lib/screens/*`: pantallas Home, Lobby y Partida.
- `lib/models/game_room.dart`: modelo de la sala de juego.

## Recomendaciones antes de publicar en Play Store

- Añadir sistema de perfiles (nickname/avatar).
- Implementar anti-spam y tiempo límite por ronda.
- Añadir sonidos, animaciones y feedback visual.
- Crear reglas de seguridad de Firestore robustas.
- Integrar Firebase App Check y Crashlytics.
- Soporte para idioma inglés/español.
