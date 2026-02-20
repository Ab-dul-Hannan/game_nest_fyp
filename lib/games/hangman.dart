import 'package:flutter/material.dart';
import 'dart:math';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<Map<String, String>> wordsWithHints = [
    {'word': 'FLUTTER', 'hint': 'Google\'s UI toolkit for building natively compiled applications'},
    {'word': 'DART', 'hint': 'Programming language optimized for building mobile apps'},
    {'word': 'PROGRAMMING', 'hint': 'Process of creating computer software'},
    {'word': 'DEVELOPER', 'hint': 'Person who creates software applications'},
    {'word': 'ANDROID', 'hint': 'Mobile operating system by Google'},
    {'word': 'PYTHON', 'hint': 'Programming language named after a snake'},
    {'word': 'JAVA', 'hint': 'Programming language with a coffee cup logo'},
    {'word': 'SWIFT', 'hint': 'Programming language created by Apple'},
    {'word': 'KOTLIN', 'hint': 'Modern programming language that runs on JVM'},
    {'word': 'RUST', 'hint': 'Systems programming language focused on safety'},
    {'word': 'GO', 'hint': 'Programming language created at Google, also called Golang'},
    {'word': 'TYPESCRIPT', 'hint': 'Typed superset of JavaScript'}
  ];

  late String selectedWord;
  late String selectedHint;
  late Set<String> guessedLetters;
  late List<String> displayWord;
  int wrongGuesses = 0;
  final int maxWrongGuesses = 6;
  bool isGameOver = false;
  bool isGameWon = false;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    final random = Random();
    final wordData = wordsWithHints[random.nextInt(wordsWithHints.length)];
    selectedWord = wordData['word']!;
    selectedHint = wordData['hint']!;
    guessedLetters = {};
    displayWord = List.filled(selectedWord.length, '_');
    wrongGuesses = 0;
    isGameOver = false;
    isGameWon = false;
    showHint = false;
  }

  void guessLetter(String letter) {
    if (isGameOver || isGameWon || guessedLetters.contains(letter)) return;

    setState(() {
      guessedLetters.add(letter);

      if (selectedWord.contains(letter)) {
        for (int i = 0; i < selectedWord.length; i++) {
          if (selectedWord[i] == letter) {
            displayWord[i] = letter;
          }
        }

        if (!displayWord.contains('_')) {
          isGameWon = true;
          _showGameOverDialog(true);
        }
      } else {
        wrongGuesses++;
        if (wrongGuesses >= maxWrongGuesses) {
          isGameOver = true;
          _showGameOverDialog(false);
        }
      }
    });
  }

  void _showGameOverDialog(bool won) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(won ? '🎉 Congratulations!' : '💀 Game Over!'),
            content: Text(
              won
                  ? 'You guessed the word: $selectedWord'
                  : 'The word was: $selectedWord',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    startNewGame();
                  });
                },
                child: const Text('Play Again', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back', style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Hangman',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                startNewGame();
              });
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_game_nest_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: HangmanPainter(wrongGuesses),
                    size: const Size(200, 200),
                  ),
                ),

                // Hint Section - Modified to show full text
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hint:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              showHint ? selectedHint : 'Tap the lightbulb to reveal a hint!',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          showHint ? Icons.visibility_off : Icons.lightbulb,
                          color: Colors.amber,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            showHint = !showHint;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: displayWord.map((letter) {
                      return Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: letter != '_' ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: letter != '_' ? Colors.blue : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Wrong Guesses: $wrongGuesses / $maxWrongGuesses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: wrongGuesses >= maxWrongGuesses ? Colors.red : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: 7,
                      padding: const EdgeInsets.all(8),
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.2,
                      children: List.generate(26, (index) {
                        String letter = String.fromCharCode(65 + index);
                        bool isGuessed = guessedLetters.contains(letter);
                        bool isCorrect = selectedWord.contains(letter);

                        Color? buttonColor;
                        if (isGuessed) {
                          buttonColor = isCorrect ? Colors.green : Colors.red;
                        }

                        return ElevatedButton(
                          onPressed: (isGuessed || isGameOver || isGameWon)
                              ? null
                              : () => guessLetter(letter),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: isGuessed ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongGuesses;

  HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(20, size.height - 20), Offset(80, size.height - 20), paint);
    canvas.drawLine(Offset(50, size.height - 20), Offset(50, 20), paint);
    canvas.drawLine(Offset(50, 20), Offset(150, 20), paint);
    canvas.drawLine(Offset(150, 20), Offset(150, 50), paint);

    if (wrongGuesses >= 1) {
      canvas.drawCircle(Offset(150, 80), 15, paint);
    }
    if (wrongGuesses >= 2) {
      canvas.drawLine(Offset(150, 95), Offset(150, 150), paint);
    }
    if (wrongGuesses >= 3) {
      canvas.drawLine(Offset(150, 110), Offset(130, 130), paint);
    }
    if (wrongGuesses >= 4) {
      canvas.drawLine(Offset(150, 110), Offset(170, 130), paint);
    }
    if (wrongGuesses >= 5) {
      canvas.drawLine(Offset(150, 150), Offset(130, 180), paint);
    }
    if (wrongGuesses >= 6) {
      canvas.drawLine(Offset(150, 150), Offset(170, 180), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}