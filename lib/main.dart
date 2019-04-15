import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';
import 'package:heat_map_1/points.dart';
import 'package:heat_map_1/wifiDisplayer.dart';

//new branch
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
          Row(
            children: <Widget>[
              Column(children: <Widget>[
                FlatButton(
                    color: Colors.blueAccent,
                    child: Text('Add point'),
                    onPressed: () {
                      _pointsBloc.dispatch(PointEvent.add());
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
              Expanded(child: WifiDisplayer())
            ],
          ),
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
