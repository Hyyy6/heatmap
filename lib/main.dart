import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
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
      BlocProvider<RatioBloc>(bloc: _ratioBloc),
      BlocProvider<PointsBloc>(bloc: _pointsBloc),
      BlocProvider<CPBloc>(bloc: _cpBloc)
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

class Sides {
  double width;
  double height;

  Sides(this.width, this.height);
}

class RatioBloc extends Bloc<Sides, double> {
  @override
  double get initialState => 1;

  @override
  Stream<double> mapEventToState(Sides event) async* {
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

  //PointState state;
  @override
  State<StatefulWidget> createState() => PointState();
}

class PointState extends State<Point> {
  Offset position = Offset(50.0, 50.0);
  int wifiLvl = 0;

  @override
  Widget build(BuildContext context) {
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
            },
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                position = offset;
              });
            },
            feedback: Container(width: 10, height: 10, color: Colors.red)));
  }
}

class PointsBloc extends Bloc<PointEvent, List<Point>> {
  List<Point> points;

  @override
  List<Point> get initialState => points = [];

  @override
  Stream<List<Point>> mapEventToState(PointEvent event) async* {
    switch (event.action) {
      case Action.add:
        points.add(Point(key: UniqueKey()));
        yield points;
        break;
      case Action.delete:
        for (Point point in points) {
          if (point.key == event.key) points.remove(point);
          break;
        }
        yield points;
        break;
      case Action.measure:
        // TODO: measure wifi lvl
        break;
    }
  }
}

class CPBloc extends Bloc<Key, Key> {
  @override
  Key get initialState => null;

  @override
  Stream<Key> mapEventToState(Key event) async* {
    yield event;
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
    PointsBloc _pointsBloc = BlocProvider.of<PointsBloc>(context);
    RatioBloc _ratioBloc = BlocProvider.of<RatioBloc>(context);
    return BlocBuilder<PointEvent, List<Point>>(
        bloc: _pointsBloc,
        builder: (BuildContext context, List<Point> pointsList) {
          return Center(
              child: BlocBuilder<PointEvent, List<Point>>(
                  bloc: _pointsBloc,
                  builder: (BuildContext context, List<Point> pointList) {
                    return Stack(
                        children: <Widget>[
                              AspectRatio(
                                  aspectRatio: _ratioBloc.currentState,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.black12),
                                  )),
                            ] +
                            pointsList);
                  }));
        });
  }
}
