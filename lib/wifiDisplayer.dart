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
    _fetchWifiData(10);
    Timer.periodic(oneSec, (Timer t) {
      _fetchWifiData(10);
    });
  }

  // :TODO fix this shit
  Future<void> _fetchWifiData(int times) async {
    const millisec = const Duration(milliseconds: 1);

    int tmp = 0;
    int count = 0;

    Timer.periodic(millisec * times, (Timer T) async {
      if (count * times == 900) {
        if (_wifiLvl != tmp) {
          tmp = (tmp / count).round();
          setState(() {
            _wifiLvl = tmp;
          });
        }
        T.cancel();
      }

      tmp += await WiFiLvlProvider.getWifiLevel();

      //if(count % 5 == 0) print(tmp/count);

      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('$_wifiLvl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }
}
