import 'package:store_control/providers/account_out.dart';

class CashOut {
  DateTime createdAt;
  String createdBy;
  DateTime cashOutAt;
  String cashOutBy;
  String type;
  String reason;
  String detail;
  double total;
  List<AccountOut> accounts;

  CashOut({
    this.createdAt,
    this.createdBy,
    this.cashOutAt,
    this.cashOutBy,
    this.type,
    this.reason,
    this.detail,
    this.total,
    this.accounts,
  });

  factory CashOut.fromJson(Map<String, dynamic> parsedJson) {
    return CashOut(
      createdAt: DateTime.parse(parsedJson['createdAt']),
      createdBy: parsedJson['createdBy'],
      cashOutAt: DateTime.parse(parsedJson['cashOutAt']),
      cashOutBy: parsedJson['cashOutBy'],
      type: parsedJson['type'],
      reason: parsedJson['reason'],
      detail: parsedJson['detail'],
      total: double.parse(parsedJson['total']),
      accounts: (parsedJson['accounts'] as List)
          .map((e) => AccountOut.fromJson(e))
          .toList(),
    );
  }
}
