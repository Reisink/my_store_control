import 'package:store_control/api/general_request.dart';
import 'package:store_control/providers/payment.dart';
import 'package:store_control/providers/products.dart';
import 'package:store_control/providers/security_app.dart';

import 'payment.dart';

class Sale {
  DateTime createdAt;
  String createdBy;
  DateTime soldAt;
  String soldBy;
  String name;
  String lastname;
  String phone;
  String observation;
  int pieces;
  double total;
  bool isDelivery;
  bool isSaleBySite;
  List<Product> items;
  List<Payment> payments;

  Sale({
    this.createdAt,
    this.createdBy,
    this.soldAt,
    this.soldBy,
    this.name,
    this.lastname,
    this.phone,
    this.observation,
    this.pieces,
    this.total,
    this.isDelivery,
    this.isSaleBySite,
    this.items,
    this.payments,
  });

  factory Sale.fromJson(Map<String, dynamic> parsedJson) {
    return Sale(
      createdAt: DateTime.parse(parsedJson['createdAt']),
      createdBy: parsedJson['createdBy'],
      soldAt: DateTime.parse(parsedJson['soldAt']),
      soldBy: parsedJson['soldBy'],
      name: parsedJson['name'],
      lastname: parsedJson['lastname'],
      phone: parsedJson['phone'],
      observation: parsedJson['observation'] ?? '',
      isDelivery: parsedJson['isDelivery'] ?? false,
      isSaleBySite: parsedJson['isSaleBySite'] ?? false,
      pieces: parsedJson['pieces'],
      total: double.parse(parsedJson['total']),
      items: (parsedJson['items'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
      payments: (parsedJson['payments'] as List)
          .map((e) => Payment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "phone": this.phone,
      "createdAt": this.createdAt.toIso8601String(),
      "createdBy": this.createdBy,
      "soldAt": this.soldAt.toIso8601String(),
      "soldBy": this.soldBy,
      "pieces": this.pieces,
      "total": this.total.toStringAsFixed(2),
      "observation": this.observation,
      "isDelivery": this.isDelivery,
      "isSaleBySite": this.isSaleBySite,
      "items": this
          .items
          .map((e) => {
                "category": e.category,
                "size": e.size,
                "type": e.type,
                "quantity": e.quantity,
                "value": e.value.toStringAsFixed(2),
              })
          .toList(),
      "payments": this
          .payments
          .map((e) => {
                "method": e.method,
                "value": e.value.toStringAsFixed(2),
                "times": e.times,
              })
          .toList()
    };
  }
}

class Sales {
  List<Sale> list;
  Sales() {
    this.list = List<Sale>();
  }

  Future<void> load(String periodo, SecurityApp app) async {
    final reqs = GeneralRequests(securityApp: app);
    final sales = await reqs.getRequestItems(collection: 'sales/$periodo');

    if (sales != null)
      this.list = sales.values.map((e) => Sale.fromJson(e)).toList();
    else
      this.list = List<Sale>();
  }

  List<Sale> salesByDay(DateTime day) {
    return this.list.where((sale) => sale.soldAt == day).toList();
  }

  Map<String, dynamic> salesByDayAcum(DateTime day) {
    String total = '0.00';
    int pieces = 0;
    var list = this
        .list
        .where((sale) =>
            sale.soldAt.year == day.year &&
            sale.soldAt.month == day.month &&
            sale.soldAt.day == day.day)
        .toList();

    if (list == null) {
      list = List<Sale>();
    } else if (list.length > 0) {
      total = list
          .map((e) => e.total)
          .reduce((value, element) => value + element)
          .toStringAsFixed(2);

      pieces =
          list.map((e) => e.pieces).reduce((value, element) => value + element);
    }

    return {
      'day': day,
      'total': total,
      'pieces': pieces,
      'quantity': list.length,
      'sales': List<Sale>.from(list.reversed),
    };
  }

  String total() {
    return this.list.length > 0
        ? this
            .list
            .map((e) => e.total)
            .reduce((value, element) => value + element)
            .toStringAsFixed(2)
        : '0.00';
  }

  int pieces() {
    return this.list.length > 0
        ? this
            .list
            .map((e) => e.pieces)
            .reduce((value, element) => value + element)
        : 0;
  }
}
