// the window where the solver.cpp solves the puzzle for you
import "dart:io";
import "dart:convert";

import "package:material_ui/material_ui.dart";

class SolverWindow extends StatefulWidget {
  const SolverWindow({super.key});

  @override
  State<SolverWindow> createState() => _SolverWindowState();
}

class _SolverWindowState extends State<SolverWindow> {
  int boardVer = 0;

  List<List<Color>> cellColor = List.generate(
    9,
    (i) => List.generate(9, (j) => Colors.white),
  );
  List<List<String>> board = List.generate(
    9,
    (i) => List.generate(9, (j) => ""),
  );
  List<String> allowed = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ""];

  // first sends input to logic_solver.cpp then waits and reads the output
  Future<List<List<String>>> cppCom(List<List<String>> board) async {
    final process = await Process.start("./lib/logic/logic_solver", []);
    final List<List<String>> newboard = [];
    final List<List<String>> zero = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => (board[i][j].trim() == "") ? "0" : board[i][j],
      ),
    );
    for (final row in zero) {
      process.stdin.writeln(row.join(" "));
    }
    await process.stdin.close();

    final String output = await utf8.decodeStream(process.stdout);
    final String errors = await utf8.decodeStream(process.stderr);

    if (errors.isNotEmpty) {
      print("Cpp Error: \n$errors");
    }

    final List<String> lines = output.split('\n');
    for (String line in lines) {
      final List<String> row = [];
      final List<String> numbers = line.trim().split(RegExp(r'\s+'));

      for (String numStr in numbers) {
        if (numStr.isNotEmpty) {
          row.add(numStr);
        }
      }
      newboard.add(row);
    }

    return newboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        spacing: 20.0,
        children: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "<--",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              selectionColor: Colors.green,
            ),
          ),
          Column(
            mainAxisAlignment: .center,
            spacing: 20.0,
            children: [
              // The 9x9 sudoku board
              Column(
                mainAxisAlignment: .center,
                children: List.generate(9, (i) {
                  return Row(
                    mainAxisAlignment: .center,
                    children: List.generate(9, (j) {
                      final boldBorderT = ((i == 3) || (i == 6));
                      final boldBorderB = ((i == 2) || (i == 5));
                      final boldBorderL = ((j == 3) || (j == 6));
                      final boldBorderR = ((j == 2) || (j == 5));
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: (boldBorderT
                                    ? Colors.red
                                    : Colors.white),
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: (boldBorderB)
                                    ? Colors.red
                                    : Colors.white,
                                width: 2,
                              ),
                              left: BorderSide(
                                color: (boldBorderL)
                                    ? Colors.red
                                    : Colors.white,
                                width: 2,
                              ),
                              right: BorderSide(
                                color: (boldBorderR)
                                    ? Colors.red
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          child: TextFormField(
                            key: ValueKey("$boardVer-$i-$j"),
                            initialValue: board[i][j],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 20,
                              color: cellColor[i][j],
                            ),
                            onChanged: (val) {
                              board[i][j] = val.trim();
                              cellColor[i][j] = Colors.white;
                            },
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              Row(
                spacing: 10.0,
                mainAxisAlignment: .center,
                children: [
                  FilledButton(
                    onPressed: () async {
                      bool validVal = false;
                      // input validation
                      for (int i = 0; i < 9; i++) {
                        for (int j = 0; j < 9; j++) {
                          if (board[i][j] == "") {
                            cellColor[i][j] = Colors.yellow; //yellow denotes the cells filled by logic_solver
                          }
                          // checking for invalid value
                          for (int n = 0; n < 10; n++) {
                            if (board[i][j] == allowed[n]) {
                              validVal = true;
                              break;
                            } else {
                              validVal = false;
                            }
                          }
                          // checking in block
                          int blockRow = (i / 3).toInt();
                          int blockCol = (j / 3).toInt();
                          for (
                            int x = 3 * (blockRow);
                            x < 3 * (blockRow + 1);
                            x++
                          ) {
                            for (
                              int y = 3 * (blockCol);
                              y < 3 * (blockCol + 1);
                              y++
                            ) {
                              if (i == x && j == y) {
                                continue;
                              }
                              if (board[i][j] == board[x][y] &&
                                  board[i][j] != "") {
                                validVal = false;
                                break;
                              }
                            }
                          }

                          // checking in column
                          for (int x = 0; x < 9; x++) {
                            if (x == i) {
                              continue;
                            }
                            if (board[x][j] == board[i][j] &&
                                board[i][j] != "") {
                              validVal = false;
                              break;
                            }
                          }

                          // checking in row
                          for (int y = 0; y < 9; y++) {
                            if (y == j) {
                              continue;
                            }
                            if (board[i][j] == board[i][y] &&
                                board[i][j] != "") {
                              validVal = false;
                              break;
                            }
                          }
                          if (validVal == false) {
                            break;
                          }
                        }
                        if (validVal == false) {
                          break;
                        }
                      }
                      if (validVal == false) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 60,
                              ),
                              title: Text(
                                "Invalid input",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              content: Text(
                                "A cell can only have single digit(1-9), no row,column or block shall have the same digit.",
                                textAlign: .center,
                              ),
                              actionsAlignment: .center,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Retry"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return PopScope(
                              canPop: false,
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                content: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 20,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text(
                                      "Solving puzzle please wait...",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        try {
                          final newBoard = await cppCom(board);
                          if (!context.mounted) return;
                          setState(() {
                            board = newBoard;
                            boardVer++;
                          });
                        } finally {
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }
                        // validating if board was solvable or no
                        for (int i = 0; i < 9; i++) {
                          for (int j = 0; j < 9; j++) {
                            if (board[i][j] == "0") {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    title: Text(
                                      "Failure",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: Text(
                                      "The given board is not solvable.",
                                      textAlign: .center,
                                    ),
                                    actionsAlignment: .center,
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Retry"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      }
                    },
                    child: Text(
                      "Solve",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < 9; i++) {
                          for (int j = 0; j < 9; j++) {
                            board[i][j] = "";
                          }
                        }

                        boardVer++;
                      });
                    },
                    child: Text("Clear all"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
