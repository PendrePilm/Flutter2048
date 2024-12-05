import 'package:flutter/material.dart';
import 'dart:math';
import 'package:collection/collection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<List<int>> grid = List.generate(4, (_) => List.generate(4, (_) => 0));
  int score = 0;
  bool isGameOver = false;
  bool isWon = false;
  int targetValue = 2048;

  @override
  void initState() {
    super.initState();
    _addRandomTile();
    _addRandomTile();
  }

  void _addRandomTile() {
    Random rand = Random();
    List<List<int>> emptyCells = [];

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      List<int> randomCell = emptyCells[rand.nextInt(emptyCells.length)];
      int row = randomCell[0];
      int col = randomCell[1];
      int value = rand.nextBool() ? 2 : 4;

      setState(() {
        grid[row][col] = value;
      });
    }
  }

  bool _checkForWin() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (grid[row][col] == targetValue) {
          return true;
        }
      }
    }
    return false;
  }

  bool _checkForGameOver() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (grid[row][col] == 0) {
          return false;
        }
        if (row < 3 && grid[row][col] == grid[row + 1][col]) {
          return false;
        }
        if (col < 3 && grid[row][col] == grid[row][col + 1]) {
          return false;
        }
      }
    }
    return true;
  }

  bool _moveLeft() {
    bool moved = false;
    int newScore = score;

    List<List<int>> oldGrid = grid.map((row) => List<int>.from(row)).toList();

    for (int row = 0; row < 4; row++) {
      List<int> newRow = grid[row].where((e) => e != 0).toList();
      for (int i = 0; i < newRow.length - 1; i++) {
        if (newRow[i] == newRow[i + 1]) {
          newRow[i] *= 2;
          newScore += newRow[i];
          newRow.removeAt(i + 1);
          moved = true;
        }
      }
      while (newRow.length < 4) {
        newRow.add(0);
      }
      grid[row] = newRow;
    }

    if (!ListEquality().equals(grid, oldGrid)) {
      moved = true;
      setState(() {
        score = newScore;
      });
    }

    return moved;
  }

  bool _moveRight() {
    setState(() {
      grid = grid.map((row) => row.reversed.toList()).toList();
    });

    bool moved = _moveLeft();

    setState(() {
      grid = grid.map((row) => row.reversed.toList()).toList();
    });

    return moved;
  }

  bool _moveUp() {
    setState(() {
      grid = List.generate(4, (col) =>
          List.generate(4, (row) => grid[row][col], growable: false),
      );
    });

    bool moved = _moveLeft();

    setState(() {
      grid = List.generate(4, (row) =>
          List.generate(4, (col) => grid[col][row], growable: false),
      );
    });

    return moved;
  }

  bool _moveDown() {
    setState(() {
      grid = List.generate(4, (col) =>
          List.generate(4, (row) => grid[row][col], growable: false),
      );
    });

    setState(() {
      grid = grid.map((row) => row.reversed.toList()).toList();
    });

    bool moved = _moveLeft();

    setState(() {
      grid = grid.map((row) => row.reversed.toList()).toList();
    });

    setState(() {
      grid = List.generate(4, (row) =>
          List.generate(4, (col) => grid[col][row], growable: false),
      );
    });

    return moved;
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => 0));
      score = 0;
      isGameOver = false;
      isWon = false;
      _addRandomTile();
      _addRandomTile();
    });
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Color(0xFFEEE4DA);
      case 4:
        return Color(0xFFEEE1C9);
      case 8:
        return Color(0xFFF3B27A);
      case 16:
        return Color(0xFFF69664);
      case 32:
        return Color(0xFFF77C5F);
      case 64:
        return Color(0xFFF75F3B);
      case 128:
        return Color(0xFFEDD073);
      case 256:
        return Color(0xFFEDCC62);
      case 512:
        return Color(0xFFEDC950);
      case 1024:
        return Color(0xFFEDC53F);
      case 2048:
        return Color(0xFFEDC22E);
      default:
        return Color(0xFFCDC1B4);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isWon) {
      return _buildGameOverDialog("Vous avez gagné !");
    }

    if (isGameOver) {
      return _buildGameOverDialog("Vous avez perdu !");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('2048 Game'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Score: $score',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGrid(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text("Recommencer"),
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: targetValue,
              onChanged: (int? newValue) {
                setState(() {
                  targetValue = newValue!;
                });
              },
              items: [256, 512, 1024, 2048].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('Atteindre $value'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverDialog(String message) {
    return Scaffold(
      appBar: AppBar(title: Text('2048 Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text("Recommencer"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          if (_moveLeft()) {
            _addRandomTile();
            _checkGameState();
          }
        } else if (details.primaryVelocity! > 0) {
          if (_moveRight()) {
            _addRandomTile();
            _checkGameState();
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          if (_moveUp()) {
            _addRandomTile();
            _checkGameState();
          }
        } else if (details.primaryVelocity! > 0) {
          if (_moveDown()) {
            _addRandomTile();
            _checkGameState();
          }
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.width,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            int row = index ~/ 4;
            int col = index % 4;
            int value = grid[row][col];
            return Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getTileColor(value),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value > 0 ? '$value' : '',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: value >= 128 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkGameState() {
    if (_checkForWin()) {
      setState(() {
        isWon = true;
      });
    }
    if (_checkForGameOver()) {
      setState(() {
        isGameOver = true;
      });
    }
  }
}
