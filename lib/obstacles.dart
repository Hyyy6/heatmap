import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';


enum ObstacleAction {add, delete, calibrate}

class ObstacleEvent {
  ObstacleAction action;
  Key _key;
  double lossCoef;

  Key get key => _key;

  ObstacleEvent.add(){
    action = ObstacleAction.add;
  }

  ObstacleEvent.delete(this._key){
    action = ObstacleAction.delete;
  }

  ObstacleEvent.calibrate(this._key, this.lossCoef) {
    action = ObstacleAction.calibrate;
  }
}

class Obstacle {

  Key key;
  double signalLossCoeff = 0;
  Offset boxSize;
  List<Offset> verticesCoords = [];
  List<ObstacleVertex> vertices = [];
  Offset position;
  ObstacleLinePainter linePainter;

  List<Widget> getWidgets() {
    List<Widget> list = [];
    list.addAll(vertices);
    list.add(linePainter);
    return list;
  }

  Obstacle(this.key) {
    signalLossCoeff = 0;
    boxSize = Offset(40, 40);
    verticesCoords.addAll([Offset(50, 50), Offset(60, 50), Offset(60, 60), Offset(50, 60)]);
    vertices = [
      ObstacleVertex(0, key, callback, verticesCoords[0]),
      ObstacleVertex(1, key, callback, verticesCoords[1]),
      ObstacleVertex(2, key, callback, verticesCoords[2]),
      ObstacleVertex(3, key, callback, verticesCoords[3]),
    ];
    position = Offset(50, 50);
    linePainter = ObstacleLinePainter();
    //painter = ObstaclePainter();
  }

  void _calcPaintSize(){
    double minX, minY, maxX, maxY;
    minX = verticesCoords[0].dx;
    minY = verticesCoords[0].dy;
    maxX = verticesCoords[0].dx;
    maxY = verticesCoords[0].dy;
    for(int i = 0; i < 4; i++) {
      if(verticesCoords[i].dx < minX)
        minX = verticesCoords[i].dx;
      if(verticesCoords[i].dx < minX)
        minY = verticesCoords[i].dy;
      if(verticesCoords[i].dx > maxX)
        maxX = verticesCoords[i].dx;
      if(verticesCoords[i].dx > maxY)
        maxY = verticesCoords[i].dy;
    }
    linePainter.getCallback(Offset(minX, minY), Offset((maxX - minX), (maxY - minY)), verticesCoords);
  }


  void callback(Offset _position, int id) {
    verticesCoords[id] = _position;
    _calcPaintSize();
  }

}

class ObstacleVertex extends StatefulWidget {
  int id;
  Key myKey;
  Function(Offset, int) callback;
  final Offset initPos;
  ObstacleVertex(this.id, this.myKey, this.callback, this.initPos);

  @override
  State<StatefulWidget> createState() {
    return ObstacleVertexState();
  }
}

class ObstacleVertexState extends State<ObstacleVertex> {
  Offset position;
  double size;

  @override
  void initState() {
    position = widget.initPos;
    size = 16;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size/2,
      top: position.dy - size/2,
      child: GestureDetector(
        child: Icon(
          Icons.add_circle,
          size: size,
        ),
        onTap: (){
          BlocProvider.of<CPBloc>(context).dispatch(widget.myKey);
        },
        onPanUpdate: (details) {
          setState((){
            var prevPos = this.position;
            var renderBox = context.findRenderObject() as RenderBox;
            var localPos = renderBox.globalToLocal(details.globalPosition);
            this.position = localPos + prevPos;
            print(position);
          });
          widget.callback(position, widget.id);
        },
      )
    );
  }
}

class ObstacleLinePainter extends StatefulWidget {


  ObstacleLinePainterState state;

  void getCallback(Offset _position, Offset _size, List<Offset> coords) {
    return state.callback(_position, _size, coords);
  }

  @override
  State<StatefulWidget> createState() {
    state = ObstacleLinePainterState();
    return state;
  }
}

class ObstacleLinePainterState extends State<ObstacleLinePainter> {
  Offset position;
  Offset size;
  List<Offset> pointsCoords;

  @override
  void initState() {
    position = Offset(50, 50);
    size = Offset(10, 10);
    pointsCoords = [Offset(50, 50), Offset(60, 50), Offset(60, 60), Offset(50, 60)];
    super.initState();
  }

  void callback(Offset _position, Offset _size, List<Offset> coords) {
    setState(() {
      position = _position;
      size = _size;
      pointsCoords = coords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        foregroundPainter: MyPainter(pointsCoords),
    );
  }
}

class MyPainter extends CustomPainter {
  List<Offset> points;
  
  MyPainter(this.points);
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black;
    canvas..drawLine(points[0], points[1], paint)
      ..drawLine(points[1], points[2], paint)
      ..drawLine(points[2], points[3], paint)
      ..drawLine(points[3], points[0], paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}