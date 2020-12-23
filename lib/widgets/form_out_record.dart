import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/providers/account_out.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/widgets/customs/my_snackbar.dart';

class FormOutRecord extends StatefulWidget {
  @override
  _FormOutRecordState createState() => _FormOutRecordState();
}

class _FormOutRecordState extends State<FormOutRecord> {
  final _space = 22.0;
  final _formKey = GlobalKey<FormState>();
  final _fieldSubTypeKey = GlobalKey<FormFieldState>();
  var _payments = List<AccountOut>();
  var _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var _typeController = TextEditingController();
  var _subTypeController = TextEditingController();
  var _valueController = TextEditingController();
  var _detailController = TextEditingController();
  var _dateMaskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var _itemsTypes = List<DropdownMenuItem<dynamic>>();
  var _itemsSubTypes = List<DropdownMenuItem<dynamic>>();

  var _dateFocusNode = FocusNode();
  var _typeFocusNode = FocusNode();
  var _subTypeFocusNode = FocusNode();
  var _valueFocusNode = FocusNode();
  var _subTypeIsOther = false;

  @override
  void initState() {
    super.initState();

    // var _aux2 = StaticLists.getTypesCashOut().map((e) => e.keys.first).toList();

    // _itemsTypes = _aux2
    //     .map((e) => DropdownMenuItem(
    //           child: Text(e),
    //           value: e,
    //         ))
    //     .toList();

    _itemsTypes = StaticLists.getTypesCashOut2()
        .keys
        .map((e) => DropdownMenuItem(
              child: Text(e),
              value: e,
            ))
        .toList();
  }

  void clearForm() {
    setState(() {
      _formKey.currentState.reset();
      _payments.clear();
      _valueController.text = '';
      _detailController.text = '';
      _subTypeController.text = '';
    });
    _dateFocusNode.requestFocus();
  }

  void fillSubType(String e) {
    if (e == 'Outras') {
      setState(() {
        _subTypeIsOther = true;
        _subTypeController.text = '';
        _subTypeFocusNode.requestFocus();
      });
      return;
    }
    var items = StaticLists.getTypesCashOut2()[e] as List<String>;
    _typeController.text = e;

    if (_fieldSubTypeKey.currentState != null)
      _fieldSubTypeKey.currentState.reset();

    setState(() {
      _subTypeIsOther = false;
      _itemsSubTypes = items
          .map((e) => DropdownMenuItem(
                child: Text(e),
                value: e,
              ))
          .toList();
    });
  }

  String validate(String campo, String valor) {
    if (valor == null || valor.isEmpty) {
      return "O campo $campo deve ser preenchido!";
    } else {
      return null;
    }
  }

  removePayment(String account) {
    setState(() {
      if (_payments.length > 0) {
        _payments.removeWhere((e) => e.account == account);
      }
    });
  }

  double valorFaltante() {
    return double.parse(_valueController.text, (_) => 0) - pagamentoRecebido();
  }

  double pagamentoRecebido() {
    return _payments.length > 0
        ? _payments
            .map((e) => e.value)
            .reduce((value, element) => value + element)
        : 0.00;
  }

  void submit() {
    //Recolher o teclado
    FocusScope.of(context).requestFocus(new FocusNode());

    if (valorFaltante() != 0) {
      MySnackBar.showSnack(
        context,
        'NOK',
        'Deve ser informado as contas de onde o valor saiu!',
      );
      return;
    }

    if (!_formKey.currentState.validate()) {
      MySnackBar.showSnack(context, 'NOK', 'Erro ao validar formulário!');
      _typeFocusNode.requestFocus();
    } else {
      var _security = Provider.of<SecurityApp>(context, listen: false);
      var _mapToJson = {
        "createdAt": DateTime.now().toIso8601String(),
        "createdBy": _security.user.name,
        "cashOutAt": DateFormat('dd/MM/yyyy')
            .parse(_dateController.text)
            .toIso8601String(),
        "cashOutBy": _security.user.name,
        "total": pagamentoRecebido().toStringAsFixed(2),
        "type": _typeController.text,
        "reason": _subTypeController.text,
        "detail": _detailController.text,
        "accounts": _payments
            .map((e) => {
                  "account": e.account,
                  "value": e.value.toStringAsFixed(2),
                })
            .toList()
      };

      var urlpart = DateFormat('yyyy-MM')
          .format(DateFormat('dd/MM/yyyy').parse(_dateController.text));
      var reqs = GeneralRequests(securityApp: _security);
      var result = reqs.postRequest(
        body: _mapToJson,
        collection: 'cashOuts/$urlpart',
      );

      result.then((value) {
        if (value) {
          clearForm();
          MySnackBar.showSnack(context, 'OK', 'Registro salvo com sucesso!');
        } else {
          MySnackBar.showSnack(
              context, 'NOK', 'Falha ao salvar! Verifique sua conexão!');
        }
      });
    }
  }

  void _showDialog(String method) {
    if (_valueController.text.isEmpty) {
      MySnackBar.showSnack(context, 'NOK', 'Informe o valor primeiro!');
      _valueFocusNode.requestFocus();
      return;
    }
    var _textInput =
        TextEditingController(text: valorFaltante().toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: Text("Conta de saída: $method"),
          content: TextFormField(
            controller: _textInput,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: <Widget>[
            // define os botões na base do dialogo
            FlatButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Aceitar"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value)
        setState(() {
          _payments.add(
            AccountOut(
              account: method,
              value: double.parse(_textInput.text),
            ),
          );
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Dados da Retirada',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: _space),
                    TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      focusNode: _dateFocusNode,
                      inputFormatters: [_dateMaskFormatter],
                      decoration: InputDecoration(
                        labelText: "Data da Retirada",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => showDatePicker(
                              // locale: Locale('pt_BR', 'BR'),
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 30)),
                              lastDate: DateTime.now())
                          .then((value) => _dateController.text =
                              DateFormat('dd/MM/yyyy').format(value)),
                      validator: (_) =>
                          validate('Data da Retirada', _dateController.text),
                    ),
                    SizedBox(height: _space),
                    DropdownButtonFormField(
                      focusNode: _typeFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Retirada',
                      ),
                      validator: (value) => validate('Tipo de Retirada', value),
                      items: _itemsTypes,
                      onChanged: (e) => fillSubType(e),
                    ),
                    SizedBox(height: _space),
                    _subTypeIsOther
                        ? TextFormField(
                            focusNode: _subTypeFocusNode,
                            controller: _subTypeController,
                            validator: (value) => validate('Motivo', value),
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Motivo',
                            ),
                          )
                        : DropdownButtonFormField(
                            key: _fieldSubTypeKey,
                            items: _itemsSubTypes,
                            validator: (value) => validate('Motivo', value),
                            onChanged: (e) => _subTypeController.text = e,
                            decoration: InputDecoration(
                              labelText: 'Motivo',
                            ),
                          ),
                    SizedBox(height: _space),
                    TextFormField(
                      focusNode: _valueFocusNode,
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return value.trim().isEmpty || double.parse(value) == 0
                            ? "O valor deve ser maior que zero!"
                            : null;
                      },
                      decoration: InputDecoration(
                        labelText: "Valor",
                      ),
                    ),
                    SizedBox(height: _space),
                    TextFormField(
                      controller: _detailController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Detalhe',
                      ),
                    ),
                    SizedBox(height: _space),
                    Text(
                      'Conta de Retirada',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: _space),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 12.0,
                      children: StaticLists.getAccounts().map((e) {
                        return Container(
                          width: 100,
                          child: RaisedButton(
                            color: e['color'],
                            onPressed: () => _showDialog(e['account']),
                            child: FittedBox(child: Text(e['account'])),
                          ),
                        );
                      }).toList(),
                    ),
                    Divider(height: 32, thickness: 5),
                    Container(
                      height: 140,
                      child: Stack(
                        // alignment: Alignment.bottomRight,
                        overflow: Overflow.visible,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            height: 100,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: _payments.length > 0
                                  ? Wrap(
                                      children: _payments
                                          .map(
                                            (e) => Card(
                                              color:
                                                  Theme.of(context).accentColor,
                                              child: Container(
                                                height: 45,
                                                width: 180,
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      IconButton(
                                                        color: Colors.white,
                                                        icon: Icon(Icons.close),
                                                        onPressed: () =>
                                                            removePayment(
                                                                e.account),
                                                      ),
                                                      Text(
                                                        "${e.account} R\$ ${e.value.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : Text('Informe a conta de saída!'),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 30,
                            child: CircleAvatar(
                              radius: 35,
                              child:
                                  Text(pagamentoRecebido().toStringAsFixed(2)),
                            ),
                          ),
                        ],
                      ),
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
                  onPressed: clearForm,
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
    );
  }
}
