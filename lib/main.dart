// home page is here
import 'package:material_ui/material_ui.dart';
import 'package:sudoku/windows/generate_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: 'Sudoku'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        spacing: 100.0,
        children: [
          const Text(
            "SUDOKU - MAIN MENU",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: .center,
              spacing: 10.0,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerateWindow(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(fixedSize: const Size(200, 50)),
                  child: const Text('Generate Sudoku'),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(fixedSize: const Size(200, 50)),
                  child: const Text('Solve Sudoku'),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(fixedSize: const Size(200, 50)),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
