import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go/board.dart';
import 'package:go/game.dart';
import 'package:go/play.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static Color theme = new Color.fromARGB(255, 34, 34, 34);
  static Color accentTheme=new Color.fromARGB(255, 255, 255, 255);
  int selectedItem=0;
  PageController controller;
  int selected=-1;

  @override
  void initState() {
    // TODO: implement initState
    controller=PageController(initialPage: 2);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget tile= Center(child:AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:theme,
              border: Border.all(color: Colors.white30),
              borderRadius:BorderRadius.all(Radius.circular(20)),
            ),
            child: GestureDetector(
              child: Icon(Icons.play_arrow,color: Colors.white,size: 100,),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Game()),);
              },
            ),
          ),
        ),
    ),
    );

    Widget settings=ListView.builder(
        itemCount: 5,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 50),
          itemBuilder: (context,i)
          {
            return GestureDetector(
              onTap: (){setState(() {
                selected=selected==i?-1:i;
              });
              },
              child: Container(
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
                            Icon(Icons.settings,size: 30,color: selected!=i?Colors.grey[800]:Colors.grey,),
                            SizedBox(width: 10,),
                            Text("Settings",style: TextStyle(color: selected!=i?Colors.grey[800]:Colors.grey,fontSize: 30),)
                          ],
                        ),
                        AnimatedContainer(height: selected==i?250:0,duration: Duration(milliseconds: 300),curve: Curves.easeInOutQuad,width: double.maxFinite,)
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
                ),
            );
          }
      );

    return Scaffold(
      backgroundColor: theme,
      body: PageView(
        controller: controller,
        pageSnapping: true,
        physics:BouncingScrollPhysics(),
        children: <Widget>[
          settings,
          tile,
          Play(),
          tile,
          tile,

        ],
        onPageChanged: (val){setState(() {
          selectedItem=val;
        });},
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            activeIcon:Icon(Icons.settings,color: Colors.red,),
            title: Text('Settings',style: TextStyle(color: Colors.red),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            activeIcon:Icon(Icons.shopping_cart,color: Colors.deepOrange,),
            title: Text('Shop',style: TextStyle(color: Colors.deepOrange),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow,size: 30,),
            activeIcon:Icon(Icons.play_arrow,color: Colors.green,size:30),
            title: Text('Play',style: TextStyle(color: Colors.green),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            activeIcon:Icon(Icons.score,color: Colors.teal,),
            title: Text('Score',style: TextStyle(color: Colors.teal),),
            backgroundColor: Colors.red
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon:Icon(Icons.person,color: Colors.blue,),
            title: Text('Profile',style: TextStyle(color: Colors.blue),),
          ),
        ],
        currentIndex: selectedItem,
        backgroundColor: theme,
        iconSize: 30,
        unselectedItemColor: new Color.fromARGB(255, 102, 102, 102),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        onTap: (val){setState(() {
          selectedItem=val;
          controller.animateToPage(val, duration: Duration(milliseconds: 300), curve:Curves.decelerate );
        });},
      ),
    );
  }
}