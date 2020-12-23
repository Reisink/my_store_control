import 'package:flutter/material.dart';
import 'package:store_control/widgets/form_cashdesk.dart';

class RegisterCashDeskSreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fechar Caixa'),
      ),
      body: FormOpenCloseDesk(),
    );
  }
}
