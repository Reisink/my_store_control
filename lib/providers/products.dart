import 'package:flutter/services.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/util/remove_accents.dart';

class Product {
  String category;
  String type;
  String size;
  String color;
  int quantity;
  double value;

  Product({
    this.category,
    this.size = 'ND',
    this.type,
    this.color = 'ND',
    this.value,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> parsedJson) {
    return Product(
      category: parsedJson['category'],
      size: parsedJson['size'] ?? 'ND',
      color: parsedJson['color'] ?? 'ND',
      quantity: parsedJson['quantity'],
      type: parsedJson['type'],
      value: double.parse(parsedJson['value'].toString()),
    );
  }
}

class Products {
  List<Product> list;
  Products() {
    this.list = List<Product>();
  }

  void clear() {
    this.list.clear();
  }

  void add(Product product) {
    var p = ifExist(product);

    if (p.quantity != null) {
      p.quantity++;
    } else {
      this.list.add(product);
    }
  }

  void addByIndex(int index) {
    this.list[index].quantity++;
  }

  int size() {
    return this.list.length;
  }

  void removeByIndex(int index) {
    this.list.removeAt(index);
  }

  void removeByUnit(int index) {
    this.list[index].quantity--;
  }

  void removeByUnitAndZero(int index) {
    this.list[index].quantity--;
    if (this.list[index].quantity == 0) {
      this.list.removeAt(index);
    }
  }

  bool notExists(Product p) {
    return this.list.length == 0 ||
        null ==
            this.list.firstWhere(
                (e) =>
                    e.category == p.category &&
                    e.size == p.size &&
                    e.type == p.type &&
                    e.color == p.color &&
                    e.value == p.value,
                orElse: () => null);
  }

  Product ifExist(Product p) {
    var find = this.list.length == 0
        ? Product()
        : this.list.firstWhere(
            (e) =>
                e.category == p.category &&
                e.size == p.size &&
                e.type == p.type &&
                e.color == p.color &&
                e.value == p.value,
            orElse: () => Product());

    return find;
  }

  String total() {
    return this.list.length > 0
        ? this
            .list
            .map((e) => e.value * e.quantity)
            .reduce((value, element) => value + element)
            .toStringAsFixed(2)
        : '0.00';
  }

  int pieces() {
    return this.list.length > 0
        ? this
            .list
            .map((e) => e.quantity)
            .reduce((value, element) => value + element)
        : 0;
  }

  Map<String, dynamic> getJson(String description) {
    return {
      'createdAt': DateTime.now().toIso8601String(),
      'description': description,
      'quantity': this.pieces(),
      'total': this.total(),
      'products': this
          .list
          .map((e) => {
                'category': e.category,
                'type': e.type,
                'size': e.size,
                'color': e.color,
                'quantity': e.quantity,
                'value': e.value,
              })
          .toList()
    };
  }

  void copyDataToInventory() {
    var label = StaticLists.fieldNuvemShop()
        .reduce((value, element) => '$value\t$element');
    var strSend = this
        .list
        .map((e) =>
            '${_getToUrl(e.category, e.type)}\t${e.category} ${e.type}\t${e.category.toUpperCase()}\tTamanho\t${e.size}\tCor\t${e.color}\t${e.value}\t\t${e.quantity}\tSIM\tNÃO\t\tSIM')
        .reduce((value, element) => '$value\n$element');
    Clipboard.setData(ClipboardData(text: '$label\n$strSend'));
  }

  String _getToUrl(String category, String product) {
    return RemoveAccents.replace('$category-$product').toLowerCase();
  }
}
