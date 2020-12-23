import 'package:flutter/material.dart';
import 'package:store_control/widgets/form_inventory_site.dart';

class RegisterInventorySiteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventário Site'),
      ),
      body: FormInventorySite(),
    );
  }
}
