import 'package:flutter/material.dart';

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