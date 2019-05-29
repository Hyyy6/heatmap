import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';
import 'package:heat_map_1/obstacles.dart';
import 'package:heat_map_1/points.dart';
import 'package:heat_map_1/wifiDisplayer.dart';
import 'package:heat_map_1/wifiLvlProvider.dart';
import 'package:extended_math/extended_math.dart';
import 'package:tuple/tuple.dart';

void hui() {
  double aEq, bEq, cEq;
  int n = 4;
  List<Tuple2<double, double>> xyPairArr = [];
  xyPairArr.add(Tuple2<double, double>(0, -23));
  xyPairArr.add(Tuple2<double, double>(1, -32));
  xyPairArr.add(Tuple2<double, double>(2, -38));
  xyPairArr.add(Tuple2<double, double>(3, -40));

  List<double> S = List(n);

  for (int i = 0; i < n; i++) {
    if (i == 0) {
      S[i] = 0;
      continue;
    } else {
      S[i] = S[i - 1] +
          1 /
              2 *
              (xyPairArr[i].item2 + xyPairArr[i - 1].item2) *
              (xyPairArr[i].item1 - xyPairArr[i - 1].item1);
    }
  }
  double sum_y_i_2 = 0,
      sum_x_y_i = 0,
      sum_y_i = 0,
      sum_x_i_2 = 0,
      sum_x_i = 0,
      sum_s_x_y_y = 0,
      sum_s_x_y_x = 0,
      sum_x_y = 0;
  for (int i = 0; i < n; i++) {
    sum_y_i_2 += xyPairArr[i].item2 * xyPairArr[i].item2;
    sum_x_y_i += xyPairArr[i].item1 * xyPairArr[i].item2;
    sum_y_i += xyPairArr[i].item2;
    sum_x_i_2 += xyPairArr[i].item1 * xyPairArr[i].item1;
    sum_x_i += xyPairArr[i].item1;
    sum_s_x_y_y +=
        -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2) * xyPairArr[i].item2;
    sum_s_x_y_x +=
        -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2) * xyPairArr[i].item1;
    sum_x_y += -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2);
  }
  Matrix amatx = SquareMatrix([
    [sum_y_i_2, sum_x_y_i, sum_y_i],
    [sum_x_y_i, sum_x_i_2, sum_x_i],
    [sum_y_i, sum_x_i, n]
  ]).inverse().matrixProduct(Matrix([
        [sum_s_x_y_y],
        [sum_s_x_y_x],
        [sum_x_y]
      ]));

  print(amatx.itemAt(1, 1));
  aEq = amatx.itemAt(1, 1).toDouble();

  double sum_x_i_a_4 = 0, sum_x_i_a_2 = 0, sum_y_x_i_a_2 = 0;
  for (int i = 0; i < n; i++) {
    sum_x_i_a_4 += 1 /
        ((xyPairArr[i].item1 + aEq) *
            (xyPairArr[i].item1 + aEq) *
            (xyPairArr[i].item1 + aEq) *
            (xyPairArr[i].item1 + aEq));
    sum_x_i_a_2 +=
        1 / ((xyPairArr[i].item1 + aEq) * (xyPairArr[i].item1 + aEq));
    sum_y_x_i_a_2 += xyPairArr[i].item2 /
        ((xyPairArr[i].item1 + aEq) * (xyPairArr[i].item1 + aEq));
  }
  Matrix cbmatx = SquareMatrix([
    [sum_x_i_a_4, -sum_x_i_a_2],
    [-sum_x_i_a_2, n]
  ]).inverse().matrixProduct(Matrix([
        [sum_y_x_i_a_2],
        [-sum_y_i]
      ]));

  cEq = cbmatx.itemAt(1, 1).toDouble();
  bEq = cbmatx.itemAt(2, 1).toDouble();
  print(aEq);
  print(cEq);
  print(bEq);
}

double aEq = double.nan, bEq = double.nan, cEq = double.nan;

void main() {
  //hui();
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
  final ObstacleBloc _obstacleBloc = ObstacleBloc();
  final ModelEngagedBloc _modelEngagedBloc = ModelEngagedBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(blocProviders: [
      BlocProvider<PointsBloc>(bloc: _pointsBloc),
      BlocProvider<CPBloc>(bloc: _cpBloc),
      BlocProvider<RatioBloc>(bloc: _ratioBloc),
      BlocProvider<ObstacleBloc>(bloc: _obstacleBloc),
      BlocProvider<ModelEngagedBloc>(bloc: _modelEngagedBloc)
    ], child: MaterialApp(title: 'WiFi Heatmap', home: SchemePage()));
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
  bool modelEngaged;
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  @override
  void initState() {
    modelEngaged = false;
    super.initState();
  }

  Future<int> _asyncInputWifiLvlDialog(BuildContext context) async {
    int wifiLvl = await WiFiLvlProvider.getWifiLevel();
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter wifi level'),
          content: new Row(
            children: <Widget>[
              new Expanded(
              child: FlatButton(
                  color: Colors.blueAccent,
                  child: Text('$wifiLvl'),
                  onPressed: () {
                  }),
          ),
              new Expanded(
                  child: new TextField(
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'WiFi Level'),
                    onChanged: (value) {
                      wifiLvl = int.parse(value);
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(wifiLvl);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RatioBloc _ratioBloc = BlocProvider.of<RatioBloc>(context);
    final PointsBloc _pointsBloc = BlocProvider.of<PointsBloc>(context);
    final CPBloc _cpBloc = BlocProvider.of<CPBloc>(context);
    final ObstacleBloc _obstacleBloc = BlocProvider.of<ObstacleBloc>(context);
    final ModelEngagedBloc _modelEngagedBloc =
        BlocProvider.of<ModelEngagedBloc>(context);

    return Scaffold(
        appBar: AppBar(title: Text('WiFi Heatmap')),
        body: Column(children: <Widget>[
          Row(children: <Widget>[
            FlatButton(
                child: Text('Cal. router'),
                color: Colors.blueAccent,
                onPressed: () {
                  setState(() {
                    calibrateRouter(_pointsBloc);
                  });
                }),
            FlatButton(
                child: Text('Cal. obstcls'),
                color: Colors.blueAccent,
                onPressed: () {
                  setState(() {
                    calibrateObstacles(_pointsBloc, _obstacleBloc);
                  });
                }),
            FlatButton(
                child: Text('Engage model'),
                color: Colors.blueAccent,
                onPressed: () {
                  _modelEngagedBloc.dispatch(true);
                })
          ]),
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
                child: Text('Set ratio'),
                color: Colors.blueAccent,
                onPressed: () {
                  _ratioBloc.dispatch(Sides(double.parse(widthController.text),
                      double.parse(heightController.text)));
                }),
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
                    child: Text('Measure WiFi'),
                    onPressed: () async {
                      var wifiLvl = await _asyncInputWifiLvlDialog(context);
                      _pointsBloc
                          .dispatch(PointEvent.measure(_cpBloc.currentState, wifiLvl));
                    }),
                FlatButton(
                    color: Colors.blueAccent,
                    child: Text('Del last point'),
                    onPressed: () {
                      _pointsBloc
                          .dispatch(PointEvent.delete(_cpBloc.currentState));
                    })
              ]),
              Column(children: <Widget>[
                FlatButton(
                    color: Colors.blueAccent,
                    child: Text('Add obstacle'),
                    onPressed: () {
                      _obstacleBloc.dispatch(ObstacleEvent.add());
                    }),
                FlatButton(
                    color: Colors.blueAccent,
                    child: Text('Delete obstacle'),
                    onPressed: () {
                      _obstacleBloc
                          .dispatch(ObstacleEvent.delete(_cpBloc.currentState));
                    }),
              ]),
              // :TODO fix this shit
              //Expanded(child: WifiDisplayer()),
              Expanded(child: WifiDisplayerInstant())
            ],
          ),
          MyMap()
        ]));
  }

  void calibrateRouter(PointsBloc pointsBloc) {
    List<Point> pointList = pointsBloc.currentState;
    String routerKey = pointsBloc.routerKey;
    Offset routerOffset = pointList
        .firstWhere((point) => point.key.toString() == routerKey)
        .state
        .position;
    double routerLvl = pointList
        .firstWhere((point) => point.key.toString() == routerKey)
        .wifiLvl
        .toDouble();
    int n = pointList.length;
    List<Tuple2<double, double>> xyPairArr = [];
    xyPairArr.add(Tuple2<double, double>(0, routerLvl));

    pointList.forEach((point) {
      if (point.key.toString() != routerKey) {
        xyPairArr.add(Tuple2<double, double>(
            LogicHelper.calcDistance(point.state.position, routerOffset),
            point.wifiLvl.toDouble()));
      }
    });
    xyPairArr.sort((a, b) => a.item1.compareTo(b.item1));
    print(xyPairArr);
    var norm = xyPairArr[1].item1;
    List<double> S = List(n);

    for (int i = 0; i < n; i++) {
      if (i == 0) {
        S[i] = 0;
        continue;
      } else {
        S[i] = S[i - 1] +
            1 /
                2 *
                (xyPairArr[i].item2 + xyPairArr[i - 1].item2) *
                (xyPairArr[i].item1 - xyPairArr[i - 1].item1);
      }
    }
    double sum_y_i_2 = 0,
        sum_x_y_i = 0,
        sum_y_i = 0,
        sum_x_i_2 = 0,
        sum_x_i = 0,
        sum_s_x_y_y = 0,
        sum_s_x_y_x = 0,
        sum_x_y = 0;
    for (int i = 0; i < n; i++) {
      sum_y_i_2 += xyPairArr[i].item2 * xyPairArr[i].item2;
      sum_x_y_i += xyPairArr[i].item1 * xyPairArr[i].item2;
      sum_y_i += xyPairArr[i].item2;
      sum_x_i_2 += xyPairArr[i].item1 * xyPairArr[i].item1;
      sum_x_i += xyPairArr[i].item1;
      sum_s_x_y_y += -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2) *
          xyPairArr[i].item2;
      sum_s_x_y_x += -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2) *
          xyPairArr[i].item1;
      sum_x_y += -(S[i] + xyPairArr[i].item1 * xyPairArr[i].item2);
    }
    Matrix amatx = SquareMatrix([
      [sum_y_i_2, sum_x_y_i, sum_y_i],
      [sum_x_y_i, sum_x_i_2, sum_x_i],
      [sum_y_i, sum_x_i, n]
    ]);
    try {
      amatx = (amatx as SquareMatrix).inverse();
    } catch (e) {}
    amatx = amatx.matrixProduct(Matrix([
      [sum_s_x_y_y],
      [sum_s_x_y_x],
      [sum_x_y]
    ]));

    print(amatx.itemAt(1, 1));
    aEq = amatx.itemAt(1, 1);

    double sum_x_i_a_4 = 0, sum_x_i_a_2 = 0, sum_y_x_i_a_2 = 0;
    for (int i = 0; i < n; i++) {
      sum_x_i_a_4 += 1 /
          ((xyPairArr[i].item1 + aEq) *
              (xyPairArr[i].item1 + aEq) *
              (xyPairArr[i].item1 + aEq) *
              (xyPairArr[i].item1 + aEq));
      sum_x_i_a_2 +=
          1 / ((xyPairArr[i].item1 + aEq) * (xyPairArr[i].item1 + aEq));
      sum_y_x_i_a_2 += xyPairArr[i].item2 /
          ((xyPairArr[i].item1 + aEq) * (xyPairArr[i].item1 + aEq));
    }
    Matrix cbmatx = SquareMatrix([
      [sum_x_i_a_4, -sum_x_i_a_2],
      [-sum_x_i_a_2, n]
    ]).inverse().matrixProduct(Matrix([
          [sum_y_x_i_a_2],
          [-sum_y_i]
        ]));

    cEq = cbmatx.itemAt(1, 1);
    bEq = cbmatx.itemAt(2, 1);
    print(cEq);
    print(bEq);
  }
}

void calibrateObstacles(PointsBloc pointsBloc, ObstacleBloc obstacleBloc) {
  List<Point> pointList = []..addAll(pointsBloc.currentState);
  List<Obstacle> obstList = []..addAll(obstacleBloc.currentState);
  String routerKey = pointsBloc.routerKey;
  Offset routerOffset = pointList
      .firstWhere((point) => point.key.toString() == routerKey)
      .state
      .position;
  double routerLvl = pointList
      .firstWhere((point) => point.key.toString() == routerKey)
      .wifiLvl
      .toDouble();
  pointList.removeWhere(
      (point) => point.key.toString() == routerKey); //list w\o router
  pointList.sort((Point a, Point b) => LogicHelper.calcDistance(
          a.state.position, routerOffset)
      .compareTo(LogicHelper.calcDistance(b.state.position,
          routerOffset))); //sorted with respect to the distance to the router
  for (Point point in pointList) {
    var lvl = LogicHelper.calcLvl(aEq, bEq, cEq, routerOffset, point.state.position);
    var tempObsts = LogicHelper.getIntercectedObsts(
        obstList, point.state.position, routerOffset);

    if(tempObsts.isEmpty)
      continue;

    tempObsts.forEach((obstacle) {
      if (obstacle.signalLossCoeff != 0) {
        lvl -= obstacle.signalLossCoeff;
      }
    });
    tempObsts.removeWhere((obstacle) => obstacle.signalLossCoeff != 0);

    if(tempObsts.isEmpty)
      continue;

    var sharedCoef = (lvl - point.wifiLvl) / tempObsts.length;
    tempObsts.forEach((obstacle) {
      obstacleBloc.dispatch(ObstacleEvent.calibrate(obstacle.key, sharedCoef));
    });
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
    final ObstacleBloc _obstacleBloc = BlocProvider.of<ObstacleBloc>(context);
    return BlocBuilder<PointEvent, List<Point>>(
        bloc: _pointsBloc,
        builder: (BuildContext context, pointList) {
          return BlocBuilder<ObstacleEvent, List<Obstacle>>(
              bloc: _obstacleBloc,
              builder: (BuildContext context, obstacleList) {
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
                                  Colors.indigo[800],
                                  Colors.indigo[700],
                                  Colors.indigo[600],
                                  Colors.indigo[400],
                                ],
                              ),
                            ),
                          )));
                      widgetList.addAll(pointList);
                      obstacleList.forEach((Obstacle obstacle) {
                        widgetList.addAll(obstacle.getWidgets());
                      });
                      return Stack(children: widgetList);
                    });
              });
        });
  }
}

class LogicHelper {
  static bool onSegment(Offset p, Offset q, Offset r) {
    if (q.dx <= max(p.dx, r.dx) &&
        q.dx >= min(p.dx, r.dx) &&
        q.dy <= max(p.dy, r.dy) &&
        q.dy >= min(p.dy, r.dy)) return true;

    return false;
  }

  static int orientation(Offset p, Offset q, Offset r) {
    double val = (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);

    if (val.abs() <= 0.001) return 0; // colinear

    return (val > 0) ? 1 : 2;
  }

  static bool doIntersect(Offset p1, Offset q1, Offset p2, Offset q2) {
    // Find the four orientations needed for general and
    // special cases
    int o1 = orientation(p1, q1, p2);
    int o2 = orientation(p1, q1, q2);
    int o3 = orientation(p2, q2, p1);
    int o4 = orientation(p2, q2, q1);

    // General case
    if (o1 != o2 && o3 != o4) return true;

    // Special Cases
    // p1, q1 and p2 are colinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;

    // p1, q1 and q2 are colinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;

    // p2, q2 and p1 are colinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;

    // p2, q2 and q1 are colinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false; // Doesn't fall in any of the above cases
  }

  static double calcDistance(Offset p1, Offset p2) {
    return sqrt(pow((p1.dx - p2.dx), 2) + pow((p1.dy - p2.dy), 2));
  }

  static double calcLvl(
      double a, double b, double k, Offset router, Offset point) {
    return k / (pow((calcDistance(router, point) + a), 2)) - b;
  }

  static List<Obstacle> getIntercectedObsts(
      List<Obstacle> obstList, Offset point, Offset router) {
    List<Obstacle> result = [];

    for (Obstacle obstacle in obstList) {
      for (int i = 0; i < 4; i++) {
        if (LogicHelper.doIntersect(point, router, obstacle.verticesCoords[i],
            obstacle.verticesCoords[(i + 1) % 4])) {
          result.add(obstacle);
          continue;
        }
      }
    }
    return result;
  }
}
