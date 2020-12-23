import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_control/providers/payment.dart';
import 'package:store_control/providers/sales.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/widgets/customs/my_alert_dialog.dart';
import 'package:store_control/widgets/customs/my_month_bar.dart';

class GridFinancialSales extends StatefulWidget {
  @override
  _GridFinancialSalesState createState() => _GridFinancialSalesState();
}

class _GridFinancialSalesState extends State<GridFinancialSales> {
  Sales sales;
  bool isLoading;
  List<Map<String, Object>> salesByDay;
  final Map<String, Color> mapColor = {
    'month': Colors.teal[900],
    'day': Colors.teal[50],
    'sale': Colors.teal[100],
    'products': Colors.teal[900],
  };

  @override
  void initState() {
    super.initState();
    sales = Sales();

    load(DateTime.now());
  }

  Future<void> load(DateTime date) async {
    setState(() {
      isLoading = true;
    });

    await sales.load(
      DateFormat('yyyy-MM').format(date),
      Provider.of<SecurityApp>(context, listen: false),
    );

    salesByDay = List.from(
      StaticLists.daysOfMonth(date.month, date.year).reversed,
    ).map((e) => sales.salesByDayAcum(e)).toList();

    setState(() {
      isLoading = false;
    });
  }

  List<Widget> paymentsRows(List<Payment> payments) {
    return payments
        .map((e) => Row(
              children: [
                Expanded(child: Text(e.method)),
                SizedBox(
                  width: 60,
                  child: FittedBox(
                      child: Text('R\$ ${e.value.toStringAsFixed(2)}')),
                ),
              ],
            ))
        .toList();
  }

  style() {
    return TextStyle(
        color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 14);
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<SecurityApp>(context, listen: false).user;
    final _heightAdjust = _user.permission == 'owner' ? 190 : 150;
    return Container(
      child: Column(
        children: [
          if (_user.permission == 'owner')
            MyMonthBar(
              onPressed: (e) => load(e),
            ),
          Container(
            height: MediaQuery.of(context).size.height - _heightAdjust,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : sales.list.length == 0
                    ? Center(child: Text('Sem vendas no período'))
                    : ListView(
                        padding: EdgeInsets.all(8.0),
                        children: childrenHeader(),
                      ),
          ),
          Expanded(
            child: Container(
              child: Material(
                elevation: 12,
                color: mapColor['month'],
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '${this.sales.list.length} Venda(s)',
                        style: style(),
                      ),
                      Text(
                        '${this.sales.pieces()} Peça(s)',
                        style: style(),
                      ),
                      Text(
                        'R\$ ${this.sales.total()}',
                        style: style(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Material> childrenHeader() {
    return salesByDay
        .map(
          (e) => Material(
            color: mapColor['day'],
            elevation: 3.0,
            shape: Border.all(color: Colors.white, width: 0.7),
            child: ExpansionTile(
              leading: Text(
                DateFormat('dd/MM/yyyy\n(E)', 'pt_BR').format(e['day']),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              title: Text('R\$ ${e['total']}'),
              subtitle:
                  Text('${e['quantity']} Venda(s)    ${e['pieces']} Peça(s)'),
              children: childrenList(e['sales']),
            ),
          ),
        )
        .toList();
  }

  List<Material> childrenList(List<Sale> salesByDay) {
    return salesByDay.length == 0
        ? [
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 40,
                child: Center(child: Text('Sem vendas')),
              ),
            )
          ]
        : salesByDay
            .map(
              (e) => Material(
                elevation: 4.0,
                shape: Border.all(color: Colors.grey[100], width: 0.5),
                color: mapColor['sale'],
                child: ExpansionTile(
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(DateFormat('HH:mm:ss').format(e.soldAt)),
                      SizedBox(
                        width: 60,
                        child: FittedBox(child: Text('${e.pieces} peça(s)')),
                      ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(width: 30),
                          if (e.observation.isNotEmpty)
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: IconButton(
                                padding: EdgeInsets.all(0.0),
                                icon: Icon(Icons.info,
                                    color: Colors.teal[900], size: 26),
                                onPressed: () => MyAlertDialog.show(
                                  context,
                                  title: Text('Observação'),
                                  content: Text(e.observation),
                                ),
                              ),
                            ),
                          if (e.isDelivery)
                            SizedBox(
                              width: 30,
                              child: Icon(Icons.moped,
                                  color: Colors.teal[900], size: 26),
                            ),
                          if (e.isSaleBySite)
                            SizedBox(
                              width: 30,
                              child: Icon(Icons.public,
                                  color: Colors.teal[900], size: 22),
                            ),
                        ],
                      )),
                      SizedBox(
                        width: 60,
                        child: FittedBox(
                            child: Text(
                          'R\$ ${e.total.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    children: paymentsRows(e.payments),
                  ),
                  children: e.items
                      .map((i) => Material(
                            color: mapColor['products'],
                            textStyle: TextStyle(color: Colors.white),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 6),
                                      child: Text(
                                          '${i.category} ${i.type} ${i.size.isNotEmpty ? "(" + i.size + ")" : ''}'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      child: Text(
                                        '${i.quantity} x R\$ ${i.value.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ),
                                ]),
                          ))
                      .toList(),
                ),
              ),
            )
            .toList();
  }
}
