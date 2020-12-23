import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/providers/cash_desk.dart';
import 'package:store_control/providers/cash_out.dart';
import 'package:store_control/providers/payment.dart';
import 'package:store_control/providers/sales.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';

class FinancialClose {
  static Future<List<Sale>> sales(BuildContext ctx, String periodo) async {
    GeneralRequests reqs = GeneralRequests(
        securityApp: Provider.of<SecurityApp>(ctx, listen: false));
    var getJson = await reqs.getRequestItems(
      collection: 'sales/$periodo',
    );
    return getJson != null
        ? getJson.values.toList().map((e) => Sale.fromJson(e)).toList()
        : List<Sale>();
  }

  static Future<List<CashOut>> cashOuts(
      BuildContext ctx, String periodo) async {
    GeneralRequests reqs = GeneralRequests(
        securityApp: Provider.of<SecurityApp>(ctx, listen: false));
    var getJson = await reqs.getRequestItems(
      collection: 'cashOuts/$periodo',
    );

    return getJson != null
        ? getJson.values.toList().map((e) => CashOut.fromJson(e)).toList()
        : List<CashOut>();
  }

  static Future<List<CashDesk>> cashDesks(
      BuildContext ctx, String periodo) async {
    GeneralRequests reqs = GeneralRequests(
        securityApp: Provider.of<SecurityApp>(ctx, listen: false));
    var getJson = await reqs.getRequestItems(
      collection: 'cashDesks/$periodo',
    );
    return getJson != null
        ? getJson.values.toList().map((e) => CashDesk.fromJson(e)).toList()
        : List<CashDesk>();
  }

  static String getValuePayment(List<Payment> payments, String method) {
    return payments
        .map((e) {
          if (e.method == method)
            return e.value;
          else
            return 0.0;
        })
        .reduce((value, element) => value + element)
        .toStringAsFixed(2);
  }

  static List<Map<String, String>> fechamento(List<CashDesk> _cashdesk) {
    if (_cashdesk.length > 0) {
      //Usar o último fechamento por enquanto
      final _aux = _cashdesk.last;

      return [
        {'Em Caixa:': 'R\$ ${_aux.caixa.toStringAsFixed(2)}'},
        {'Sangria:': 'R\$ ${_aux.sangria.toStringAsFixed(2)}'},
        {'Saldo Conta:': 'R\$ ${_aux.conta.toStringAsFixed(2)}'},
        {'Saldo Picpay:': 'R\$ ${_aux.picpay.toStringAsFixed(2)}'},
        // {'Sangria D-1:': 'R\$ 0'},
      ];
    } else {
      return [
        {'Fechamento': 'não foi registrado!'}
      ];
    }
  }

  static List<Map<String, String>> overall(
      List<Sale> _sales, List<CashOut> _cashOuts) {
    //Obter valores acululados
    final totalOfMonth = _sales.length > 0
        ? _sales
            .map((e) => e.total)
            .reduce((value, element) => value + element)
            .toStringAsFixed(2)
        : '0.00';
    final piecesOfMonth = _sales.length > 0
        ? _sales
            .map((e) => e.pieces)
            .reduce((value, element) => value + element)
        : 0;

    final cashOutOfMonth = _cashOuts.length > 0
        ? _cashOuts
            .map((e) => e.total)
            .reduce((value, element) => value + element)
            .toStringAsFixed(2)
        : '0.00';

    return [
      {'Valor Total: ': 'R\$ $totalOfMonth'},
      {'Total de Vendas: ': '${_sales.length}'},
      {'Total de Peças: ': '$piecesOfMonth peça(s)'},
      {'Total de Saídas: ': 'R\$ $cashOutOfMonth'},
    ];
  }

  static List<Map<String, String>> _salesByList(
    List<Sale> sales,
  ) {
    if (sales.length > 0) {
      var _total = sales
          .map((e) => e.total)
          .reduce((acum, total) => acum + total)
          .toStringAsFixed(2);

      var _payments = List<Payment>();

      //Todo - Reescrever utilizando map
      sales.map((e) => e.payments).forEach((payments) {
        payments.forEach((payment) {
          _payments.add(payment);
        });
      });

      var list = StaticLists.getPayments();
      var out = [
        {'Valor Total': 'R\$ $_total'},
      ];

      list.forEach((element) {
        var value = getValuePayment(_payments, element['payment']);
        if (value != '0.00' && element['payment'] != 'Troca')
          out.add({'+ ${element['payment']}': 'R\$ $value'});
      });

      return out;
    } else {
      return [
        {'Total de Vendas:': 'R\$ 0.00'},
      ];
    }
  }

  static List<Map<String, String>> entradas(
    List<Sale> sales,
  ) {
    if (sales.length > 0) {
      var _total = sales
          .map((e) => e.total)
          .reduce((acum, total) => acum + total)
          .toStringAsFixed(2);

      var _listSaleStore = sales.expand((s) => [if (!s.isDelivery) s]).toList();
      var _listSaleDelivery =
          sales.expand((s) => [if (s.isDelivery) s]).toList();

      var _store = _salesByList(_listSaleStore);
      var _delivery = _salesByList(_listSaleDelivery);

      var result = List<Map<String, String>>();

      result.add({'Total de Vendas:': 'R\$ $_total'});
      result.add({'': ''});
      result.add({'LOJA FISICA': '${_listSaleStore.length} venda(s)'});
      result.addAll(_store);
      result.add({'': ''});
      result.add({'ENTREGA': '${_listSaleDelivery.length} venda(s)'});
      result.addAll(_delivery);

      return result;
    } else {
      return [
        {'Total de Vendas:': 'R\$ 0.00'},
      ];
    }
  }

  static List<Map<String, String>> saidas(List<CashOut> cashOuts) {
    if (cashOuts.length > 0) {
      var total = cashOuts
          .map((e) => e.total)
          .reduce((value, element) => value + element)
          .toStringAsFixed(2);

      var details = cashOuts
          .map((e) => {
                '${e.reason} ${e.detail.isNotEmpty ? '\n' + e.detail : ''}':
                    'R\$ ${e.total.toStringAsFixed(2)}'
              })
          .toList();

      details.insert(0, {'Valor Total': 'R\$ $total'});

      return details;
    } else {
      return [
        {'Valor Total': 'R\$ 0.00'}
      ];
    }
  }

  static List<Map<String, String>> estoque(List<Sale> sales) {
    if (sales.length > 0) {
      var _pieces = sales
          .map((e) => e.pieces)
          .reduce((value, element) => value + element);

      String _trocas;

      try {
        var list = sales
            .map((sale) => sale.payments)
            .reduce((value, element) => value + element)
            .expand((pay) => [if (pay.method == 'Troca') pay.value]);
        _trocas =
            '${list.reduce((value, element) => value + element).toStringAsFixed(2)} / ${list.length}';
      } catch (_) {
        _trocas = '0.00 / 0';
      }

      return [
        {'Qtd. Vendas:': '${sales.length}'},
        {'Peças Vendidas:': '$_pieces'},
        {'Trocas:': 'R\$ $_trocas'},
      ];
    } else {
      return [
        {'Qtd. Vendas:': '0'},
        {'Peças Vendidas:': '0'},
        {'Trocas:': '0'},
      ];
    }
  }
}
