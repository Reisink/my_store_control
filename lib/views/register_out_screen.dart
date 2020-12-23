import 'package:flutter/material.dart';
import 'package:store_control/widgets/form_out_record.dart';

class RegisterOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saidas'),
      ),
      body: FormOutRecord(),
    );
  }
}
