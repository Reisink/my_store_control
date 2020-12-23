import 'package:flutter/material.dart';

class MySelectToggleButtons extends StatefulWidget {
  final List<String> listString;
  final void Function(String value) onPressed;

  MySelectToggleButtons({
    Key key,
    @required this.listString,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _MySelectToggleButtonsState createState() => _MySelectToggleButtonsState();
}

class _MySelectToggleButtonsState extends State<MySelectToggleButtons> {
  TextEditingController textEditingController;
  ScrollController scrollController;
  List<String> listString;
  List<bool> listBool;
  void Function(String value) onPressed;

  @override
  void initState() {
    super.initState();
    fillData();
  }

  // Util apenas para debug para não precisar reconstruir o widget quando alterar uma lista
  // @override
  // void didUpdateWidget(MySelectToggleButtons oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   fillData();
  // }

  void fillData() {
    listString = widget.listString;
    listBool = List.generate(listString.length, (index) => false);
    onPressed = widget.onPressed;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ToggleButtons(
        borderWidth: 2,
        borderRadius: BorderRadius.circular(8.0),
        textStyle: TextStyle(fontWeight: FontWeight.w400),
        fillColor: Color.fromRGBO(0, 128, 128, 0.30),
        splashColor: Colors.black45,
        children: listString
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(e),
              ),
            )
            .toList(),
        onPressed: (int index) {
          setState(() {
            onPressed(listString[index]);
            for (int buttonIndex = 0;
                buttonIndex < listBool.length;
                buttonIndex++) {
              if (buttonIndex == index) {
                listBool[buttonIndex] = true;
              } else {
                listBool[buttonIndex] = false;
              }
            }
          });
        },
        isSelected: listBool,
      ),
    );
  }
}
