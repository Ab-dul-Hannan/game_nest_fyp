import 'dart:math';
import 'package:flutter/material.dart';

class MatchManiaGame extends StatefulWidget {
  const MatchManiaGame({super.key});

  @override
  State<MatchManiaGame> createState() => _MatchManiaGameState();
}

class _MatchManiaGameState extends State<MatchManiaGame> {
  static const int gridSize = 8;
  static const int candyTypes = 5;

  List<List<int>> board = [];
  int? selectedRow;
  int? selectedCol;

  int score = 0;
  int level = 1;
  int targetScore = 100;

  @override
  void initState() {
    super.initState();
    generateBoard();
  }

  void generateBoard() {
    board = List.generate(
      gridSize,
          (_) => List.generate(gridSize, (_) => Random().nextInt(candyTypes)),
    );
    // Remove any initial matches
    while (hasMatches()) {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (isPartOfMatch(r, c)) {
            board[r][c] = Random().nextInt(candyTypes);
          }
        }
      }
    }
  }

  bool hasMatches() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize - 2; c++) {
        if (board[r][c] == board[r][c + 1] && board[r][c] == board[r][c + 2]) {
          return true;
        }
      }
    }
    for (int c = 0; c < gridSize; c++) {
      for (int r = 0; r < gridSize - 2; r++) {
        if (board[r][c] == board[r + 1][c] && board[r][c] == board[r + 2][c]) {
          return true;
        }
      }
    }
    return false;
  }

  bool isPartOfMatch(int row, int col) {
    // Check horizontal
    int horizontalCount = 1;
    for (int c = col - 1; c >= 0 && board[row][c] == board[row][col]; c--) horizontalCount++;
    for (int c = col + 1; c < gridSize && board[row][c] == board[row][col]; c++) horizontalCount++;
    if (horizontalCount >= 3) return true;

    // Check vertical
    int verticalCount = 1;
    for (int r = row - 1; r >= 0 && board[r][col] == board[row][col]; r--) verticalCount++;
    for (int r = row + 1; r < gridSize && board[r][col] == board[row][col]; r++) verticalCount++;
    if (verticalCount >= 3) return true;

    return false;
  }

  Color getCandyColor(int value) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[value % colors.length];
  }

  void onTileTap(int row, int col) {
    if (selectedRow == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else {
      if (isAdjacent(row, col, selectedRow!, selectedCol!)) {
        // Try swap
        swap(row, col, selectedRow!, selectedCol!);

        // Check if swap created a match
        if (hasMatches()) {
          checkMatches();
        } else {
          // Swap back if no match
          swap(row, col, selectedRow!, selectedCol!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No match! Try another swap."),
              duration: Duration(milliseconds: 800),
            ),
          );
        }
      }
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    }
  }

  bool isAdjacent(int r1, int c1, int r2, int c2) {
    return (r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1);
  }

  void swap(int r1, int c1, int r2, int c2) {
    int temp = board[r1][c1];
    board[r1][c1] = board[r2][c2];
    board[r2][c2] = temp;
  }

  void checkMatches() async {
    bool matched = true;

    while (matched) {
      matched = false;
      Set<String> toClear = {};

      // Horizontal matches
      for (int r = 0; r < gridSize; r++) {
        int streak = 1;
        for (int c = 1; c < gridSize; c++) {
          if (board[r][c] == board[r][c - 1] && board[r][c] != -1) {
            streak++;
          } else {
            if (streak >= 3) {
              for (int i = 0; i < streak; i++) {
                toClear.add("$r,${c - 1 - i}");
              }
            }
            streak = 1;
          }
        }
        if (streak >= 3) {
          for (int i = 0; i < streak; i++) {
            toClear.add("$r,${gridSize - 1 - i}");
          }
        }
      }

      // Vertical matches
      for (int c = 0; c < gridSize; c++) {
        int streak = 1;
        for (int r = 1; r < gridSize; r++) {
          if (board[r][c] == board[r - 1][c] && board[r][c] != -1) {
            streak++;
          } else {
            if (streak >= 3) {
              for (int i = 0; i < streak; i++) {
                toClear.add("${r - 1 - i},$c");
              }
            }
            streak = 1;
          }
        }
        if (streak >= 3) {
          for (int i = 0; i < streak; i++) {
            toClear.add("${gridSize - 1 - i},$c");
          }
        }
      }

      if (toClear.isNotEmpty) {
        matched = true;

        // Add score based on number of candies cleared
        int pointsEarned = toClear.length * 10;
        setState(() {
          score += pointsEarned;
        });

        // Show points popup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("+$pointsEarned points!"),
              duration: const Duration(milliseconds: 300),
            ),
          );
        }

        // Clear matches
        for (var pos in toClear) {
          var parts = pos.split(",");
          int r = int.parse(parts[0]);
          int c = int.parse(parts[1]);
          board[r][c] = -1;
        }

        // Drop candies
        await dropCandies();

        setState(() {});
      }
    }

    checkLevelUp();
  }

  Future<void> dropCandies() async {
    for (int c = 0; c < gridSize; c++) {
      List<int> column = [];

      for (int r = gridSize - 1; r >= 0; r--) {
        if (board[r][c] != -1) {
          column.add(board[r][c]);
        }
      }

      while (column.length < gridSize) {
        column.add(Random().nextInt(candyTypes));
      }

      for (int r = gridSize - 1; r >= 0; r--) {
        board[r][c] = column[gridSize - 1 - r];
      }
    }
  }

  void checkLevelUp() {
    if (score >= targetScore) {
      setState(() {
        level++;
        score = 0;
        targetScore += 100;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Level Up! 🎉 Now on Level $level"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void resetGame() {
    setState(() {
      score = 0;
      level = 1;
      targetScore = 100;
      generateBoard();
      selectedRow = null;
      selectedCol = null;
    });
  }

  Widget buildTile(int r, int c) {
    int value = board[r][c];

    return GestureDetector(
      onTap: () => onTileTap(r, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value == -1 ? Colors.grey[300] : getCandyColor(value),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (selectedRow == r && selectedCol == c)
                ? Colors.white
                : Colors.grey.shade300,
            width: (selectedRow == r && selectedCol == c) ? 4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: value != -1 ? Icon(
            _getCandyIcon(value),
            color: Colors.white.withOpacity(0.8),
            size: 30,
          ) : null,
        ),
      ),
    );
  }

  IconData _getCandyIcon(int value) {
    List<IconData> icons = [
      Icons.favorite,      // Heart
      Icons.star,          // Star
      Icons.circle,        // Circle
      Icons.square,        // Square
      Icons.diamond,       // Diamond
    ];
    return icons[value % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Match Mania - Level $level", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: "Reset Game",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_game_nest_7.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Score Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("SCORE", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(
                          "$score",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink),
                        ),
                      ],
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.shade300),
                    Column(
                      children: [
                        const Text("TARGET", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(
                          "$targetScore",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.shade300),
                    Column(
                      children: [
                        const Text("LEVEL", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(
                          "$level",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: score / targetScore,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Game Board
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gridSize * gridSize,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemBuilder: (context, index) {
                      int r = index ~/ gridSize;
                      int c = index % gridSize;
                      return buildTile(r, c);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Instructions
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  "👆 Tap adjacent shapes to swap and match 3+ in a row! 👆",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}