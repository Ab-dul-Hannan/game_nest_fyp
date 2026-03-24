import 'package:flutter/material.dart';
import 'dart:math';

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

  int gameSpeed = 200;

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

      if (newHead.x < 0 || newHead.x >= gridSize ||
          newHead.y < 0 || newHead.y >= gridSize) {
        gameOver();
        return;
      }

      if (snake.contains(newHead)) {
        gameOver();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        generateNewFood();
        if (gameSpeed > 80) gameSpeed -= 5;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      gameSpeed = 200;
      generateNewFood();
    });
  }

  void handleSwipeUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    setState(() {
      if (dx.abs() > dy.abs()) {
        if (dx > 0 && direction != 'left') direction = 'right';
        if (dx < 0 && direction != 'right') direction = 'left';
      } else {
        if (dy > 0 && direction != 'up') direction = 'down';
        if (dy < 0 && direction != 'down') direction = 'up';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Snake', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetGame),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_game_nest_4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(isGameStarted ? 'Playing...' : 'Start', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onPanUpdate: handleSwipeUpdate,
                  child: Center(
                    child: Container(
                      width: 320,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            childAspectRatio: 320 / 420,
                          ),
                          itemCount: gridSize * gridSize,
                          itemBuilder: (context, index) {
                            int x = index % gridSize;
                            int y = index ~/ gridSize;
                            Point point = Point(x, y);

                            if (snake.contains(point)) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: point == snake[0] ? Colors.lightGreenAccent : Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            } else if (food == point) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            } else {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startGameLoop() {
    Future.delayed(Duration(milliseconds: gameSpeed), () {
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
