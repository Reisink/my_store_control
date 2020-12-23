import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/constants/importants.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/user.dart';
import 'package:store_control/widgets/customs/my_snackbar.dart';

class FormSecurity extends StatefulWidget {
  @override
  _FormSecurityState createState() => _FormSecurityState();
}

class _FormSecurityState extends State<FormSecurity> {
  final list = List.generate(9, (index) => index + 1)..add(0);
  var listUsers = List<User>();
  int errors;
  String codeSecurity;
  int waitTime;
  SecurityApp security;
  GeneralRequests myRequests;
  bool isLoadingUsers = false;
  bool hasError = false;
  String msgError = '';

  Future<void> waitFailedAttempts() async {
    setState(() {
      waitTime = 60;
    });
    while (waitTime > 0) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        waitTime--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    security = Provider.of<SecurityApp>(context, listen: false);
    errors = 0;
    codeSecurity = '';
    waitTime = 0;
    loadUser();
  }

  loadUser() {
    setState(() {
      isLoadingUsers = true;
    });

    myRequests = GeneralRequests(securityApp: security);

    myRequests.getVersion().then((value) {
      if (Importantes.APP_VERSION != value) {
        setState(() {
          hasError = true;
          isLoadingUsers = false;
          msgError =
              'Versão desatualizada! Entre em contato com o Administrador';
          return;
        });
      } else {
        myRequests.getUsers().then((users) {
          listUsers = users.map((e) => User.fromJson(e)).toList();
          setState(() {
            isLoadingUsers = false;
          });
        }).catchError((e) {
          setState(() {
            hasError = true;
            isLoadingUsers = false;
            msgError = 'Não foi possível conectar!';
          });
        });
      }
    });
  }

  User getUserByCode(String code) {
    return listUsers.firstWhere(
      (user) => user.accessKey == code,
      orElse: () => User(),
    );
  }

  onPressedCode(String code) async {
    codeSecurity += code;
    if (codeSecurity.length >= 4) {
      var user = getUserByCode(codeSecurity);
      if (user.name != null) {
        setState(() {
          isLoadingUsers = true;
        });
        security.setUser(user);
        security.setStore(await myRequests.getStore(user.storeKey));

        Navigator.popAndPushNamed(context, AppRoutes.FORM_REGISTER_SALE);
      } else {
        MySnackBar.showSnack(
            context, 'INFO', 'Código incorreto, digite novamente!');
        codeSecurity = '';
        errors++;
      }
      // print('Erros $errors');
      if (errors > 2) {
        await waitFailedAttempts();
        errors = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, 0),
            end: Alignment(0, 1),
            colors: [
              Theme.of(context).primaryColorDark,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Código de segurança',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 25),
            Expanded(
              child: waitTime > 0
                  ? Center(
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        radius: 45,
                        child: Text(
                          waitTime.toString(),
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    )
                  : isLoadingUsers
                      ? Center(child: LinearProgressIndicator())
                      : hasError
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  msgError,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red[200],
                                      fontStyle: FontStyle.italic),
                                ),
                                SizedBox(height: 20),
                                OutlineButton(
                                  onPressed: loadUser,
                                  child: Text(
                                    'Tentar novamente',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white60),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width > 350
                                  ? 350
                                  : MediaQuery.of(context).size.width,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 14.0,
                                  runSpacing: 10.0,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: list
                                      .map(
                                        (e) => Material(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            splashRadius: 37,
                                            splashColor: Colors.teal,
                                            iconSize: 62,
                                            icon: CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColorLight,
                                              radius: 35,
                                              child: Text(e.toString(),
                                                  style:
                                                      TextStyle(fontSize: 28)),
                                            ),
                                            onPressed: () =>
                                                onPressedCode(e.toString()),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
            ),
            SizedBox(height: 25),
            waitTime == 0
                ? Container(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton.icon(
                        onPressed: () => codeSecurity = '',
                        icon: Icon(Icons.security),
                        label: Text('Digitar novamente'),
                      ),
                    ),
                  )
                : Text('Aguarde para tentar novamente'),
          ],
        ),
      ),
    );
  }
}
