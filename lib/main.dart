import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/views/financial_close_screen.dart';
import 'package:store_control/views/financial_sales.dart';
import 'package:store_control/views/home_screen.dart';
import 'package:store_control/views/register_cashdesk_screen.dart';
import 'package:store_control/views/register_inventory_site_screen.dart';
import 'package:store_control/views/register_out_screen.dart';
import 'package:store_control/views/register_sale_screen.dart';

void main() {
  //localizationsDelegates e o supportedLocales resolveram o problema de idiomas
  // initializeDateFormatting('pt_BR', null).then((_) => runApp(MyApp()));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SecurityApp())],
      child: MaterialApp(
        title: 'Store Control',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('pt', 'BR')],
        theme: ThemeData(
          fontFamily: 'Montserrat',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Colors.blueGrey,
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.orange,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.teal, //  <-- light color
            textTheme:
                ButtonTextTheme.primary, //  <-- dark text for light background
          ),
        ),
        home: HomeScreen(),
        routes: {
          AppRoutes.FORM_REGISTER_SALE: (ctx) => RegisterSaleScreen(),
          AppRoutes.FORM_REGISTER_OUT: (ctx) => RegisterOutScreen(),
          AppRoutes.GRID_FINANCIAL_CLOSE: (ctx) => FinancialCloseScreen(),
          AppRoutes.GRID_FINANCIAL_SALES: (ctx) => FinancialSales(),
          AppRoutes.FORM_REGISTER_CASHDESK: (ctx) => RegisterCashDeskSreen(),
          AppRoutes.FORM_REGISTER_INVENTORY_SITE: (ctx) =>
              RegisterInventorySiteScreen(),
        },
      ),
    );
  }
}
