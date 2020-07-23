import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GradientGraph extends StatefulWidget {
  @override
  _GradientGraphState createState() => _GradientGraphState();
}

class _GradientGraphState extends State<GradientGraph>  with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> animation;


 @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0
    );

    animation= new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
        parent: _controller,
        reverseCurve: Curves.decelerate,
        curve: Curves.decelerate
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    List<double> x = [0, 100, 200, 300, 400, 500]; //First values must be 0
    List<double> y = [0, 40, 0, 100, 50, 100];
    List<double> preY = [0, 0, 0, 0, 0,0];

    return Center(
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget child) {
          return  CustomPaint(
            foregroundPainter: Graph(x, List.generate(y.length, (int i)
            {
              return y[i]*animation.value+(1-animation.value)*preY[i];
            })),
            child: Container(height: 400,
            child: GestureDetector(
              onTap: (){_controller.value==0?_controller.forward():_controller.reverse();},
            ),),
          );
        }, animation:_controller,
      ),
    );
  }
}

@override
bool hitTest(Offset position) {
  print(position);
  return true;
}

class Graph extends CustomPainter {
  List<double> x;
  List<double> y;
  Color theme =new Color.fromARGB(64,194,211,255);

  Graph(List<double> x, List<double> y) {
    this.x = x;
    this.y = y;
  }

  @override
  void paint(Canvas canvas, Size size) {

    double xScale=size.width/(x.length-1);
    double yScale=1;

    Paint white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Paint fill = Paint()
      ..style = PaintingStyle.fill
    ..shader=LinearGradient(
      colors: [theme,Colors.transparent],
      stops: [0,1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
    ).createShader(Rect.fromLTRB(0, size.height / 2-yScale*y.reduce(max), size.width, size.height));

    Path lines = Path()..moveTo(0, size.height / 2-y[0]);
    Path gradient=Path()..moveTo(0, size.height)..lineTo(0, size.height / 2-y[0]);

    double last = 0;

    for (int i = 1; i < y.length; i++) {
      double m1 = last;
      double m2 = i < y.length - 1 ? (y[i + 1] - y[i - 1]) / (x[i + 1] - x[i - 1]) : 0;
      last = m2;
      gradient.cubicTo(xScale * i - xScale / 2, size.height / 2 - yScale*(y[i - 1] + xScale / 2 * m1), xScale * i - xScale / 2, size.height / 2 - yScale*(y[i] - xScale / 2 * m2), xScale * i, size.height /
          2 -
          yScale*y[i]);

    }

    gradient..lineTo(size.width, size.height)..close();

    for (int i = 1; i < y.length; i++) {
      double m1 = last;
      double m2 = i < y.length - 1 ? (y[i + 1] - y[i - 1]) / (x[i + 1] - x[i - 1]) : 0;
      last = m2;
      lines.cubicTo(xScale * i - xScale / 2, size.height / 2 - yScale*(y[i - 1] + xScale / 2 * m1), xScale * i - xScale / 2, size.height / 2 - yScale*(y[i] - xScale / 2 * m2), xScale * i, size.height /
          2 -
          yScale*y[i]);
      canvas.drawCircle(Offset(i * xScale, size.height / 2 - yScale*y[i]), 2, white);
    }

    canvas.drawPath(gradient, fill);
    canvas.drawPath(lines, white);


    /*for(int i=1;i<y.length-1;i++)// Slopes Visualisation
    {
      canvas.drawCircle(Offset(x[i], size.height/2-yScale*y[i]), 2, white..color=Colors.red);
      double m2=(y[i+1]-y[i-1])/(x[i+1]-x[i-1]);
      canvas.drawLine(Offset(x[i], size.height/2-yScale*y[i]), Offset(xScale*i-xScale/2,size.height/2-yScale*y[i]+xScale/2*m2), white..strokeWidth=1);
      canvas.drawLine(Offset(x[i], size.height/2-yScale*y[i]), Offset(xScale*i+xScale/2,size.height/2-yScale*y[i]-xScale/2*m2), white..strokeWidth=1);
    }*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  @override
  bool shouldRebuildSemantics(Graph oldDelegate) => true;
}
