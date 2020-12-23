import 'package:flutter/material.dart';

class MySnackBar {
  static void showSnack(BuildContext context, String type, String message) {
    var _style;
    var _icon;
    int _duration = 800;

    switch (type) {
      case 'OK':
        _style = TextStyle(color: Colors.green);
        _icon = Icon(Icons.check_circle, color: Colors.green);
        _duration = 1000;
        break;
      case 'NOK':
        _style = TextStyle(color: Colors.red);
        _icon = Icon(Icons.error, color: Colors.red);
        _duration = 2000;
        break;
      default:
        _icon = Icon(Icons.watch_later, color: Colors.amber);
        _style = TextStyle(color: Colors.amber);
        break;
    }

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          _icon,
          SizedBox(width: 10),
          Text(message, style: _style),
        ],
      ),
      duration: Duration(milliseconds: _duration),
    ));
  }
}
