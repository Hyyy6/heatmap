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
    const oneSec = const Duration(seconds: 1);
    _fetchWifiData();
    Timer.periodic(oneSec, (Timer t) {
      _fetchWifiData();
    });
  }

  Future<void> _fetchWifiData() async {
    const smallTimer = const Duration(milliseconds: 5);
    int tmp = 0;
    int count = 0;
    Timer(Duration(milliseconds: 900), () {
      Timer.periodic(smallTimer, (Timer T) async {
        tmp += await WiFiLvlProvider.getWifiLevel();

        if(count % 5 == 0) print(tmp/count);

        count++;
      });
      tmp = (tmp/count).round();
      if(_wifiLvl != tmp)
        setState(() {
          _wifiLvl = tmp;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('$_wifiLvl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }
}
