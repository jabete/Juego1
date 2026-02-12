import 'dart:math';

class FlagQuestion {
  FlagQuestion({
    required this.emoji,
    required this.answer,
    required this.options,
  });

  final String emoji;
  final String answer;
  final List<String> options;
}

class FlagService {
  final Random _random = Random();

  static const Map<String, String> _flags = {
    '🇦🇷': 'Argentina',
    '🇧🇷': 'Brasil',
    '🇨🇱': 'Chile',
    '🇨🇴': 'Colombia',
    '🇲🇽': 'México',
    '🇺🇸': 'Estados Unidos',
    '🇨🇦': 'Canadá',
    '🇫🇷': 'Francia',
    '🇩🇪': 'Alemania',
    '🇯🇵': 'Japón',
    '🇨🇳': 'China',
    '🇮🇹': 'Italia',
    '🇬🇧': 'Reino Unido',
    '🇰🇷': 'Corea del Sur',
    '🇿🇦': 'Sudáfrica',
  };

  FlagQuestion generateQuestion() {
    final entries = _flags.entries.toList()..shuffle(_random);
    final correct = entries.first;

    final wrongOptions = entries
        .skip(1)
        .take(3)
        .map((entry) => entry.value)
        .toList();

    final allOptions = [...wrongOptions, correct.value]..shuffle(_random);

    return FlagQuestion(
      emoji: correct.key,
      answer: correct.value,
      options: allOptions,
    );
  }
}
