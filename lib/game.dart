import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int _counter = 0;
  static Color theme = new Color.fromARGB(255, 35, 35, 35);
  double size = 10;
  GoBoard board = GoBoard(theme, 10,1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(size.toInt().toString(),style: TextStyle(fontSize: 30
                  ,color: Colors.white),),
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
                      board = new GoBoard(theme, val.toInt(),1);
                    });
                  }),
              board,
              FloatingActionButton(
                onPressed: () {
                  board.gameBoard.switchDot();
                },
                child: Icon(
                  Icons.invert_colors,
                  color: theme,
                ),
                backgroundColor: Colors.white,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: DropdownButton(
                  icon: Icon(Icons.palette),
                  onChanged: (val){setState(() {
                    board=new GoBoard(theme, size.toInt(),val);
                  });},
                  items: <DropdownMenuItem>[
                    DropdownMenuItem(child:Text("Style 1"),value: 0,),
                    DropdownMenuItem(child:Text("Style 2"),value: 1,)
                  ],
                ),
              ),
            ],
          ),
          color: theme,
        ));
  }
}

