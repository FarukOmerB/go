import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int _counter = 0;
  static Color darkTheme = new Color.fromARGB(255, 35, 35, 35);
  //light mode static Color darkTheme = new Color.fromARGB(255, 196, 196, 196);

  static List<TableTheme> tableThemes = [
    TableTheme(
        style: 1,
        background: Color.fromARGB(255, 35, 35, 35),
        edgeColor: new Color.fromARGB(255, 57, 57, 57),
        insideColor: new Color.fromARGB(255, 43, 42, 42),
        lineColor: new Color.fromARGB(255, 30, 30, 30)),
    TableTheme(
        style: 1,
        background: Color.fromARGB(255, 200, 200, 200),
        edgeColor: new Color.fromARGB(255, 186, 186, 186),
        insideColor: new Color.fromARGB(255, 196, 196, 196),
        lineColor: new Color.fromARGB(255, 114, 114, 114)),
    TableTheme(
        style: 1,
        background: Color.fromARGB(255, 222, 222, 222),
        edgeColor: new Color.fromARGB(255, 209, 170, 110),
        insideColor: new Color.fromARGB(255, 231, 179, 98),
        lineColor: new Color.fromARGB(255, 137, 108, 59)),
    TableTheme(style: 2, background: Color.fromARGB(255, 35, 35, 35), lineColor: Colors.white)
  ];
  int theme = 0;
  double size = 10;
  GoBoard board = GoBoard(10, tableThemes[0]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                size.toInt().toString(),
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              Slider(
                  value: size,
                  max: 20,
                  min: 2,
                  divisions: 18,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white10,
                  onChanged: (val) {
                    setState(() {
                      size = val;
                      board = GoBoard(size.toInt(), tableThemes[theme]);
                    });
                  }),
              board,
              FloatingActionButton(
                onPressed: () {
                  board.gameBoard.switchDot();
                },
                child: Icon(
                  Icons.invert_colors,
                  color: darkTheme,
                ),
                backgroundColor: Colors.white,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: DropdownButton(
                  icon: Icon(Icons.palette),
                  onChanged: (val) {
                    setState(() {
                      theme = val;
                      board = GoBoard(size.toInt(), tableThemes[val]);
                    });
                  },
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(
                      child: Text("Dark"),
                      value: 0,
                    ),
                    DropdownMenuItem(
                      child: Text("Light"),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text("Original"),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text("Line Light"),
                      value: 3,
                    )
                  ],
                ),
              ),
            ],
          ),
          color: board.tableTheme.background,
        ));
  }
}
