import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateTimePicker extends StatelessWidget {
  final String labelText;
  final void Function(String value) onPressed;
  final void Function(String value) onValidateDate;
  final void Function(String value) onValidateTime;
  final TextEditingController dateController;
  final TextEditingController timeController;

  MyDateTimePicker({
    this.labelText,
    this.onPressed,
    @required this.dateController,
    @required this.timeController,
    this.onValidateDate,
    this.onValidateTime,
  });

  // final _dateController = TextEditingController(
  //     text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  // final _timeController = TextEditingController(
  //     text: DateFormat('HH:mm:00').format(DateTime.now()));
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  validator: onValidateDate,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    if (value != null) {
                      dateController.text =
                          DateFormat('dd/MM/yyyy').format(value);
                      onPressed(
                          '${dateController.text} ${timeController.text}');
                    }
                  }),
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: timeController,
                  keyboardType: TextInputType.number,
                  validator: onValidateTime,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () {
                    showTimePicker(
                      initialTime: TimeOfDay.now(),
                      context: context,
                    ).then((value) {
                      if (value != null) {
                        timeController.text = DateFormat('HH:mm').format(
                            DateTime(1, 1, 1, value.hour, value.minute));
                        onPressed(
                            '${dateController.text} ${timeController.text}');
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
