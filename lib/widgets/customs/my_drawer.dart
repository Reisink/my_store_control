import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/providers/security_app.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<SecurityApp>(context, listen: false).store;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).primaryColorDark,
                Theme.of(context).primaryColorLight,
              ]),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: 15,
                  child: CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.memory(
                          Provider.of<SecurityApp>(context).store.logo),
                      // child: Image(
                      //   image: AssetImage('assets/images/logo.jpg'),
                      // ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  child: Text(
                    Provider.of<SecurityApp>(context).store.name,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 10,
                    child: Text(
                      Provider.of<SecurityApp>(context).user.name,
                      style: TextStyle(color: Colors.white60),
                    ))
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.pie_chart),
                  title: Text('Consultar Fechamentos'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.GRID_FINANCIAL_CLOSE),
                ),
                ListTile(
                  leading: Icon(Icons.store),
                  title: Text('Consultar Vendas'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.GRID_FINANCIAL_SALES),
                ),
                // ListTile(
                //   leading: Icon(Icons.shopping_cart),
                //   title: Text('Registrar Venda Antigo'),
                //   onTap: () =>
                //       Navigator.of(context).pushNamed(AppRoutes.FORM_REGISTER),
                // ),
                ListTile(
                  leading: Icon(Icons.add_shopping_cart),
                  title: Text('Registrar Venda'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.FORM_REGISTER_SALE),
                ),
                ListTile(
                  leading: Icon(Icons.file_download),
                  title: Text('Registrar Saída'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.FORM_REGISTER_OUT),
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on),
                  title: Text('Fechar Caixa'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.FORM_REGISTER_CASHDESK),
                ),
                ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Inventário Site'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.FORM_REGISTER_INVENTORY_SITE),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sair'),
                  onTap: () => SystemNavigator.pop(),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).primaryColorLight,
            child: ListTile(
              title: Text('${store.address}, ${store.number}'),
              subtitle: Text('${store.district} - ${store.city}'),
            ),
          ),
        ],
      ),
    );
  }
}
