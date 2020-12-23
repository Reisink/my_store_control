class AccountOut {
  String account;
  double value;

  AccountOut({
    this.account,
    this.value,
  });

  factory AccountOut.fromJson(Map<String, dynamic> parsedJson) {
    return AccountOut(
      account: parsedJson['account'],
      value: double.parse(parsedJson['value']),
    );
  }
}
