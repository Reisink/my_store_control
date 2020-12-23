import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyMonthBar extends StatelessWidget {
  final void Function(DateTime value) onPressed;
  MyMonthBar({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final _listMonths = List.generate(
          (DateTime.now().difference(DateTime(2020, 1, 1)).inDays + 2),
          (i) => DateTime(2020, 1, i))
      .where((element) => element.day == 1)
      .toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
          children: _listMonths
              .map((e) => Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: RaisedButton(
                      onPressed: () => this.onPressed(e),
                      child: Text(
                        DateFormat('MMM yy', 'pt_BR').format(e),
                      ),
                    ),
                  ))
              .toList()),
    );
  }
}
