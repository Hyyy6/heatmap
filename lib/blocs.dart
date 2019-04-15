import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heat_map_1/points.dart';
import 'package:heat_map_1/wifiLvlProvider.dart';

class PointsBloc extends Bloc<PointEvent, List<Point>> {
  @override
  List<Point> get initialState => [];

  @override
  void onTransition(Transition<PointEvent, List<Point>> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<List<Point>> mapEventToState(PointEvent event) async* {
    List<Point> newPointList = [];
    newPointList.addAll(currentState);

    switch (event.action) {
      case Action.add:
        newPointList.add(Point(key: UniqueKey()));
        print('points bloc $currentState');
        yield newPointList;
        break;
      case Action.delete:

        for (Point point in newPointList) {
          if (point.key == event.key) {
            newPointList.remove(point);
            break;
          }
        }
        yield newPointList;
        break;
      case Action.measure:
        Point tmpPoint = newPointList.firstWhere((point) => point.key == event.key);
        if (tmpPoint != null) {
          tmpPoint.wifiLvl = await WiFiLvlProvider.getWifiLevel();
        }
        yield newPointList;
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

class RatioBloc extends Bloc<Sides, double> {
  @override
  double get initialState => 16 / 9;

  @override
  Stream<double> mapEventToState(Sides event) async* {
    print(event.width / event.height);
    yield event.width / event.height;
  }
}


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