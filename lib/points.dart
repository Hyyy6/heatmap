import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';

class Sides {
  double width;
  double height;

  Sides(this.width, this.height);
}

enum Action { add, delete, measure }

class PointEvent {
  Action action;
  Key _key;

  PointEvent.add() {
    action = Action.add;
  }

  PointEvent.delete(this._key) {
    action = Action.delete;
  }

  PointEvent.measure(this._key) {
    action = Action.measure;
  }

  Key get key => _key;
}

class Point extends StatefulWidget {
  Point({Key key}) : super(key: key);
  //Offset position = Offset(50.0, 50.0);
  int wifiLvl = 0;
  PointState state;

  @override
  State<StatefulWidget> createState() => state = PointState();
}

class PointState extends State<Point> {
  var position;
  var wifiLvl;
  var size;

  @override
  void initState() {
    position = Offset(50, 50);
    size = Offset(20, 20);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    wifiLvl = widget.wifiLvl;
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: WrappedGestureDetector(widget, size, position, wifiLvl, callbackStart, callbackUpdate, callbackEnd)
    );
  }

  void callbackStart(){
    setState(() {
      this.size = Offset(25, 25);
    });
  }

  Offset callbackUpdate(details) {
    setState((){
      var prevPos = this.position;
      var renderBox = context.findRenderObject() as RenderBox;
      var localPos = renderBox.globalToLocal(details.globalPosition);
      this.position = localPos + prevPos;
      print(position);
    });
    return position;
  }

  void callbackEnd(){
    print("New position $position");
    setState((){
      this.size = Offset(20, 20);
    });
  }
}

class WrappedGestureDetector extends StatefulWidget {

  Widget widget;
  Offset size;
  Offset position;
  int wifiLvl;
  Function() callbackStart;
  Function(DragUpdateDetails) callbackUpdate;
  Function() callbackEnd;


  WrappedGestureDetector(this.widget, this.size, this.position, this.wifiLvl, this.callbackStart, this.callbackUpdate, this.callbackEnd);

  @override
  _WrappedGestureDetectorState createState() => _WrappedGestureDetectorState();
}

class _WrappedGestureDetectorState extends State<WrappedGestureDetector> {
  Offset position;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            width: widget.size.dx,
            height: widget.size.dy,
            color: Colors.amber,
            child: Text('${widget.wifiLvl}')),
        onTap: () {
          BlocProvider.of<CPBloc>(context).dispatch(widget.widget.key);
          print(widget.position);
        },
        onPanStart: (details) {
          widget.callbackStart();
        },
        onPanUpdate: (details) {
          //print(localPos);
          setState((){
            position = widget.callbackUpdate(details);
          });

        },
        onPanEnd: (details) {
          widget.callbackEnd();
        }
    );
  }
}