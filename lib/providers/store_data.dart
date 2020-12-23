import 'dart:convert';
import 'dart:typed_data';

class StoreData {
  String name;
  String address;
  String number;
  String district;
  String city;
  String document;
  String mainContact;
  Uint8List logo;

  StoreData({
    this.name,
    this.address,
    this.number,
    this.district,
    this.city,
    this.document,
    this.mainContact,
    this.logo,
  });

  factory StoreData.fromJson(Map<String, dynamic> parsedJson) {
    return StoreData(
      name: parsedJson['name'],
      address: parsedJson['address'],
      number: parsedJson['number'],
      district: parsedJson['district'],
      city: parsedJson['city'],
      document: parsedJson['document'],
      mainContact: parsedJson['mainContact'],
      logo: base64Decode(parsedJson['logo']),
    );
  }

  void setStore(StoreData store) {
    this.name = store.name;
    this.address = store.address;
    this.number = store.number;
    this.district = store.district;
    this.city = store.city;
    this.document = store.document;
    this.mainContact = store.mainContact;
  }
}
