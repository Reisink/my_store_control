class CashDesk {
  DateTime createdAt;
  String createdBy;
  DateTime cashDeskAt;
  String cashDeskBy;
  double caixa;
  double sangria;
  double conta;
  double picpay;

  CashDesk({
    this.createdAt,
    this.createdBy,
    this.cashDeskAt,
    this.cashDeskBy,
    this.caixa,
    this.sangria,
    this.conta,
    this.picpay,
  });

  factory CashDesk.fromJson(Map<String, dynamic> parsedJson) {
    return CashDesk(
      createdAt: DateTime.parse(parsedJson['createdAt']),
      createdBy: parsedJson['createdBy'],
      cashDeskAt: DateTime.parse(parsedJson['cashDeskAt']),
      cashDeskBy: parsedJson['cashDeskBy'],
      caixa: double.parse(parsedJson['caixa']),
      sangria: double.parse(parsedJson['sangria']),
      conta: double.parse(parsedJson['conta']),
      picpay: double.parse(parsedJson['picpay']),
    );
  }
}
