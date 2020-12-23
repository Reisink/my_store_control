import 'package:flutter/material.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/widgets/customs/my_drawer.dart';
import 'package:store_control/widgets/form_sale_record.dart';

class RegisterSaleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vender'),
        actions: [
          IconButton(
              icon: Icon(Icons.power_settings_new),
              tooltip: 'Voltar para tela de segurança',
              onPressed: () =>
                  Navigator.of(context).popAndPushNamed(AppRoutes.HOME))
        ],
      ),
      drawer: MyDrawer(),
      body: Center(
        child: FormSaleRecord(),
      ),
    );
  }
}
