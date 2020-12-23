import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/constants/routes.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/widgets/customs/my_snackbar.dart';

class FormOpenCloseDesk extends StatefulWidget {
  @override
  _FormOpenCloseDeskState createState() => _FormOpenCloseDeskState();
}

class _FormOpenCloseDeskState extends State<FormOpenCloseDesk> {
  var _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()));
  TextEditingController _valueContaController = new TextEditingController();
  TextEditingController _valuePicpayController = new TextEditingController();
  TextEditingController _valueSangriaController = new TextEditingController();
  TextEditingController _valueCaixaController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _caixaFocusNode = FocusNode();
  final _spaceBox = 22.0;

  @override
  void initState() {
    super.initState();
    _caixaFocusNode.requestFocus();
  }

  cleanForm() {
    _formKey.currentState.reset();
    _caixaFocusNode.requestFocus();
  }

  auxDouble(String value) {
    return double.parse(value.replaceAll(',', '.')).toStringAsFixed(2);
  }

  void submit() {
    FocusScope.of(context).requestFocus(new FocusNode());

    if (!_formKey.currentState.validate()) {
      MySnackBar.showSnack(context, 'NOK', 'Erro ao validar formulário!');
    }

    var _security = Provider.of<SecurityApp>(context, listen: false);

    var _mapToJson = {
      'createdAt': DateTime.now().toIso8601String(),
      'createdBy': _security.user.name,
      'cashDeskAt': DateFormat('dd/MM/yyyy HH:mm')
          .parse(_dateController.text)
          .toIso8601String(),
      'cashDeskBy': _security.user.name,
      'caixa': auxDouble(_valueCaixaController.text),
      'sangria': auxDouble(_valueSangriaController.text),
      'conta': auxDouble(_valueContaController.text),
      'picpay': auxDouble(_valuePicpayController.text)
    };

    var urlpart = DateFormat('yyyy-MM')
        .format(DateFormat('dd/MM/yyyy HH:mm').parse(_dateController.text));

    var reqs = GeneralRequests(securityApp: _security);
    var result = reqs.postRequest(
      collection: 'cashDesks/$urlpart',
      body: _mapToJson,
    );

    result.then((value) {
      if (value) {
        Navigator.of(context).popAndPushNamed(AppRoutes.GRID_FINANCIAL_CLOSE);
      } else {
        MySnackBar.showSnack(
            context, 'NOK', 'Falha ao salvar! Verifique sua conexão!');
      }
    });
  }

  String validate(String campo, String valor) {
    if (valor.isEmpty) {
      return "O campo $campo deve ser preenchido!";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Data/Hora",
                        ),
                        onTap: () => MySnackBar.showSnack(context, 'INFO',
                            'A data e hora não pode ser alterada!'),
                      ),
                      Divider(),
                      TextFormField(
                        focusNode: _caixaFocusNode,
                        controller: _valueCaixaController,
                        keyboardType: TextInputType.number,
                        validator: (value) => validate('Valor em caixa', value),
                        decoration: InputDecoration(
                            prefix: Text('R\$ '), labelText: 'Valor em Caixa'),
                      ),
                      SizedBox(height: _spaceBox),
                      TextFormField(
                        controller: _valueSangriaController,
                        keyboardType: TextInputType.number,
                        validator: (value) => validate('Sangria', value),
                        decoration: InputDecoration(
                            prefix: Text('R\$ '), labelText: 'Sangria'),
                      ),
                      SizedBox(height: _spaceBox),
                      TextFormField(
                        controller: _valueContaController,
                        keyboardType: TextInputType.number,
                        validator: (value) => validate('Saldo em conta', value),
                        decoration: InputDecoration(
                            prefix: Text('R\$ '), labelText: 'Saldo em Conta'),
                      ),
                      SizedBox(height: _spaceBox),
                      TextFormField(
                        controller: _valuePicpayController,
                        keyboardType: TextInputType.number,
                        validator: (value) => validate('Saldo Picpay', value),
                        decoration: InputDecoration(
                            prefix: Text('R\$ '), labelText: 'Saldo Picpay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RaisedButton.icon(
                    onPressed: cleanForm,
                    icon: const Icon(Icons.restore_from_trash),
                    label: Text('Limpar'),
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: RaisedButton.icon(
                    onPressed: submit,
                    icon: const Icon(Icons.save),
                    label: Text('Salvar'),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
