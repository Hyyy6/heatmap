import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heat_map_1/blocs.dart';
import 'package:heat_map_1/main.dart';
import 'package:heat_map_1/obstacles.dart';
import 'package:heat_map_1/points.dart';


class HeatMap extends CustomPainter {
  List<Point> pointList;
  List<Obstacle> obstList;
  String routerKey;

  HeatMap(this.pointList, this.obstList, this.routerKey);

  @override
  void paint(Canvas canvas, Size size) {
    Point router = pointList
        .firstWhere((point) => point.key.toString() == routerKey);
    print(router.state.position);
    Paint cell = Paint();
    for (double dx = 0; dx < size.width; dx += 10) {
      for (double dy = 0; dy < size.height; dy += 10) {
        cell.color = getColor(Offset(dx + 5, dy + 5), router, obstList);
        canvas.drawRect(
            Rect.fromCircle(center: Offset(dx + 5, dy + 5), radius: 5), cell);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  Color getColor(Offset pos, Point router, List<Obstacle> obstList) {
    double lvl = LogicHelper.calcLvl(aEq, bEq, cEq, router.state.position, pos);
    LogicHelper.getIntercectedObsts(obstList, pos, router.state.position).forEach((obst) {
      lvl -= obst.signalLossCoeff;
    });
    double maxLvl = router.wifiLvl.toDouble();
    double minLvl = -127;

    if (lvl < minLvl) lvl = minLvl;

    double ratio = 2 * (lvl - minLvl).toDouble() / (maxLvl - minLvl).toDouble();
    print(ratio.toInt());
    int b = max(0, (255*(1 - ratio)).toInt());
    int r = max(0, (255*(ratio - 1)).toInt());
    int g = 255 - b - r;
    return Color.fromRGBO(r, g, b, 1);
  }
}
