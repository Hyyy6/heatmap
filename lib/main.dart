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

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
        blocProviders: [BlocProvider<RatioBloc>(bloc: _ratioBloc)],
        child: MaterialApp(title: 'Govno', home: SchemePage()));
  }

  @override
  void dispose() {
    _ratioBloc.dispose();
    super.dispose();
  }
}

class _AppState_ex extends State<App> {
  final CounterBloc _counterBloc = CounterBloc();
  final ThemeBloc _themeBloc = ThemeBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<CounterBloc>(bloc: _counterBloc),
        BlocProvider<ThemeBloc>(bloc: _themeBloc)
      ],
      child: BlocBuilder(
        bloc: _themeBloc,
        builder: (_, ThemeData theme) {
          return MaterialApp(
            title: 'Flutter Demo',
            home: CounterPage(),
            theme: theme,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _counterBloc.dispose();
    _themeBloc.dispose();
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
          BlocBuilder<Sides, double>(
            bloc: _ratioBloc,
            builder: (BuildContext context, double ratio) {
              return Center(
                child: AspectRatio(
                    aspectRatio: ratio,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle, color: Colors.black12),
                    )),
              );
            },
          )
        ]));
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);
    final ThemeBloc _themeBloc = BlocProvider.of<ThemeBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.update),
              onPressed: () {
                _themeBloc.dispatch(ThemeEvent.toggle);
              },
            ),
          ),
        ],
      ),
    );
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

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  @override
  ThemeData get initialState => ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield currentState == ThemeData.dark()
            ? ThemeData.light()
            : ThemeData.dark();
        break;
    }
  }
}
