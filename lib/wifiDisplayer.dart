import 'dart:async';

import 'package:flutter/material.dart';
import 'wifiLvlProvider.dart';

class WifiDisplayer extends StatefulWidget {
  //WiFiLvlProvider wifiLvlProvider = WiFiLvlProvider();

  @override
  State<StatefulWidget> createState() => WifiDisplayerState();
}

class WifiDisplayerState extends State<WifiDisplayer> {
  int _wifiLvl;

  @override
  void initState() {
    super.initState();
    _fetchWifiData();
  }

  // :TODO fix this shit
  void _fetchWifiData() {
    int tmp = 0;
    int count = 0;

    Timer.periodic(Duration(microseconds: 100), (Timer T) async {
      tmp += await WiFiLvlProvider.getWifiLevel();
      count++;
      if(count == 10) {
        setState(() {
          _wifiLvl = (tmp/count).round();
        });
        count = 0;
        tmp = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('$_wifiLvl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }
}

class WifiDisplayerInstant extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WifiDisplayerInstantState();
}

class WifiDisplayerInstantState extends State<WifiDisplayerInstant> {
  int wifiLvl;

  void _fetchWifiData () {
    Timer.periodic(Duration(seconds: 1), (Timer T) async {
        var tmp = await WiFiLvlProvider.getWifiLevel();
        setState(() {
          wifiLvl = tmp;
        });
    });
  }

  @override
  void initState() {
    _fetchWifiData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Center(
        child: Text('$wifiLvl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }
}