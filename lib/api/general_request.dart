import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:store_control/constants/urls.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/store_data.dart';

class GeneralRequests {
  SecurityApp securityApp;
  GeneralRequests({
    this.securityApp,
  });

  Future<String> getVersion() async {
    String token = await this.securityApp.token();
    var response = await http
        .get('${AppUrls.FIREBASE_SETUP}.json?auth=$token')
        .timeout(Duration(seconds: 3));
    return jsonDecode(response.body)['version'] ?? 'erro';
  }

  Future<List<dynamic>> getUsers() async {
    String token = await this.securityApp.token();
    var response = await http
        .get('${AppUrls.FIREBASE_USERS}.json?auth=$token')
        .timeout(Duration(seconds: 3));
    var result = jsonDecode(response.body) as Map<String, dynamic>;
    return result.values.map((e) => e).toList();
  }

  Future<StoreData> getStore(String storeKey) async {
    String token = await this.securityApp.token();

    var response =
        await http.get('${AppUrls.FIREBASE_STORES}/$storeKey.json?auth=$token');

    var result = jsonDecode(response.body) as Map<String, dynamic>;
    return StoreData.fromJson(result['registration']);
  }

  Future<bool> postRequest({
    @required Map<String, dynamic> body,
    @required String collection,
  }) async {
    String token = await this.securityApp.token();
    var response = await http.post(
        '${AppUrls.FIREBASE_STORES}/${this.securityApp.user.storeKey}/$collection.json?auth=$token',
        body: jsonEncode(body));

    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future<bool> putRequest({
    @required Map<String, dynamic> body,
    @required String key,
    @required String collection,
  }) async {
    String token = await this.securityApp.token();
    var response = await http.put(
        '${AppUrls.FIREBASE_STORES}/${this.securityApp.user.storeKey}/$collection/$key.json?auth=$token',
        body: jsonEncode(body));

    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future<Map<String, dynamic>> getRequestItems({
    String collection,
  }) async {
    String token = await this.securityApp.token();
    var _url =
        '${AppUrls.FIREBASE_STORES}/${this.securityApp.user.storeKey}/$collection.json?auth=$token';

    var response = await http.get(_url);

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      return map;
    } else
      return null;
  }
}
