class Payment {
  String method;
  int times;
  double value;

  Payment({this.method, this.value, this.times = 1});

  factory Payment.fromJson(Map<String, dynamic> parsedJson) {
    return Payment(
      method: parsedJson['method'],
      times: parsedJson['times'],
      value: double.parse(parsedJson['value']),
    );
  }
}
