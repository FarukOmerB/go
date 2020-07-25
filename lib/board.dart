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

  void isBreathing(int x, int y, List<Piece> sp, int op) {
    if (!(x.isNegative || x >= this._board.size || y.isNegative || y >= this._board.size)) {
      int self = _board.dots[y][x];

      if (self != 0 && self != op) {
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
      }
    }
  }

  bool calcCapture(int op) {
    bool state = true;
    bool kill = false;

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
          kill = true;
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
    List<Piece> neighbours = [this];
    this.isBreathing(this.x, this.y, neighbours, opposite);
    bool breathing = false;
    neighbours.forEach((f) {
      if (f.isOpen()) {
        breathing = true;
      }
    });

    bool l = left.calcCapture(this.color);
    bool r = right.calcCapture(this.color);
    bool t = top.calcCapture(this.color);
    bool b = bottom.calcCapture(this.color);

    if (!(l || r || t || b) && !breathing) {
      _board.dots[y][x] = 0;
    }
  }
}

class GoBoard extends StatelessWidget {
  CustomPaint table;
  TableTheme tableTheme;
  int size;
  Board gameBoard;

  GoBoard(int size,TableTheme theme) {
    this.size = size;
    this.gameBoard = new Board(this.size);
    this.tableTheme=theme;
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
            child:tableTheme.style == 1 ? CustomPaint(painter: MaterialBoard(dots: gameBoard.dots, theme: tableTheme)) : CustomPaint(painter: LineBoard(theme: tableTheme,  dots: gameBoard
                .dots)),
          )),
        ),
      ],
    );
  }
}

class TableTheme {
  Color lineColor;
  Color insideColor;
  Color edgeColor;
  Color background;
  int style;

  TableTheme({this.insideColor, this.edgeColor, this.lineColor,this.background,this.style});
}

class MaterialBoard extends CustomPainter {
  TableTheme theme;
  double width = 0.4;
  bool isNull;
  List<List<int>> dots;
  double radius = 10;
  double padding = 9;
  MaterialBoard({this.isNull, this.dots, this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    boardDraw(
      canvas,
      size,
    );
  }

  void boardDraw(
    Canvas canvas,
    Size size,
  ) {
    int count = dots.length;
    double step = count.toDouble() + 1.0;

    Paint line = new Paint()
      ..color = theme.lineColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 3
      ..blendMode = BlendMode.srcOver;

    Paint edges = new Paint()
      ..color = theme.edgeColor
      ..style = PaintingStyle.fill;

    Paint inside = new Paint()
      ..color = theme.insideColor
      ..style = PaintingStyle.fill;

    Paint blackStone = new Paint()
      ..color = new Color.fromRGBO(36, 36, 36, 1)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    Paint whiteStone = new Paint()
      ..color = new Color.fromRGBO(196, 196, 196, 1)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    Paint shadow = new Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    RRect board = RRect.fromLTRBAndCorners(size.width / step - padding, size.height / step - padding, size.width - size.width / step + padding, size.height - size.height / step + padding,
        topRight: Radius.circular(radius), topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius), bottomLeft: Radius.circular(radius));

    canvas.drawShadow(Path()..addRRect(board), Colors.black.withOpacity(0.5), 7, true);

    canvas.drawRRect(board, edges);

    RRect internalBoard = RRect.fromLTRBAndCorners(size.width / step, size.height / step, size.width - size.width / step, size.height - size.height / step,
        topRight: Radius.circular(radius), topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius), bottomLeft: Radius.circular(radius));

    canvas.drawShadow(Path()..addRRect(internalBoard), Colors.black.withOpacity(0.4), 3, true);
    canvas.drawRRect(internalBoard, inside);

    /*canvas.drawPath(
        Path()..moveTo(size.width / step-10,size.height / step-10)..lineTo( (size.width - size.width / step+10), size.height / step-10)
          ..lineTo(size.width / step-10, (size.height - size.height / step+10)/2)..close(),
        new Paint()..color=Colors.white.withOpacity(0.05)..blendMode=BlendMode.overlay);*/

    Rect grad = Rect.fromLTRB(size.width / step - padding, size.height / step - padding, size.width - size.width / step + padding, size.height - size.height / step + padding);
    canvas.drawRRect(
        RRect.fromRectAndCorners(grad, topRight: Radius.circular(radius), topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius), bottomLeft: Radius.circular(radius)),
        new Paint()
          ..shader = RadialGradient(
            radius: 2,
            center: Alignment.topLeft,
            colors: [Colors.white.withAlpha(90), Colors.transparent],
            stops: [0, 1],
          ).createShader(grad)
          ..blendMode = BlendMode.softLight);

    for (int i = 2; i < count; i++) {
      canvas.drawLine(Offset(i * (size.width / step), size.width / step), Offset(i * size.width / step, size.height - size.width / step), line);

      for (int j = 2; j < count; j++) {
        canvas.drawLine(Offset(size.width / step, j * (size.height / step)), Offset(size.width - size.width / step, j * size.height / step), line);
      }
    }

    for (int i = 0; i < count; i++) {
      double x = (i.toDouble() + 1) * (size.width / step);
      for (int j = 0; j < count; j++) {
        if (dots[j][i] == 0) continue;

        double y = (j.toDouble() + 1) * (size.height / step);

        double radius = size.width / step / 2.2;

        canvas.drawShadow(
            new Path()..addOval(Rect.fromCircle(center: Offset(x.toDouble() + radius / 20, y.toDouble() + radius / 20), radius: size.width / step / 2.2)), Colors.black.withOpacity(0.8), 3, true);
        canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, dots[j][i] == 1 ? whiteStone : blackStone);

        canvas.drawCircle(
            Offset(x.toDouble(), y.toDouble()),
            radius,
            new Paint()
              ..shader = RadialGradient(colors: [Colors.white.withOpacity(1), Colors.transparent], center: Alignment.topLeft, radius: 2)
                  .createShader(Rect.fromCircle(center: Offset(x.toDouble(), y.toDouble()), radius: radius))
              ..blendMode = BlendMode.overlay);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LineBoard extends CustomPainter {
  TableTheme theme;
  double width=0.4;
  bool isNull;
  List<List<int>> dots;
  LineBoard({
    this.isNull,
    this.dots,
    this.theme
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint lineV = new Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.lineColor.withOpacity(0), theme.lineColor, theme.lineColor.withOpacity(0)],
        stops: [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    Paint lineH = new Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [theme.lineColor.withAlpha(0),theme.lineColor.withOpacity(0.1), theme.lineColor.withAlpha(0)],
        stops: [0, 0.5, 1],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    Paint edges = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2.5;

    Paint white = new Paint()
      ..color = theme.lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    Paint black = new Paint()
      ..color = theme.background
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;

    Paint blackStroke = new Paint()
      ..color = theme.background
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 8;

    Paint whiteStroke = new Paint()
      ..color = theme.lineColor
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
