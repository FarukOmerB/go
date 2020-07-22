import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Board {
  int size;
  List<List<int>> dots;
  int dot = 1;
  Board(int size) {
    this.size = size;
    this.dots = List.generate(this.size, (index) => List.generate(this.size, (index) => 0));
  }

  void clear() {
    this.dots = List.generate(this.size, (index) => List.generate(this.size, (index) => 0));
  }

  void switchDot() {
    this.dot = dot == 1 ? 2 : 1;
  }
}

class Piece {
  int x;
  int y;
  int id;
  int color;
  bool open;
  Board _board;
  List<Piece> memory;
  bool dead;

  Piece(int x, int y, Board board) {
    this.x = x;
    this.y = y;
    this._board = board;

    if (x.isNegative || y.isNegative || x >= _board.dots.length || y >= _board.dots.length) {
      this.dead = true;
    } else {
      this.dead = false;
      this.id = hashValues(x, y);
      this.color = _board.dots[y][x];
      this.open = isOpen();
      this.memory = [this];
    }
  }

  bool isOpen() {
    if (!dead) {
      bool right = x + 1 < this._board.dots.length ? (_board.dots[y][x + 1] == 0) : false;
      bool left = x - 1 >= 0 ? (_board.dots[y][x - 1] == 0) : false;
      bool top = y + 1 < this._board.dots.length ? (_board.dots[y + 1][x] == 0) : false;
      bool bottom = y - 1 >= 0 ? (_board.dots[y - 1][x] == 0) : false;

      return left || right || top || bottom;
    } else {
      return false;
    }
  }

  void trace(int x, int y, Piece sp, int op) {
    int self = _board.dots[y][x];

    if (self != 0 && self != op) {
      Piece left;
      Piece right;
      Piece top;
      Piece bottom;

      if (x + 1 < _board.dots.length && this._board.dots[y][x + 1] != op && this._board.dots[y][x + 1] != 0) {
        right = new Piece(x + 1, y, _board);

        bool state = true;

        sp.memory.forEach((i) {
          if (i.id == right.id) {
            state = false;
          }
        });

        if (state) {
          sp.memory.add(right);
          right.trace(x + 1, y, sp, op);
        }
      }
      if (x - 1 >= 0 && this._board.dots[y][x - 1] != op && this._board.dots[y][x - 1] != 0) {
        left = new Piece(x - 1, y, _board);

        bool state = true;

        sp.memory.forEach((i) {
          if (i.id == left.id) {
            state = false;
          }
        });

        if (state) {
          sp.memory.add(left);
          left.trace(x - 1, y, sp, op);
        }
      }
      if (y + 1 < _board.dots.length && this._board.dots[y + 1][x] != op && this._board.dots[y + 1][x] != 0) {
        top = new Piece(x, y + 1, _board);
        bool state = true;

        sp.memory.forEach((i) {
          if (i.id == top.id) {
            state = false;
          }
        });

        if (state) {
          sp.memory.add(top);
          top.trace(x, y + 1, sp, op);
        }
      }
      if (y - 1 >= 0 && this._board.dots[y - 1][x] != op && this._board.dots[y - 1][x] != 0) {
        bottom = new Piece(x, y - 1, _board);
        bool state = true;

        sp.memory.forEach((i) {
          if (i.id == bottom.id) {
            state = false;
          }
        });

        if (state) {
          sp.memory.add(bottom);
          bottom.trace(x, y - 1, sp, op);
        }
      }
    }
  }

  void isBreathing(int x, int y,List<Piece> sp, int op) {

    if(!(x.isNegative || x>=this._board.size || y.isNegative || y>=this._board.size)){
      int self = _board.dots[y][x];

      if (self != 0 && self != op ) {
        Piece left;
        Piece right;
        Piece top;
        Piece bottom;

        if (x + 1 < _board.dots.length && this._board.dots[y][x + 1] != op && this._board.dots[y][x + 1] != 0) {
          right = new Piece(x + 1, y, _board);

          bool state = true;

          sp.forEach((i) {
            if (i.id == right.id) {
              state = false;
            }
          });

          if (state) {
            sp.add(right);
            right.isBreathing(x + 1, y, sp, op);
          }
        }
        if (x - 1 >= 0 && this._board.dots[y][x - 1] != op && this._board.dots[y][x - 1] != 0) {
          left = new Piece(x - 1, y, _board);

          bool state = true;

          sp.forEach((i) {
            if (i.id == left.id) {
              state = false;
            }
          });

          if (state) {
            sp.add(left);
            left.isBreathing(x - 1, y, sp, op);
          }
        }
        if (y + 1 < _board.dots.length && this._board.dots[y + 1][x] != op && this._board.dots[y + 1][x] != 0) {
          top = new Piece(x, y + 1, _board);
          bool state = true;

          sp.forEach((i) {
            if (i.id == top.id) {
              state = false;
            }
          });

          if (state) {
            sp.add(top);
            top.isBreathing(x, y + 1, sp, op);
          }
        }
        if (y - 1 >= 0 && this._board.dots[y - 1][x] != op && this._board.dots[y - 1][x] != 0) {
          bottom = new Piece(x, y - 1, _board);
          bool state = true;

          sp.forEach((i) {
            if (i.id == bottom.id) {
              state = false;
            }
          });

          if (state) {
            sp.add(bottom);
            bottom.isBreathing(x, y - 1, sp, op);
          }
        }
      }}
  }

  bool calcCapture(int op) {
    bool state = true;
    bool kill=false;

    if (!dead && this.color != op && this.color != 0) {
      this.open = isOpen();
      trace(this.x, this.y, this, op);

      this.memory.forEach((i) {
        if (i.open) {
          state = false;
        }
      });

      if (state) {
        this.memory.forEach((i) {
          kill=true;
          this._board.dots[i.y][i.x] = 0;
        });
      }
    }

    return kill;
  }

  void result() {
    Piece left = new Piece(this.x - 1, this.y, this._board);
    Piece right = new Piece(this.x + 1, y, this._board);
    Piece top = new Piece(this.x, this.y + 1, this._board);
    Piece bottom = new Piece(this.x, this.y - 1, this._board);

    int opposite = this.color == 1 ? 2 : 1;
    List<Piece> neighbours=[this];
    this.isBreathing(this.x, this.y, neighbours, opposite);
    bool breathing=false;
    neighbours.forEach((f){
      if(f.isOpen()){breathing=true;}
    });

    bool l = left.calcCapture(this.color);
    bool r = right.calcCapture(this.color);
    bool t = top.calcCapture(this.color);
    bool b = bottom.calcCapture(this.color);

    if (!(l || r || t || b ) && !breathing) {
      _board.dots[y][x] = 0;
    }
  }
}


class GoBoard extends StatelessWidget {
  Color theme;
  int size;
  Board gameBoard;
  int style;

  GoBoard(Color theme, int size,int style) {
    this.size = size;
    this.theme = theme;
    this.style=style;
    this.gameBoard = new Board(this.size);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
              child: GestureDetector(
            onLongPress: () {
              gameBoard.clear();
              (context as Element).markNeedsBuild();
            },
            onTapUp: (data) {
              //print(data.localPosition);
              double step = context.size.width.toInt() / (gameBoard.size + 1);
              int y = (data.localPosition.dy / step).round() - 1;
              int x = (data.localPosition.dx / step).round() - 1;
              //print("$x $y");
              if ((x >= 0 && x < gameBoard.size && y >= 0 && y < gameBoard.size)) {
                gameBoard.dots[y][x] = gameBoard.dots[y][x] == 0 ? gameBoard.dot : 0;
                Piece movement = new Piece(x, y, gameBoard);
                movement.result();

                (context as Element).markNeedsBuild();
              }
              //dot = dot == 1 ? 2 : 1;
            },
            child: this.style==1?CustomPaint(painter: Table(dots: gameBoard.dots)):CustomPaint(painter: Tile(dark: theme, light: Colors.white, width: 0.4, dots: gameBoard.dots)),
          )),
        ),
      ],
    );
  }
}

class Table extends CustomPainter {
  Color dark=new Color.fromARGB(255, 30, 30, 30);
  Color light=Colors.white;
  double width=0.4;
  bool isNull;
  List<List<int>> dots;
  double radius=10;
  Table({
    this.isNull,
    this.dots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    boardDraw(canvas, size,);
  }

  void boardDraw(Canvas canvas, Size size, ){

    int count = dots.length;
    double step = count.toDouble() + 1.0;

    Paint line = new Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = width*2.2;

    Paint edges = new Paint()
      ..color = new Color.fromARGB(255, 57, 57, 57)
      ..style = PaintingStyle.fill;

    Paint inside = new Paint()
      ..color = new Color.fromARGB(255, 43, 42, 42)
      ..style = PaintingStyle.fill;


    canvas.drawShadow(Path()..moveTo(size.width / step-10,size.height / step-10)..lineTo( size.width - size.width / step+10, size.height / step-10)..lineTo(size.width - size.width / step+10, size
        .height - size.height / step+10)
      ..lineTo(size.width / step-10, size.height - size.height / step+10)..close(), Colors.black.withOpacity(0.5), 7, true);

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(size.width / step-10, size.height / step-10, size.width - size.width / step+10, size.height - size.height / step+10,
            topRight: Radius.circular(radius), topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius), bottomLeft: Radius.circular(radius)),
        edges);

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(size.width / step, size.height / step, size.width - size.width / step, size.height - size.height / step,
            topRight: Radius.circular(radius), topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius), bottomLeft: Radius.circular(radius)),
        inside);

    canvas.drawPath(
        Path()..moveTo(size.width / step-10,size.height / step-10)..lineTo( (size.width - size.width / step+10), size.height / step-10)
          ..lineTo(size.width / step-10, (size.height - size.height / step+10)/2)..close(),
        new Paint()..color=Colors.white.withAlpha(1));

    for (int i = 2; i < count; i++) {
      canvas.drawLine(Offset(i * (size.width / step), size.width / step), Offset(i * size.width / step, size.height-size.width / step), line);

      for (int j = 2; j < count; j++) {
        canvas.drawLine(Offset(size.width / step, j * (size.height / step)), Offset(size.width-size.width / step, j * size.height / step), line);
      }
    }

    for (int i = 0; i < count; i++) {
      double x = (i.toDouble() + 1) * (size.width / step);
      for (int j = 0; j < count; j++) {
        double y = (j.toDouble() + 1) * (size.height / step);

        double radius=size.width / step / 2.2;

        Paint white = new Paint()
          ..color = light
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill
          ..strokeWidth = width
          ..shader=LinearGradient(
            colors: [new Color.fromARGB(255, 250, 250, 250), new Color.fromARGB(255, 160, 160, 160),],
            stops: [0,0.5],
            end: Alignment.bottomRight,
            begin: Alignment.topLeft
          ).createShader(Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: radius));

        Paint black = new Paint()
          ..color = dark
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill
          ..strokeWidth = width
          ..shader=LinearGradient(
            colors: [new Color.fromARGB(255, 70, 70, 70),new Color.fromARGB(255, 30, 30, 30)],
              stops: [0,0.5],
              end: Alignment.bottomRight,
              begin: Alignment.topLeft
          ).createShader(Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: radius));

        Paint shadow = new Paint()
          ..color = dark.withOpacity(0.8)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill
          ..strokeWidth = width;
        if (dots[j][i] == 1) {
          canvas.drawCircle(Offset(x.toDouble()+radius/10, y.toDouble()+radius/7),radius, shadow);
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, white);
        } else if (dots[j][i] == 2) {
          canvas.drawCircle(Offset(x.toDouble()+radius/10, y.toDouble()+radius/7), size.width / step / 2.2, shadow);
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()),radius, black);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Tile extends CustomPainter {
  Color dark;
  Color light;
  double width;
  bool isNull;
  List<List<int>> dots;
  Tile({
    this.width,
    this.dark,
    this.light,
    this.isNull,
    this.dots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint lineV = new Paint()
      ..color = light
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0), Colors.white, Colors.white.withOpacity(0)],
        stops: [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    Paint lineH = new Paint()
      ..color = light
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.white.withAlpha(0), Colors.white.withOpacity(0.1), Colors.white.withAlpha(0)],
        stops: [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    Paint edges = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2.5;

    Paint white = new Paint()
      ..color = light
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    Paint black = new Paint()
      ..color = dark
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    Paint blackStroke = new Paint()
      ..color = dark
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 8;

    Paint whiteStroke = new Paint()
      ..color = light
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2;

    boardDraw(canvas, size, lineV, lineH, edges, white, black, whiteStroke, blackStroke);
  }

  void boardDraw(Canvas canvas, Size size, Paint pV, Paint pH, Paint e, Paint white, Paint black, Paint whiteStroke, Paint blackStroke) {
    int count = dots.length;
    double step = count.toDouble() + 1.0;

    for (int i = 1; i <= count; i++) {
      canvas.drawLine(Offset(i * (size.width / step), 0), Offset(i * size.width / step, size.height), pV);

      for (int j = 1; j <= count; j++) {
        canvas.drawLine(Offset(0, j * (size.height / step)), Offset(size.width, j * size.height / step), pH);
      }
    }

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(size.width / step, size.height / step, size.width - size.width / step, size.height - size.height / step,
            topRight: Radius.circular(5), topLeft: Radius.circular(5), bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
        e);

    for (int i = 0; i < count; i++) {
      double x = (i.toDouble() + 1) * (size.width / step);
      for (int j = 0; j < count; j++) {
        double y = (j.toDouble() + 1) * (size.height / step);
        if (dots[j][i] == 1) {
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), size.width / step / 2.5, white);
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), size.width / step / 2.5, blackStroke);
        } else if (dots[j][i] == 2) {
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), size.width / step / 2.5, black);
          canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), size.width / step / 2.5, whiteStroke);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
