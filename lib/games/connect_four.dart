import 'package:flutter/material.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Connect Four',
          style: TextStyle(color: Colors.black), // Changed to black
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Changed icons to black
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
            image: AssetImage('assets/images/bg_game_nest_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cellSize = constraints.maxWidth / (cols + 2);
            cellSize = cellSize.clamp(30, 45);

            return SafeArea(
              child: SingleChildScrollView(
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
                              color: Colors.black, // Changed to black
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
                              color: Colors.black, // Changed to black
                            ),
                          ),
                        ),
                      // Removed the blue background container, now just the game board
                      Column(
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}