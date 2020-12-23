import 'package:flutter/material.dart';

class MyAlertDialog {
  static void show(BuildContext context,
      {Widget title, Widget content, void Function(bool) onShow}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            // define os botões na base do dialogo
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (onShow != null) onShow(value);
    });
  }
}
