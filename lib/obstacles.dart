import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heat_map_1/blocs.dart';


enum ObstacleAction {add, delete}

class ObstacleEvent {
  ObstacleAction action;
  Key _key;

  Key get key => _key;

  ObstacleEvent.add(){
    action = ObstacleAction.add;
  }

  ObstacleEvent.delete(this._key){
    action = ObstacleAction.delete;
  }
}

class Obstacle extends StatefulWidget {
  Obstacle({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ObstacleState();
  }
}

class ObstacleState extends State<Obstacle> {
  double signalLossCoeff;
  Offset boxSize;
  List<Offset> verticesCoords;
  List<ObstacleVertex> vertices;
  Offset position;

  @override
  void initState() {
    signalLossCoeff = 0;
    boxSize = Offset(40, 40);
    verticesCoords.addAll([Offset(50, 50), Offset(60, 50), Offset(60, 60), Offset(50, 60)]);
    vertices = [
      ObstacleVertex(0, widget.key, callback, verticesCoords[0]),
      ObstacleVertex(1, widget.key, callback, verticesCoords[1]),
      ObstacleVertex(2, widget.key, callback, verticesCoords[2]),
      ObstacleVertex(3, widget.key, callback, verticesCoords[3]),
    ];
    position = Offset(50, 50);
    super.initState();
  }

  Offset _calcPaintSize(){

  }
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.addAll(vertices);
    widgetList.add(CustomPaint(
      chi
    ));
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Stack(
        children: widgetList

      ));
  }

  void callback(Offset _position, int id) {
    setState(() {
      if (id == 0)
        position = _position;
      verticesCoords[id] = _position;
    });
  }

}

class ObstacleVertex extends StatefulWidget {
  int id;
  Key key;
  Function(Offset, int) callback;
  final Offset initPos;
  ObstacleVertex(this.id, this.key, this.callback, this.initPos);

  @override
  State<StatefulWidget> createState() {
    return ObstacleVertexState();
  }
}

class ObstacleVertexState extends State<ObstacleVertex> {
  Offset position;

  @override
  void initState() {
    position = widget.initPos;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        child: Icon(
          Icons.add_circle,
          size: 10,
        ),
        onTap: (){
          BlocProvider.of<CPBloc>(context).dispatch(widget.key);
        },
        onPanUpdate: (details) {
          setState((){
            var prevPos = this.position;
            var renderBox = context.findRenderObject() as RenderBox;
            var localPos = renderBox.globalToLocal(details.globalPosition);
            this.position = localPos + prevPos;
            print(position);
          });
          widget.callback(position);
        },
      )
    );
  }
}

class ObstaclePainter extends CustomPainter {

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    canvas.
  }
}