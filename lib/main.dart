import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
    super.onError(error, stacktrace);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final RatioBloc _ratioBloc = RatioBloc();
  final PointsBloc _pointsBloc = PointsBloc();
  final CPBloc _cpBloc = CPBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(blocProviders: [
      BlocProvider<PointsBloc>(bloc: _pointsBloc),
      BlocProvider<CPBloc>(bloc: _cpBloc),
      BlocProvider<RatioBloc>(bloc: _ratioBloc),
    ], child: MaterialApp(title: 'Govno', home: SchemePage()));
  }

  @override
  void dispose() {
    _ratioBloc.dispose();
    _pointsBloc.dispose();
    _cpBloc.dispose();
    super.dispose();
  }
}

class SchemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SchemePageState();
}

class SchemePageState extends State<SchemePage> {
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final RatioBloc _ratioBloc = BlocProvider.of<RatioBloc>(context);
    final PointsBloc _pointsBloc = BlocProvider.of<PointsBloc>(context);
    final CPBloc _cpBloc = BlocProvider.of<CPBloc>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Pizdec govno')),
        body: Column(children: <Widget>[
          Row(children: <Widget>[
            Flexible(
              child: TextField(
                controller: widthController,
              ),
            ),
            Flexible(
              child: TextField(
                controller: heightController,
              ),
            ),
            FlatButton(
                child: Text('Set the ratio'),
                color: Colors.blueAccent,
                onPressed: () {
                  _ratioBloc.dispatch(Sides(double.parse(widthController.text),
                      double.parse(heightController.text)));
                })
          ]),
          Column(children: <Widget>[
            FlatButton(
                color: Colors.blueAccent,
                child: Text('Add point'),
                onPressed: () {
                  _pointsBloc.dispatch(PointEvent(Action.add));
                }),
            FlatButton(
                color: Colors.blueAccent,
                child: Text('Measure WiFi level for currently dragged point'),
                onPressed: () {
                  _pointsBloc
                      .dispatch(PointEvent.measure(_cpBloc.currentState));
                }),
            FlatButton(
                color: Colors.blueAccent,
                child: Text('Delete currently dragged point'),
                onPressed: () {
                  _pointsBloc.dispatch(PointEvent.delete(_cpBloc.currentState));
                })
          ]),
          MyMap()
        ]));
  }
}

class MyMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyMapState();
  }
}

class MyMapState extends State<MyMap> {
  @override
  Widget build(BuildContext context) {
    final PointsBloc _pointsBloc = BlocProvider.of<PointsBloc>(context);
    final RatioBloc _ratioBloc = BlocProvider.of<RatioBloc>(context);
    return BlocBuilder<PointEvent, List<Point>>(
        bloc: _pointsBloc,
        builder: (BuildContext context, pointList) {
          return BlocBuilder<Sides, double>(
              bloc: _ratioBloc,
              builder: (BuildContext context, ratio) {
                print(pointList);
                List<Widget> widgetList = [];
                widgetList.add(AspectRatio(
                    aspectRatio: ratio,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        gradient: LinearGradient(
                          // Where the linear gradient begins and ends
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          // Add one stop for each color. Stops should increase from 0 to 1
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            // Colors are easy thanks to Flutter's Colors class.
                            Colors.indigo[800],
                            Colors.indigo[700],
                            Colors.indigo[600],
                            Colors.indigo[400],
                          ],
                        ),
                      ),
                    )));
                widgetList.addAll(pointList);
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Stack(children: widgetList, key: GlobalKey()),
                );
              });
        });
  }
}

class Sides {
  double width;
  double height;

  Sides(this.width, this.height);
}

class RatioBloc extends Bloc<Sides, double> {
  @override
  double get initialState => 16 / 9;

  @override
  Stream<double> mapEventToState(Sides event) async* {
    print(event.width / event.height);
    yield event.width / event.height;
  }
}

enum Action { add, delete, measure }

class PointEvent {
  Action action;
  Key _key;

  PointEvent(this.action);
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

//  @override
//  void initState() {
//    position = Offset(50.0, 50.0);
//    wifiLvl = 0;
//    super.initState();
//  }

  @override
  Widget build(BuildContext context) {
    position = widget.position;
    wifiLvl = widget.wifiLvl;
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
            child: Container(
                width: 10,
                height: 10,
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

class PointsBloc extends Bloc<PointEvent, List<Point>> {
  //List<Point> points = [];

  @override
  List<Point> get initialState => [];

  @override
  void onTransition(Transition<PointEvent, List<Point>> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<List<Point>> mapEventToState(PointEvent event) async* {
    switch (event.action) {
      case Action.add:
        this.currentState.add(Point(key: UniqueKey()));
        //points.add(Point(key: UniqueKey()));
        print('points bloc $currentState');
        yield this.currentState;
        break;
      case Action.delete:
        for (Point point in this.currentState) {
          if (point.key == event.key) this.currentState.remove(point);
          break;
        }
        yield this.currentState;
        break;
      case Action.measure:
        // TODO: measure wifi lvl
        break;
    }
  }
}

class CPBloc extends Bloc<Key, Key> {
  @override
  Key get initialState => Key('init');

  @override
  Stream<Key> mapEventToState(Key event) async* {
    print(event);
    yield event;
  }
}
