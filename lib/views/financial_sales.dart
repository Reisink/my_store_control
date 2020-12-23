import 'package:flutter/material.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/widgets/grid_financial_sales.dart';

class FinancialSales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_shopping_cart),
            onPressed: () => Navigator.popAndPushNamed(
                context, AppRoutes.FORM_REGISTER_SALE),
          )
        ],
      ),
      body: GridFinancialSales(),
    );
  }
}
