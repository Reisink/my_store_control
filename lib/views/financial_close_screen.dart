import 'package:flutter/material.dart';
import 'package:store_control/widgets/grid_financial_close.dart';

class FinancialCloseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fechamento'),
      ),
      body: Center(
        child: GridFinancialClose(),
      ),
    );
  }
}
