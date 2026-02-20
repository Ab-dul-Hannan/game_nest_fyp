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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Snake',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(180),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isGameStarted ? 'Playing...' : 'Start Game'),
                      ),
                    ],
                  ),
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                ),
            ],
          ),
        ),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
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