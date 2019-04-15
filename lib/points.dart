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
  Offset position = Offset(50.0, 50.0);
  int wifiLvl = 0;
  PointState state;
  @override
  State<StatefulWidget> createState() => state = PointState();
}

class PointState extends State<Point> {
  var position;
  var wifiLvl;

  @override
  Widget build(BuildContext context) {
    position = widget.position;
    wifiLvl = widget.wifiLvl;
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
            child: Container(
                width: 20,
                height: 20,
                color: Colors.amber,
                child: Text('$wifiLvl')),
            onDragStarted: () {
              BlocProvider.of<CPBloc>(context).dispatch(widget.key);
              print(position);
            },
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                print(position);
                print(offset);
                position = offset - Offset(0, 272);
                if (position.dx < 0) position = Offset(0, position.dy);
                if (position.dy < 0) position = Offset(position.dx, 0);
                widget.position = position;
                print(position);
              });
            },
            feedback: Container(width: 10, height: 10, color: Colors.red)));
  }
}


