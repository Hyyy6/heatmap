import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';
import 'main.dart';
import 'obstacles.dart';

class Sides {
  double width;
  double height;

  Sides(this.width, this.height);
}

enum PointsAction { add, delete, measure, force }

class PointEvent {
  PointsAction action;
  Key _key;
  double wifiLvl;

  PointEvent.add() {
    action = PointsAction.add;
  }

  PointEvent.delete(this._key) {
    action = PointsAction.delete;
  }

  PointEvent.measure(this._key, this.wifiLvl) {
    action = PointsAction.measure;
  }

  PointEvent.force() {
    action = PointsAction.force;
  }
  Key get key => _key;
}

class Point extends StatefulWidget {
  Point({Key key}) : super(key: key);
  final Color color = Colors.amber;
  double wifiLvl = 0.1;
  int modelWifiLvl = 0;
  PointState state;

  @override
  State<StatefulWidget> createState() => state = PointState();
}

class PointState extends State<Point> {
  Offset position;
  double wifiLvl;
  Offset size;

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
        left: position.dx - size.dx/2,
        top: position.dy - size.dy/2,
        child: WrappedGestureDetector(widget, size, position, wifiLvl, callbackStart, callbackUpdate, callbackEnd, widget.color, widget.key.toString())
    );
  }

  void callbackMeasure(double _wifiLvl) {
    setState(() {
      this.wifiLvl = _wifiLvl;
    });
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
  double wifiLvl;
  String myKey;
  Color color;
  Function() callbackStart;
  Function(DragUpdateDetails) callbackUpdate;
  Function() callbackEnd;


  WrappedGestureDetector(this.widget, this.size, this.position, this.wifiLvl, this.callbackStart, this.callbackUpdate, this.callbackEnd, this.color, this.myKey);

  @override
  _WrappedGestureDetectorState createState() => _WrappedGestureDetectorState();
}

class _WrappedGestureDetectorState extends State<WrappedGestureDetector> {
  Offset position;
  //Offset routerPos;
  int modelWifiLvl;

  @override
  Widget build(BuildContext context) {
    var pointsBloc = BlocProvider.of<PointsBloc>(context);
    var obstBloc = BlocProvider.of<ObstacleBloc>(context);
    var modelBloc = BlocProvider.of<ModelBloc>(context);

    return BlocBuilder<PointEvent, List<Point>>(
        bloc: pointsBloc,
        builder: (BuildContext context, pointList) {
          return BlocBuilder<ObstacleEvent, List<Obstacle>>(
            bloc: obstBloc,
            builder: (BuildContext context, obstList) {
              return BlocBuilder<ModelAction, ModelState> (
                bloc: modelBloc,
                builder: (BuildContext context, modelState) {
                  if(modelState.engageModel == false || widget.myKey == pointsBloc.routerKey)
                    return GestureDetector(
                        child: Container(
                            width: widget.size.dx,
                            height: widget.size.dy,
                            color: widget.color,
                            child: Text('${LogicHelper.toDbm(widget.wifiLvl)}')),
                        onTap: () {
                          BlocProvider.of<CPBloc>(context).dispatch(widget.widget.key);
                          print(widget.position);
                        },
                        onPanStart: (details) {
                          widget.callbackStart();
                        },
                        onPanUpdate: (details) {
                          //print(localPos);
                          setState(() {
                            position = widget.callbackUpdate(details);
                          });
                        },
                        onPanEnd: (details) {
                          widget.callbackEnd();
                          if(widget.myKey == pointsBloc.routerKey)
                            pointsBloc.dispatch(PointEvent.force());
                        }
                    );
                  else {
                    var routerPos = pointsBloc.currentState.firstWhere((point) =>
                    point.key.toString() == pointsBloc.routerKey
                    ).state.position;
                    var lvl = LogicHelper.calcLvl(aEq, bEq, cEq, routerPos, widget.position);
                    LogicHelper.getIntercectedObsts(obstList, widget.position, routerPos).forEach((obst) {
                      lvl -= obst.signalLossCoeff;
                    });
//                    setState((){
//                      modelWifiLvl = lvl.toInt();
//                    });
                    return Container(
                        width: widget.size.dx,
                        height: widget.size.dy,
                        color: widget.color,
                        child: Text('${LogicHelper.toDbm(lvl)}'));
                  }
                }
              );
            }
          );
        }
    );
  }
}

class Router extends Point {
  Router({Key key}) : super(key: key);
  Color color = Colors.pink;
}