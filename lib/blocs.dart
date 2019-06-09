import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heat_map_1/obstacles.dart';
import 'package:heat_map_1/points.dart';
import 'package:heat_map_1/wifiLvlProvider.dart';

class PointsBloc extends Bloc<PointEvent, List<Point>> {
  String routerKey;

  @override
  List<Point> get initialState {
    var key = UniqueKey();
    routerKey = key.toString();
    return [Router(key: key)];
  }

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
      case PointsAction.add:
        newPointList.add(Point(key: UniqueKey()));
        print('points bloc $currentState');
        yield newPointList;
        break;
      case PointsAction.delete:
        for (Point point in newPointList) {
          if(point.key.toString() == routerKey)
            continue;
          if (point.key == event.key) {
            newPointList.remove(point);
            break;
          }
        }
        yield newPointList;
        break;
      case PointsAction.measure:
        Point tmpPoint = newPointList.firstWhere((point) => point.key == event.key);
        if (tmpPoint != null) {
          tmpPoint.wifiLvl = event.wifiLvl;
          tmpPoint.state.callbackMeasure(tmpPoint.wifiLvl);
        }
        yield newPointList;
        break;
      case PointsAction.force:
        yield newPointList;
        break;
    }
  }
}

class ObstacleBloc extends Bloc<ObstacleEvent, List<Obstacle>> {
  @override
  List<Obstacle> get initialState => [];

  void onTransition(Transition<ObstacleEvent, List<Obstacle>> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<List<Obstacle>> mapEventToState(ObstacleEvent event) async* {
    List<Obstacle> newObstacleList = [];
    newObstacleList.addAll(currentState);

    switch (event.action) {
      case ObstacleAction.add:
        newObstacleList.add(Obstacle(UniqueKey()));
        print('points bloc $currentState');
        yield newObstacleList;
        break;
      case ObstacleAction.delete:
        print(event.key.toString());
        for (Obstacle obstacle in newObstacleList) {
          print(obstacle.key.toString());
          if (obstacle.key == event.key) {
            newObstacleList.remove(obstacle);
            break;
          }
        }
        yield newObstacleList;
        break;
      case ObstacleAction.calibrate:
        for (Obstacle obstacle in newObstacleList) {
          print(obstacle.key.toString());
          if (obstacle.key == event.key) {
            obstacle.signalLossCoeff = event.lossCoef;
            yield newObstacleList;
            break;
          }
        }
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

enum ModelAction {engageModel, engageHeatmap}

class ModelState {
  bool engageModel;
  bool engageHeatmap;

  ModelState(this.engageModel, this.engageHeatmap);
}

class ModelBloc extends Bloc<ModelAction, ModelState> {
  @override
  ModelState get initialState => ModelState(false, false);

  @override
  Stream<ModelState> mapEventToState(ModelAction event) async* {
    var temp = this.currentState;
    switch (event) {
      case ModelAction.engageModel:
        yield ModelState(!temp.engageModel, temp.engageHeatmap);
        break;
      case ModelAction.engageHeatmap:
        yield ModelState(temp.engageModel, !temp.engageHeatmap);
        break;
    }
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