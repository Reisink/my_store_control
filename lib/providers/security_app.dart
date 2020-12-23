import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:store_control/constants/importants.dart';
import 'package:store_control/providers/store_data.dart';
import 'package:store_control/providers/user.dart';

class SecurityApp with ChangeNotifier {
  String _token;
  DateTime _expiresIn;
  StoreData _store;
  User _user;

  void setStore(StoreData store) {
    this._store = store;
  }

  StoreData get store => this._store;

  void setUser(User user) {
    this._user = user;
  }

  User get user => this._user;

  Future<String> token() async {
    if (!this._tokenValid()) {
      this._token = await this._getTokenRequest();
      this._expiresIn = DateTime.now().add(Duration(seconds: 3600));
      notifyListeners();
    }

    return this._token;
  }

  bool _tokenValid() {
    return this._expiresIn != null && this._expiresIn.isAfter(DateTime.now());
  }

  Future<String> _getTokenRequest() async {
    var body = {
      "email": "admin@app-store-control.com",
      "password": "YhV6IZi7wPfjOPYCUfPG3TkSJLY2",
      "returnSecureToken": true
    };

    var response = await http
        .post(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Importantes.API_KEY}',
            body: jsonEncode(body))
        .timeout(Duration(seconds: 10), onTimeout: () => null);

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      var token = result['idToken'];
      return token;
    } else {
      return '';
    }
  }
}
