import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_control/providers/financial_close.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/widgets/customs/my_month_bar.dart';

class GridFinancialClose extends StatefulWidget {
  @override
  _GridFinancialCloseState createState() => _GridFinancialCloseState();
}

class _GridFinancialCloseState extends State<GridFinancialClose> {
  final CarouselController _controller = CarouselController();
  List<DateTime> _listDayOfMonth;
  List<dynamic> _fillMonth;
  Future<String> futureString;
  var _indexPage = 0;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    futureString = loadMaps(DateTime.now().year, DateTime.now().month);
  }

  Future<String> loadMaps(int _year, int _month) async {
    final _startDate = DateTime(_year, _month, 1);
    final _periodoFormat = DateFormat('yyyy-MM').format(_startDate);
    final _sales = await FinancialClose.sales(context, _periodoFormat);
    final _cashOuts = await FinancialClose.cashOuts(context, _periodoFormat);
    final _cashDesks = await FinancialClose.cashDesks(context, _periodoFormat);
    final _user = Provider.of<SecurityApp>(context, listen: false).user;

    _listDayOfMonth =
        StaticLists.daysOfMonth(_startDate.month, _startDate.year);

    _fillMonth = _listDayOfMonth.map((e) {
      final _aux =
          _sales.where((element) => element.soldAt.day == e.day).toList();

      final _out =
          _cashOuts.where((element) => element.cashOutAt.day == e.day).toList();

      final _cashdesk = _cashDesks
          .where((element) => element.cashDeskAt.day == e.day)
          .toList();

      return {
        'closedDay': e,
        'mapOverall': _user.permission == 'owner'
            ? FinancialClose.overall(_sales, _cashOuts)
            : List<Map<String, String>>(),
        'mapIn': FinancialClose.entradas(_aux),
        'mapOut': FinancialClose.saidas(_out),
        'mapStorage': FinancialClose.estoque(_aux),
        'mapCashdesk': FinancialClose.fechamento(_cashdesk),
      };
    }).toList();

    setState(() {
      _indexPage = _listDayOfMonth.length - 1;
    });

    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<SecurityApp>(context, listen: false).user;
    final _heightAdjust = _user.permission == 'owner' ? 216 : 190;
    return Column(
      children: [
        _user.permission == 'owner'
            ? MyMonthBar(
                onPressed: (e) => setState(() {
                  _isloading = true;
                  loadMaps(e.year, e.month).then((value) {
                    _isloading = false;
                  });
                }),
              )
            : SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height - _heightAdjust,
          child: FutureBuilder(
              future: futureString,
              builder: (ctx, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text(snapshot.error.toString()));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                else
                  return _isloading
                      ? Center(child: CircularProgressIndicator())
                      : CarouselSlider(
                          items: _fillMonth
                              .map((e) => RefreshIndicator(
                                    onRefresh: () => loadMaps(
                                        (e['closedDay'] as DateTime).year,
                                        (e['closedDay'] as DateTime).month),
                                    child: CardInformation(
                                      closedDay: e['closedDay'],
                                      mapIn: e['mapIn'],
                                      mapOut: e['mapOut'],
                                      mapStorage: e['mapStorage'],
                                      mapOverall: e['mapOverall'],
                                      mapCashdesk: e['mapCashdesk'],
                                    ),
                                  ))
                              .toList(),
                          carouselController: _controller,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height - 216,
                            initialPage: _listDayOfMonth.length - 1,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) => setState(() {
                              _indexPage = index;
                            }),
                            autoPlay: false,
                          ),
                        );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: CircleAvatar(
                  radius: 24,
                  child: Text('<<'),
                ),
                onTap: () => _controller.animateToPage(0),
              ),
            ),
            InkWell(
              child: CircleAvatar(
                child: Text('<'),
              ),
              onTap: () => _controller.previousPage(),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: CircleAvatar(
                child: Text('${_indexPage + 1}'),
              ),
            ),
            InkWell(
              child: CircleAvatar(
                child: Text('>'),
              ),
              onTap: () => _controller.nextPage(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: CircleAvatar(
                  radius: 24,
                  child: Text('>>'),
                ),
                onTap: () =>
                    _controller.animateToPage(_listDayOfMonth.length - 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CardInformation extends StatelessWidget {
  const CardInformation({
    Key key,
    @required this.closedDay,
    @required this.mapIn,
    @required this.mapOut,
    @required this.mapStorage,
    @required this.mapOverall,
    @required this.mapCashdesk,
  }) : super(key: key);

  final DateTime closedDay;
  final List<Map<String, String>> mapIn;
  final List<Map<String, String>> mapOut;
  final List<Map<String, String>> mapStorage;
  final List<Map<String, String>> mapOverall;
  final List<Map<String, String>> mapCashdesk;

  @override
  Widget build(BuildContext context) {
    var styleLabel = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Card(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          // width: MediaQuery.of(context).size.width - 8.0,
          // height: MediaQuery.of(context).size.height - 64.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.bottomLeft,
              begin: Alignment.topRight,
              colors: [
                Colors.black12,
                Colors.black26,
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                DateFormat('dd/MM/yyyy (E)', 'pt_BR').format(closedDay),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Column(
                children: [
                  Text('Gestão/Controle', style: styleLabel),
                  SizedBox(height: 10),
                  Column(
                    children: mapCashdesk
                        .map((e) => LabelAndValueWidget(mapTitleValue: e))
                        .toList(),
                  ),
                  Divider(thickness: 2, height: 25),
                  Text('Gestão de estoque', style: styleLabel),
                  SizedBox(height: 10),
                  Column(
                    children: mapStorage
                        .map((e) => LabelAndValueWidget(mapTitleValue: e))
                        .toList(),
                  ),
                  Divider(thickness: 2, height: 25),
                  Text('Entradas', style: styleLabel),
                  SizedBox(height: 10),
                  Column(
                    children: mapIn
                        .map((e) => LabelAndValueWidget(mapTitleValue: e))
                        .toList(),
                  ),
                  Divider(thickness: 2, height: 25),
                  Text('Saidas', style: styleLabel),
                  SizedBox(height: 10),
                  Column(
                    children: mapOut
                        .map((e) => LabelAndValueWidget(mapTitleValue: e))
                        .toList(),
                  ),
                  if (mapOverall.length > 0)
                    Column(
                      children: [
                        SizedBox(height: 30),
                        Text('Resultado do Mês', style: styleLabel),
                        SizedBox(height: 15),
                        Column(
                          children: mapOverall
                              .map((e) => LabelAndValueWidget(mapTitleValue: e))
                              .toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabelAndValueWidget extends StatelessWidget {
  const LabelAndValueWidget({
    Key key,
    @required this.mapTitleValue,
  }) : super(key: key);

  final Map<String, String> mapTitleValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mapTitleValue.keys.first,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 20),
              Text(mapTitleValue.values.first),
            ],
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
