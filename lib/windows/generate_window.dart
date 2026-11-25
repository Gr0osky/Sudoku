// the window where you generate a puzzle for yourself
import "dart:io";

import "package:material_ui/material_ui.dart";

class GenerateWindow extends StatefulWidget {
  const GenerateWindow({super.key});

  @override
  State<GenerateWindow> createState() => _GenerateWindowState();
}

class _GenerateWindowState extends State<GenerateWindow> {
  int? _diff = 1;
  int boardVer = 0;

  List<List<String>> board = [
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
  ];
  List<String> allowed = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

  // reads the values printed by reader.cpp, by breaking input into lines and reaching numbers from the lines
  Future<List<List<String>>> boardRead(int? diff) async {
    final printed = await Process.run('./lib/logic/reader', [diff.toString()]);

    if (printed.exitCode != 0) {
      throw Exception(printed.stderr);
    }

    final String output = printed.stdout.toString().trim();
    final List<List<String>> board = [];
    final List<String> lines = output.split('\n');

    for (String line in lines) {
      final List<String> row = [];
      final List<String> numbers = line.trim().split(RegExp(r'\s+'));

      for (String numStr in numbers) {
        if (numStr.isNotEmpty) {
          row.add(numStr);
        }
      }
      board.add(row);
    }
    return board;
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
            crossAxisAlignment: .center,
            children: [
              // The 9x9 sudoku table
              Column(
                mainAxisAlignment: .center,
                children: List.generate(board.length, (i) {
                  return Row(
                    mainAxisAlignment: .center,
                    children: List.generate(board[i].length, (j) {
                      final bool edit = (board[i][j].trim() == "0");
                      final bool boldBorderT = ((i == 3) || (i == 6));
                      final bool boldBorderB = (i == 2) || (i == 5);
                      final bool boldBorderL = ((j == 3) || (j == 6));
                      final bool boldBorderR = ((j == 2) || (j == 5));
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: (boldBorderT)
                                    ? Colors.red
                                    : Colors.white,
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
                            initialValue: edit ? "" : board[i][j],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            readOnly: !edit,
                            style: TextStyle(
                              fontSize: 18,
                              color: edit ? Colors.yellow : Colors.white,
                            ),
                            onChanged: (val) {
                              board[i][j] = val.trim();
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
                  Text(
                    "Difficulty: ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // note: the difficulty only changes the number of clues
                  DropdownMenu(
                    initialSelection: _diff,
                    label: Text("Select Difficulty"),
                    onSelected: (int? newDiff) {
                      setState(() {
                        _diff = newDiff;
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 1, label: "Easy"),
                      DropdownMenuEntry(value: 2, label: "Medium"),
                      DropdownMenuEntry(value: 3, label: "Hard"),
                    ],
                  ),
                ],
              ),
              FilledButton(
                onPressed: () async {
                  List<List<String>> newBoard = await boardRead(_diff);
                  board = newBoard;
                  boardVer++;
                  setState(() {});
                },
                child: Text(
                  "Generate",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                // this is a dart implementation of the check function in logic.cpp
                // note that here its being applied to all cells, whereas the logic_solver.cpp function is only applied to empty cells with specific k values.
                onPressed: () {
                  bool correct = true;
                  for (int i = 0; i < 9; i++) {
                    for (int j = 0; j < 9; j++) {
                      int blockRow = (i / 3).toInt();
                      int blockCol = (j / 3).toInt();

                      // check in block
                      for (int x = 3 * blockRow; x < 3 * (blockRow + 1); x++) {
                        for (
                          int y = 3 * blockCol;
                          y < 3 * (blockCol + 1);
                          y++
                        ) {
                          if (x == i && y == j) {
                            continue;
                          }
                          if (board[x][y] == board[i][j]) {
                            correct = false;
                            break;
                          }
                        }
                        if (correct == false) {
                          break;
                        }
                      }

                      if (correct == false) {
                        break;
                      }

                      // check in column
                      for (int x = 0; x < 9; x++) {
                        if (x == i) {
                          continue;
                        }
                        if (board[x][j] == board[i][j]) {
                          correct = false;
                          break;
                        }
                      }

                      // check in row
                      for (int y = 0; y < 9; y++) {
                        if (y == j) {
                          continue;
                        }
                        if (board[i][y] == board[i][j]) {
                          correct = false;
                          break;
                        }
                      }

                      // check for validity of entered values
                      bool validVal = false;
                      for (int n = 0; n < 9; n++) {
                        if (board[i][j].trim() == allowed[n]) {
                          validVal = true;
                        }
                      }
                      if (validVal == false) {
                        correct = false;
                        break;
                      }
                    }
                    if (correct == false) {
                      break;
                    }
                  }
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        icon: Icon(
                          correct ? Icons.check_circle : Icons.cancel,
                          color: correct ? Colors.green : Colors.red,
                          size: 60,
                        ),
                        title: Text(
                          correct ? "Correct!" : "Wrong solution",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: correct ? Colors.green : Colors.red,
                          ),
                        ),
                        content: Text(
                          correct
                              ? "Great job, i genuinely cant solve most sudokus without a computing algorithm."
                              : "Try again! Any block, row or column shall not have repeating digits.",
                          textAlign: .center,
                        ),
                        actionsAlignment: .center,
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(correct ? "Next" : "Retry"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Submit solution",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
