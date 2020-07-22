import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'board.dart';
import 'game.dart';

class Play extends StatefulWidget {
  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  static Color theme = new Color.fromARGB(255, 35, 35, 35);
  GoBoard _goBoard = GoBoard(theme, 10, 1);
  PageController _controller;
  PageController _listController;
  int currentPage;

  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.7, initialPage: 0);
    _listController=PageController(viewportFraction: 0.3, initialPage: 0);
    currentPage = 0;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 5,
              child: Container(
                child: PageView.builder(
                    itemCount: 10,
                    onPageChanged: (val) {
                      setState(() {
                        currentPage = val;
                        _listController.animateToPage(val, duration: Duration(seconds: 1), curve: Curves.ease);
                      });
                    },
                    controller: _controller,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, item) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Game()),
                          );
                        },
                        child: Center(
                            child: AnimatedContainer(
                              width: currentPage == item ? 350 : 300,
                              height: currentPage == item ? 350 : 300,
                              child: _goBoard,
                              duration: Duration(milliseconds: 300),
                            )),
                      );
                    }),
                color: new Color.fromARGB(255, 27, 26, 26),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color: new Color.fromARGB(255, 40, 39, 39),

                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: PageView.builder(
                itemCount: 10,
                onPageChanged: (val){_controller.animateToPage(val, duration: Duration(seconds: 1), curve: Curves.ease);},
                controller: _listController,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.all(25),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.flag,size: 30,color:currentPage!=index?Colors.grey[800]:Colors.grey),
                                  SizedBox(width: 10,),
                                  Text("Puzzle $index",style: TextStyle(color:currentPage!=index?Colors.grey[800]:Colors.grey,fontSize: 30),)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      decoration:   BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 5)
                            )
                          ],
                          color: new Color.fromARGB(255, 40, 40, 40)
                      ),
                  );
                },
              ),
            ),
        ]);
  }
}
