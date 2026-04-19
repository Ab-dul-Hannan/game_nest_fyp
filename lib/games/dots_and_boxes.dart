import 'dart:math';
import 'package:flutter/material.dart';

class DotsAndBoxesGame extends StatefulWidget {
  const DotsAndBoxesGame({super.key});

  @override
  State<DotsAndBoxesGame> createState() => _DotsAndBoxesGameState();
}

class _DotsAndBoxesGameState extends State<DotsAndBoxesGame> {
  static const int gridSize = 5;

  Map<String, String> drawnLines = {};
  Map<String, String> boxes = {};

  String currentPlayer = "A";
  int playerAScore = 0;
  int playerBScore = 0;

  bool vsAI = false;
  bool aiThinking = false;

  String getLineKey(int r1, int c1, int r2, int c2) {
    if (r1 > r2 || (r1 == r2 && c1 > c2)) {
      return "$r2,$c2-$r1,$c1";
    }
    return "$r1,$c1-$r2,$c2";
  }

  bool isLineDrawn(int r1, int c1, int r2, int c2) {
    return drawnLines.containsKey(getLineKey(r1, c1, r2, c2));
  }

  bool get isGameOver => boxes.length == (gridSize - 1) * (gridSize - 1);

  bool _applyMove(int r1, int c1, int r2, int c2) {
    drawnLines[getLineKey(r1, c1, r2, c2)] = currentPlayer;
    bool scored = _checkBoxes();
    if (!scored) {
      currentPlayer = currentPlayer == "A" ? "B" : "A";
    }
    return scored;
  }

  bool _checkBoxes() {
    bool scored = false;
    for (int r = 0; r < gridSize - 1; r++) {
      for (int c = 0; c < gridSize - 1; c++) {
        String boxKey = "$r,$c";
        if (boxes.containsKey(boxKey)) continue;
        if (isLineDrawn(r, c, r, c + 1) &&
            isLineDrawn(r, c, r + 1, c) &&
            isLineDrawn(r + 1, c, r + 1, c + 1) &&
            isLineDrawn(r, c + 1, r + 1, c + 1)) {
          boxes[boxKey] = currentPlayer;
          scored = true;
          if (currentPlayer == "A") {
            playerAScore += 10;
          } else {
            playerBScore += 10;
          }
        }
      }
    }
    return scored;
  }

  void drawLine(int r1, int c1, int r2, int c2) {
    if (aiThinking || isLineDrawn(r1, c1, r2, c2) || isGameOver) return;

    setState(() {
      _applyMove(r1, c1, r2, c2);
    });

    _scheduleAiMoveIfNeeded();
  }

  void _scheduleAiMoveIfNeeded() {
    if (!vsAI || currentPlayer != "B" || isGameOver) return;

    setState(() => aiThinking = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final move = _pickAiMove();
      if (move != null) {
        setState(() {
          _applyMove(move[0], move[1], move[2], move[3]);
          aiThinking = false;
        });
        _scheduleAiMoveIfNeeded();
      } else {
        setState(() => aiThinking = false);
      }
    });
  }

  List<int>? _pickAiMove() {
    List<List<int>> winning = [];
    List<List<int>> safe = [];
    List<List<int>> risky = [];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final candidates = <List<int>>[];
        if (c < gridSize - 1 && !isLineDrawn(r, c, r, c + 1)) {
          candidates.add([r, c, r, c + 1]);
        }
        if (r < gridSize - 1 && !isLineDrawn(r, c, r + 1, c)) {
          candidates.add([r, c, r + 1, c]);
        }

        for (final move in candidates) {
          int score = _boxesCompletedBy(move[0], move[1], move[2], move[3]);
          if (score > 0) {
            winning.add(move);
          } else if (_isMoveSafe(move[0], move[1], move[2], move[3])) {
            safe.add(move);
          } else {
            risky.add(move);
          }
        }
      }
    }

    final rng = Random();
    if (winning.isNotEmpty) return winning[rng.nextInt(winning.length)];
    if (safe.isNotEmpty) return safe[rng.nextInt(safe.length)];
    if (risky.isNotEmpty) return risky[rng.nextInt(risky.length)];
    return null;
  }

  int _boxesCompletedBy(int r1, int c1, int r2, int c2) {
    drawnLines[getLineKey(r1, c1, r2, c2)] = "temp";
    int count = 0;
    for (int r = 0; r < gridSize - 1; r++) {
      for (int c = 0; c < gridSize - 1; c++) {
        if (!boxes.containsKey("$r,$c") &&
            isLineDrawn(r, c, r, c + 1) &&
            isLineDrawn(r, c, r + 1, c) &&
            isLineDrawn(r + 1, c, r + 1, c + 1) &&
            isLineDrawn(r, c + 1, r + 1, c + 1)) {
          count++;
        }
      }
    }
    drawnLines.remove(getLineKey(r1, c1, r2, c2));
    return count;
  }

  bool _isMoveSafe(int r1, int c1, int r2, int c2) {
    drawnLines[getLineKey(r1, c1, r2, c2)] = "temp";
    bool safe = true;
    for (int r = 0; r < gridSize - 1 && safe; r++) {
      for (int c = 0; c < gridSize - 1 && safe; c++) {
        if (boxes.containsKey("$r,$c")) continue;
        int sidesDrawn = 0;
        if (isLineDrawn(r, c, r, c + 1)) sidesDrawn++;
        if (isLineDrawn(r, c, r + 1, c)) sidesDrawn++;
        if (isLineDrawn(r + 1, c, r + 1, c + 1)) sidesDrawn++;
        if (isLineDrawn(r, c + 1, r + 1, c + 1)) sidesDrawn++;
        if (sidesDrawn == 3) safe = false;
      }
    }
    drawnLines.remove(getLineKey(r1, c1, r2, c2));
    return safe;
  }

  void resetGame() {
    setState(() {
      drawnLines.clear();
      boxes.clear();
      playerAScore = 0;
      playerBScore = 0;
      currentPlayer = "A";
      aiThinking = false;
    });
  }

  void chooseMode(bool ai) {
    setState(() {
      vsAI = ai;
    });
    resetGame();
  }

  String get statusText {
    if (isGameOver) {
      if (playerAScore > playerBScore) return "🎉 Player A Wins!";
      if (playerBScore > playerAScore) {
        return vsAI ? "🤖 AI Wins!" : "🎉 Player B Wins!";
      }
      return "🤝 It's a Draw!";
    }
    if (aiThinking) return "🤖 AI is thinking...";
    return "Turn: Player $currentPlayer";
  }

  Color _lineColor(String player) {
    return player == "A" ? Colors.red : Colors.blue;
  }

  Widget buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget buildHorizontalLine(int r, int c) {
    String? drawnBy = drawnLines[getLineKey(r, c, r, c + 1)];
    return GestureDetector(
      onTap: () => drawLine(r, c, r, c + 1),
      child: Container(
        width: 40,
        height: 10,
        color: drawnBy != null ? _lineColor(drawnBy) : Colors.grey[300],
      ),
    );
  }

  Widget buildVerticalLine(int r, int c) {
    String? drawnBy = drawnLines[getLineKey(r, c, r + 1, c)];
    return GestureDetector(
      onTap: () => drawLine(r, c, r + 1, c),
      child: Container(
        width: 10,
        height: 40,
        color: drawnBy != null ? _lineColor(drawnBy) : Colors.grey[300],
      ),
    );
  }

  Widget buildBox(int r, int c) {
    String key = "$r,$c";
    String? owner = boxes[key];
    return Container(
      width: 40,
      height: 40,
      color: owner != null
          ? (owner == "A"
          ? Colors.red.withOpacity(0.4)
          : Colors.blue.withOpacity(0.4))
          : Colors.transparent,
      child: Center(
        child: Text(
          owner ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget buildGrid() {
    List<Widget> rows = [];

    for (int r = 0; r < gridSize; r++) {
      List<Widget> row = [];
      for (int c = 0; c < gridSize; c++) {
        row.add(buildDot());
        if (c < gridSize - 1) row.add(buildHorizontalLine(r, c));
      }
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: row));

      if (r < gridSize - 1) {
        List<Widget> row2 = [];
        for (int c = 0; c < gridSize; c++) {
          row2.add(buildVerticalLine(r, c));
          if (c < gridSize - 1) row2.add(buildBox(r, c));
        }
        rows.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: row2));
      }
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Dots & Boxes", style: TextStyle(color: Colors.black)),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_game_nest_7.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🔴 P1: $playerAScore",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    vsAI
                        ? "🔵 AI: $playerBScore"
                        : "🔵 P2: $playerBScore",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                statusText,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),

              const SizedBox(height: 20),

              buildGrid(),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => chooseMode(false),
                    child: const Text("2 Player"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => chooseMode(true),
                    child: const Text("Vs AI"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}