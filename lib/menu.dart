import 'package:flutter/material.dart';
import 'dart:math';

// Game 1: Tic Tac Toe
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool isGameOver = false;

  void playMove(int index) {
    if (board[index] == '' && winner == '' && !isGameOver) {
      setState(() {
        board[index] = currentPlayer;
        checkWinner();
        if (winner == '' && !isBoardFull()) {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  void checkWinner() {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        winner = board[combo[0]];
        isGameOver = true;
        return;
      }
    }

    if (isBoardFull()) {
      winner = 'Draw';
      isGameOver = true;
    }
  }

  bool isBoardFull() {
    return !board.contains('');
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      isGameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (winner.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  winner == 'Draw' ? "It's a Draw!" : 'Winner: $winner',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Current Player: $currentPlayer",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              width: 300,
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => playMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Game 2: Memory Match
class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  List<MemoryCard> cards = [];
  List<int> flippedIndexes = [];
  int matchedPairs = 0;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<String> emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
    List<String> gameCards = [...emojis, ...emojis];
    gameCards.shuffle();

    cards = gameCards
        .map((emoji) => MemoryCard(
      emoji: emoji,
      isFlipped: false,
      isMatched: false,
    ))
        .toList();
  }

  void onCardTap(int index) {
    if (isLocked) return;
    if (flippedIndexes.contains(index)) return;
    if (cards[index].isMatched) return;
    if (flippedIndexes.length == 2) return;

    setState(() {
      cards[index].isFlipped = true;
      flippedIndexes.add(index);
    });

    if (flippedIndexes.length == 2) {
      checkMatch();
    }
  }

  void checkMatch() {
    setState(() {
      isLocked = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        if (cards[flippedIndexes[0]].emoji ==
            cards[flippedIndexes[1]].emoji) {
          cards[flippedIndexes[0]].isMatched = true;
          cards[flippedIndexes[1]].isMatched = true;
          matchedPairs++;
        } else {
          cards[flippedIndexes[0]].isFlipped = false;
          cards[flippedIndexes[1]].isFlipped = false;
        }

        flippedIndexes.clear();
        isLocked = false;

        if (matchedPairs == 8) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text('You won!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: const Text('Play Again'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  void resetGame() {
    setState(() {
      initializeGame();
      flippedIndexes.clear();
      matchedPairs = 0;
      isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Matches: $matchedPairs / 8',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onCardTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cards[index].isFlipped || cards[index].isMatched
                            ? Colors.white
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          cards[index].isFlipped || cards[index].isMatched
                              ? cards[index].emoji
                              : '❓',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryCard {
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
  });
}

// Game 3: Connect Four - FIXED
class ConnectFourGame extends StatefulWidget {
  const ConnectFourGame({super.key});

  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  static const int rows = 6;
  static const int cols = 7;
  List<List<String>> board = List.generate(rows, (_) => List.filled(cols, ''));
  String currentPlayer = '🔴';
  String winner = '';
  bool isGameOver = false;

  void dropPiece(int col) {
    if (winner.isNotEmpty || isGameOver) return;

    for (int row = rows - 1; row >= 0; row--) {
      if (board[row][col] == '') {
        setState(() {
          board[row][col] = currentPlayer;
          checkWinner(row, col);
          if (winner.isEmpty && !isGameOver) {
            currentPlayer = currentPlayer == '🔴' ? '🟡' : '🔴';
          }
        });
        return;
      }
    }
  }

  void checkWinner(int row, int col) {
    // Check horizontal
    if (checkDirection(row, col, 0, 1) + checkDirection(row, col, 0, -1) >= 3) {
      winner = currentPlayer;
      isGameOver = true;
      return;
    }

    // Check vertical
    if (checkDirection(row, col, 1, 0) >= 3) {
      winner = currentPlayer;
      isGameOver = true;
      return;
    }

    // Check diagonal (down-right)
    if (checkDirection(row, col, 1, 1) + checkDirection(row, col, -1, -1) >= 3) {
      winner = currentPlayer;
      isGameOver = true;
      return;
    }

    // Check diagonal (down-left)
    if (checkDirection(row, col, 1, -1) + checkDirection(row, col, -1, 1) >= 3) {
      winner = currentPlayer;
      isGameOver = true;
      return;
    }

    // Check for draw
    bool isDraw = true;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] == '') {
          isDraw = false;
          break;
        }
      }
    }
    if (isDraw) {
      winner = 'Draw';
      isGameOver = true;
    }
  }

  int checkDirection(int row, int col, int rowDir, int colDir) {
    int count = 0;
    int r = row + rowDir;
    int c = col + colDir;

    while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == currentPlayer) {
      count++;
      r += rowDir;
      c += colDir;
    }
    return count;
  }

  void resetGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, ''));
      currentPlayer = '🔴';
      winner = '';
      isGameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Four'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes
          double cellSize = constraints.maxWidth / (cols + 2);
          cellSize = cellSize.clamp(30, 45); // Limit size between 30 and 45

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (winner.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        winner == 'Draw' ? "It's a Draw!" : 'Winner: $winner',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Current Player: $currentPlayer",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: List.generate(rows, (row) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(cols, (col) {
                            return GestureDetector(
                              onTap: () => dropPiece(col),
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: board[row][col].isEmpty
                                      ? Colors.white
                                      : board[row][col] == '🔴'
                                      ? Colors.red
                                      : Colors.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20), // Add some bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Game 4: Snake
class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  List<Point> snake = [Point(10, 10), Point(9, 10), Point(8, 10)];
  late Point food;
  String direction = 'right';
  bool isGameOver = false;
  bool isGameStarted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    generateNewFood();
  }

  void generateNewFood() {
    final random = Random();
    do {
      food = Point(
        random.nextInt(gridSize),
        random.nextInt(gridSize),
      );
    } while (snake.contains(food));
  }

  void moveSnake() {
    if (isGameOver || !isGameStarted) return;

    setState(() {
      Point newHead;
      switch (direction) {
        case 'up':
          newHead = Point(snake[0].x, snake[0].y - 1);
          break;
        case 'down':
          newHead = Point(snake[0].x, snake[0].y + 1);
          break;
        case 'left':
          newHead = Point(snake[0].x - 1, snake[0].y);
          break;
        case 'right':
          newHead = Point(snake[0].x + 1, snake[0].y);
          break;
        default:
          return;
      }

      // Check wall collision
      if (newHead.x < 0 || newHead.x >= gridSize ||
          newHead.y < 0 || newHead.y >= gridSize) {
        gameOver();
        return;
      }

      // Check self collision
      if (snake.contains(newHead)) {
        gameOver();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        generateNewFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void gameOver() {
    setState(() {
      isGameOver = true;
      isGameStarted = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Your Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [Point(10, 10), Point(9, 10), Point(8, 10)];
      direction = 'right';
      isGameOver = false;
      isGameStarted = false;
      score = 0;
      generateNewFood();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: isGameStarted
                      ? null
                      : () {
                    setState(() {
                      isGameStarted = true;
                    });
                    startGameLoop();
                  },
                  child: Text(isGameStarted ? 'Playing...' : 'Start Game'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int x = index % gridSize;
                    int y = index ~/ gridSize;
                    Point point = Point(x, y);

                    if (snake.contains(point)) {
                      return Container(
                        color: Colors.green,
                        child: point == snake[0]
                            ? const Center(
                          child: Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 10,
                          ),
                        )
                            : null,
                      );
                    } else if (food == point) {
                      return Container(
                        color: Colors.red,
                      );
                    } else {
                      return Container(
                        color: Colors.grey[300],
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          if (isGameStarted)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDirectionButton(Icons.arrow_upward, 'up'),
                  const SizedBox(width: 8),
                  _buildDirectionButton(Icons.arrow_downward, 'down'),
                  const SizedBox(width: 8),
                  _buildDirectionButton(Icons.arrow_back, 'left'),
                  const SizedBox(width: 8),
                  _buildDirectionButton(Icons.arrow_forward, 'right'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, String dir) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if ((dir == 'up' && direction != 'down') ||
              (dir == 'down' && direction != 'up') ||
              (dir == 'left' && direction != 'right') ||
              (dir == 'right' && direction != 'left')) {
            direction = dir;
          }
        });
      },
      child: Icon(icon),
    );
  }

  void startGameLoop() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (isGameStarted && mounted) {
        moveSnake();
        startGameLoop();
      }
    });
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

// Game 5: Hangman - COMPLETELY FIXED
class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<String> words = [
    'FLUTTER', 'DART', 'PROGRAMMING', 'DEVELOPER', 'ANDROID', 'PYTHON',
    'JAVA', 'SWIFT', 'KOTLIN', 'RUST', 'GO', 'TYPESCRIPT'
  ];

  late String selectedWord;
  late Set<String> guessedLetters;
  late List<String> displayWord;
  int wrongGuesses = 0;
  final int maxWrongGuesses = 6;
  bool isGameOver = false;
  bool isGameWon = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    final random = Random();
    selectedWord = words[random.nextInt(words.length)];
    guessedLetters = {};
    displayWord = List.filled(selectedWord.length, '_');
    wrongGuesses = 0;
    isGameOver = false;
    isGameWon = false;
  }

  void guessLetter(String letter) {
    if (isGameOver || isGameWon || guessedLetters.contains(letter)) return;

    setState(() {
      guessedLetters.add(letter);

      if (selectedWord.contains(letter)) {
        // Update display word
        for (int i = 0; i < selectedWord.length; i++) {
          if (selectedWord[i] == letter) {
            displayWord[i] = letter;
          }
        }

        // Check if won
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
      appBar: AppBar(
        title: const Text('Hangman'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hangman drawing
            Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: HangmanPainter(wrongGuesses),
                size: const Size(200, 200),
              ),
            ),

            // Word display
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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

            // Wrong guesses counter
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
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

            // Keyboard
            Expanded(
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
                      foregroundColor: isGuessed ? Colors.white : null,
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
          ],
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

    // Draw gallows
    canvas.drawLine(Offset(20, size.height - 20), Offset(80, size.height - 20), paint); // base
    canvas.drawLine(Offset(50, size.height - 20), Offset(50, 20), paint); // vertical pole
    canvas.drawLine(Offset(50, 20), Offset(150, 20), paint); // top beam
    canvas.drawLine(Offset(150, 20), Offset(150, 50), paint); // rope

    // Draw hangman based on wrong guesses
    if (wrongGuesses >= 1) {
      // Head
      canvas.drawCircle(Offset(150, 80), 15, paint);
    }
    if (wrongGuesses >= 2) {
      // Body
      canvas.drawLine(Offset(150, 95), Offset(150, 150), paint);
    }
    if (wrongGuesses >= 3) {
      // Left arm
      canvas.drawLine(Offset(150, 110), Offset(130, 130), paint);
    }
    if (wrongGuesses >= 4) {
      // Right arm
      canvas.drawLine(Offset(150, 110), Offset(170, 130), paint);
    }
    if (wrongGuesses >= 5) {
      // Left leg
      canvas.drawLine(Offset(150, 150), Offset(130, 180), paint);
    }
    if (wrongGuesses >= 6) {
      // Right leg
      canvas.drawLine(Offset(150, 150), Offset(170, 180), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Original GameHubHome moved from main.dart
class GameHubHome extends StatelessWidget {
  const GameHubHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60), // Add margin at the top
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/game_nest_menu_games.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              GameCard(
                title: 'Tic Tac Toe',
                icon: Icons.grid_3x3,
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TicTacToeGame()),
                ),
              ),
              GameCard(
                title: 'Memory Match',
                icon: Icons.style,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoryMatchGame()),
                ),
              ),
              GameCard(
                title: 'Connect 4',
                icon: Icons.circle,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConnectFourGame()),
                ),
              ),
              GameCard(
                title: 'Snake',
                icon: Icons.bolt,
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SnakeGame()),
                ),
              ),
              GameCard(
                title: 'Hangman',
                icon: Icons.abc,
                color: Colors.red,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HangmanGame()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}