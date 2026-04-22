import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const List<String> emojiSet = [
  "😀","😎","🤖","👻","🐱","🐶","🐼","🐸",
  "🍕","🍔","🍩","🍎","⚽","🏀","🚗","✈️",
  "🌈","⭐","🔥","🎮","🎵","🎲","🧩","🎯"
];

class PersonalPuzzleGame extends StatefulWidget {
  const PersonalPuzzleGame({super.key});

  @override
  State<PersonalPuzzleGame> createState() => _PersonalPuzzleGameState();
}

class _PersonalPuzzleGameState extends State<PersonalPuzzleGame> {
  File? selectedImage;
  Size? imageSize;

  int gridSize = 3;
  List<int> tiles = [];
  int emptyIndex = 0;
  bool puzzleSolved = false;

  bool emojiMode = true;
  String selectedEmoji = "😀";

  @override
  void initState() {
    super.initState();
    initializePuzzle();
  }

  void initializePuzzle() {
    // Generate tiles
    List<int> newTiles = List.generate(gridSize * gridSize, (index) => index);
    int localEmptyIndex;
    do {
      newTiles.shuffle(Random());
      localEmptyIndex = newTiles.indexOf(gridSize * gridSize - 1);
    } while (!isSolvable(newTiles, gridSize, localEmptyIndex));

    tiles = newTiles;
    emptyIndex = localEmptyIndex;
    puzzleSolved = false;

    // Pick random emoji if in emoji mode
    if (emojiMode) {
      selectedEmoji = emojiSet[Random().nextInt(emojiSet.length)];
    }
  }

  bool isSolvable(List<int> puzzle, int size, int emptyIdx) {
    int inversions = 0;
    for (int i = 0; i < puzzle.length; i++) {
      for (int j = i + 1; j < puzzle.length; j++) {
        if (puzzle[i] != size * size - 1 &&
            puzzle[j] != size * size - 1 &&
            puzzle[i] > puzzle[j]) {
          inversions++;
        }
      }
    }
    int emptyRowFromBottom = size - (emptyIdx ~/ size);
    if (size % 2 == 1) {
      return inversions % 2 == 0;
    } else {
      return (emptyRowFromBottom % 2 == 0)
          ? (inversions % 2 == 1)
          : (inversions % 2 == 0);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final width = frameInfo.image.width.toDouble();
      final height = frameInfo.image.height.toDouble();
      frameInfo.image.dispose();

      setState(() {
        selectedImage = file;
        imageSize = Size(width, height);
        emojiMode = false;
        initializePuzzle();
      });
    }
  }

  void moveTile(int index) {
    if (puzzleSolved) return;

    int row = index ~/ gridSize;
    int col = index % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    bool isAdjacent =
        (row == emptyRow && (col - emptyCol).abs() == 1) ||
            (col == emptyCol && (row - emptyRow).abs() == 1);

    if (isAdjacent) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        emptyIndex = index;
        checkWin();
      });
    }
  }

  void checkWin() {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return;
    }
    setState(() => puzzleSolved = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Puzzle Completed! 🎉"),
            content: const Text("Great job solving it!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: const Text("Play Again"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    });
  }

  void resetGame() {
    setState(() {
      initializePuzzle();
    });
  }

  Widget buildPuzzleTile(int index, double tileW, double tileH) {
    const gap = 2.0;

    // EMOJI PUZZLE TILE
    if (emojiMode) {
      if (tiles[index] == gridSize * gridSize - 1 && !puzzleSolved) {
        return Container(
          margin: const EdgeInsets.all(gap),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }

      final tileValue = tiles[index];
      final srcCol = tileValue % gridSize;
      final srcRow = tileValue ~/ gridSize;
      final boardW = tileW * gridSize;
      final boardH = tileH * gridSize;

      return GestureDetector(
        onTap: () => moveTile(index),
        child: Padding(
          padding: const EdgeInsets.all(gap),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: OverflowBox(
              alignment: Alignment.topLeft,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: Offset(-srcCol * tileW, -srcRow * tileH),
                child: Container(
                  width: boardW,
                  height: boardH,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Text(
                    selectedEmoji,
                    style: TextStyle(
                      fontSize: boardW * 0.7,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // IMAGE PUZZLE TILE
    if (selectedImage == null) return const SizedBox();

    if (tiles[index] == gridSize * gridSize - 1 && !puzzleSolved) {
      return Padding(
        padding: const EdgeInsets.all(gap),
        child: Container(
          color: Colors.black38,
        ),
      );
    }

    final tileValue = tiles[index];
    final srcCol = tileValue % gridSize;
    final srcRow = tileValue ~/ gridSize;
    final boardW = tileW * gridSize;
    final boardH = tileH * gridSize;

    return GestureDetector(
      onTap: () => moveTile(index),
      child: Padding(
        padding: const EdgeInsets.all(gap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.translate(
              offset: Offset(-srcCol * tileW, -srcRow * tileH),
              child: Image.file(
                selectedImage!,
                width: boardW,
                height: boardH,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Personal Puzzle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.photo), onPressed: pickImage),
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetGame),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_game_nest_3.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final size in [3, 4, 5])
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        label: Text("${size}x$size"),
                        selected: gridSize == size,
                        onSelected: (_) {
                          setState(() {
                            gridSize = size;
                            initializePuzzle();
                          });
                        },
                      ),
                    )
                ],
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: puzzleSolved && selectedImage != null
                        ? Image.file(selectedImage!)
                        : LayoutBuilder(
                      builder: (context, constraints) {
                        double boardSize = min(
                            constraints.maxWidth, constraints.maxHeight);
                        double tileSize = boardSize / gridSize;
                        return SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                            ),
                            itemCount: tiles.length,
                            itemBuilder: (context, index) {
                              return buildPuzzleTile(
                                  index, tileSize, tileSize);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "👆 Tap tiles adjacent to empty space to move them! 👆",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}