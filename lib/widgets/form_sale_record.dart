import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/providers/payment.dart';
import 'package:store_control/providers/products.dart';
import 'package:store_control/providers/sales.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/widgets/customs/my_datetime_picker.dart';
import 'package:store_control/widgets/customs/my_list_products.dart';
import 'package:store_control/widgets/customs/my_select_toggle_buttons.dart';
import 'package:store_control/widgets/customs/my_snackbar.dart';

class FormSaleRecord extends StatefulWidget {
  @override
  _FormSaleRecordState createState() => _FormSaleRecordState();
}

class _FormSaleRecordState extends State<FormSaleRecord> {
  final _formKey = GlobalKey<FormState>();
  final _space = 22.0;
  var _products = Products();
  var _payments = List<Payment>();

  var _valueFocus = FocusNode();
  var _nameFocus = FocusNode();
  var _phoneFocus = FocusNode();
  var _observationFocus = FocusNode();
  var _categoryController = TextEditingController();
  var _typeController = TextEditingController();
  var _sizeController = TextEditingController();
  var _valueController = TextEditingController();
  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _observationController = TextEditingController();
  var _checkSaleBySite = false;
  var _checkDelivery = false;

  var _scrollController = ScrollController();

  // var _dateMaskFormatter = new MaskTextInputFormatter(
  //     mask: '##/##/#### ##:##', filter: {"#": RegExp(r'[0-9]')});
  var _phoneMaskFormatter = new MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  var _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var _timeController =
      TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

  List<String> _listCategory;
  List<String> _listSizes;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _listSizes = StaticLists.getSizes();
    _listCategory = StaticLists.getCategories();
  }

  String validate(String campo, String valor) {
    if (valor.isEmpty) {
      return "O campo $campo deve ser preenchido!";
    } else {
      return null;
    }
  }

  String validateWithSize(String campo, String valor, int sizeMin) {
    if (valor.isEmpty) {
      return "O campo $campo deve ser preenchido!";
    } else if (valor.length < sizeMin) {
      return "O campo $campo deve ser maior que $sizeMin";
    } else {
      return null;
    }
  }

  String getCustomKey(DateTime _dateTimeSale) {
    var makeSure = DateTime.now().millisecondsSinceEpoch.toString();
    return DateFormat('ddHHmm').format(_dateTimeSale) +
        // _nameController.text.substring(0, 2).toUpperCase() +
        '-' +
        makeSure.substring(makeSure.length - 6);
  }

  void submit() {
    //Recolher o teclado
    FocusScope.of(context).requestFocus(new FocusNode());

    if (valorFaltante() != 0.0) {
      MySnackBar.showSnack(
          context, 'NOK', 'O total está diferente do valor pago!');
      return;
    }

    if (!_formKey.currentState.validate()) {
      MySnackBar.showSnack(context, 'NOK', 'Erro ao validar formulário!');
    } else {
      setState(() {
        isSaving = true;
      });

      var _security = Provider.of<SecurityApp>(context, listen: false);
      var _dateTimeSale = DateFormat('dd/MM/yyyy HH:mm')
          .parse('${_dateController.text} ${_timeController.text}');
      var urlpart = DateFormat('yyyy-MM').format(_dateTimeSale);
      var _mapToJson = Sale(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              createdAt: DateTime.now(),
              createdBy: _security.user.name,
              soldAt: _dateTimeSale,
              soldBy: _security.user.name,
              pieces: pecas(),
              total: totalExceptChange(),
              observation: _observationController.text.trim(),
              isDelivery: _checkDelivery,
              isSaleBySite: _checkSaleBySite,
              items: _products.list,
              payments: _payments)
          .toJson();

      var reqs = GeneralRequests(securityApp: _security);
      var result = reqs.putRequest(
        body: _mapToJson,
        key: getCustomKey(_dateTimeSale),
        collection: 'sales/$urlpart',
      );

      result.then((value) {
        if (value) {
          if (_mapToJson['phone'].toString().isNotEmpty) {
            var reqs = GeneralRequests(
                securityApp: Provider.of<SecurityApp>(context, listen: false));
            reqs.postRequest(
              body: {
                'fullname': _mapToJson['name'],
                'phone': _mapToJson['phone']
              },
              collection: 'customers',
            );
          }
          setState(() {
            isSaving = false;
          });
          MySnackBar.showSnack(context, 'OK', 'Registro salvo com sucesso!');

          // if (_phoneController.text.isNotEmpty)
          //   MyAlertDialog.show(
          //     context,
          //     title: Text('Comprovante'),
          //     content: Text('Enviar para o(a) Cliente?'),
          //     onShow: (value) => sendSalesReceipt(),
          //   );

          cleanForm();
        } else {
          MySnackBar.showSnack(
              context, 'NOK', 'Falha ao salvar venda! Verifique sua conexão!');
          setState(() {
            isSaving = false;
          });
        }
      });
    }
  }

  cleanForm() {
    _formKey.currentState.reset();
    setState(() {
      _nameController.text = '';
      _phoneController.text = '';
      _typeController.text = '';
      _valueController.text = '';
      _observationController.text = '';
      _checkDelivery = false;
      _checkSaleBySite = false;
      _payments.clear();
      _products.list.clear();
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _timeController.text = DateFormat('HH:mm').format(DateTime.now());
    });

    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.decelerate);
  }

  int pecas() {
    return _products.list.length > 0
        ? _products.list
            .map((e) => e.quantity)
            .reduce((value, element) => value + element)
        : 0;
  }

  double valorFaltante() {
    return somar() - pagamentoRecebido();
  }

  double totalExceptChange() {
    try {
      return _payments
          .expand((pay) => [
                if (pay.method != 'Troca' && pay.method != 'Desconto') pay.value
              ])
          .reduce((value, element) => value + element);
    } catch (e) {
      return 0.0;
    }
  }

  double somar() {
    //Foi necessário toda essa confusão, porque no android o fato de usa a multiplicação fazia com que houve um diferenca
    var result = _products.list.length > 0
        ? _products.list
            .map((e) => (e.value * e.quantity))
            .reduce((value, element) => value + element)
        : 0.0;

    return double.parse((result).toStringAsFixed(2));
  }

  double pagamentoRecebido() {
    var result = _payments.length > 0
        ? _payments
            .map((e) => e.value)
            .reduce((value, element) => value + element)
        : 0.0;

    return double.parse((result).toStringAsFixed(2));
  }

  // void sendSalesReceipt() async {
  //   await FlutterLaunch.launchWathsApp(
  //     phone: _phoneController.text,
  //     message: "Hello",
  //   );
  // }

  void _showDialog(String method) {
    var _textInput =
        TextEditingController(text: valorFaltante().toStringAsFixed(2));

    _scrollController.animateTo(650,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: Text("Pagamento com $method"),
          content: TextFormField(
            controller: _textInput,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onTap: () => _textInput.selection = TextSelection(
                baseOffset: 0, extentOffset: _textInput.text.length),
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
      if (value && _textInput.text != '0.00')
        setState(() {
          _payments.add(
            Payment(
              method: method,
              value: double.parse(_textInput.text),
            ),
          );
        });
    });
  }

  removePayment(String method) {
    setState(() {
      if (_payments.length > 0) {
        _payments.removeWhere((e) => e.method == method);
      }
    });
  }

  addOrRemoveProduct(bool add) async {
    var product = Product(
      category: _categoryController.text,
      size: _sizeController.text,
      type: _typeController.text,
      quantity: 1,
      value: double.parse(_valueController.text),
    );

    setState(() {
      if (_products.list.length == 0) {
        _products.add(product);
      } else {
        var p = _products.ifExist(product);

        if (p.category != null) {
          if (add) {
            p.quantity++;
          } else {
            p.quantity--;
            if (p.quantity == 0) {
              _products.list.remove(p);
            }
          }
        } else {
          if (add) _products.add(product);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              MyDateTimePicker(
                labelText: 'Data/Hora da Venda',
                dateController: _dateController,
                timeController: _timeController,
                onPressed: (value) => setState(() {
                  print(value);
                  _dateController.text = value.split(' ')[0];
                  _timeController.text = value.split(' ')[1];
                }),
                // onValidateTime: (value) => validate('Hora', value),
                // onValidateDate: (value) => validate('Data', value),
              ),
              // TextFormField(
              //   controller: _dateController,
              //   validator: (_) =>
              //       validate('Data/Hora da venda', _dateController.text),
              //   inputFormatters: [_dateMaskFormatter],
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     labelText: "Data/Hora da Venda",
              //   ),
              // ),
              SizedBox(height: _space),
              Text(
                'Dados da Venda',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: _space),
              MySelectToggleButtons(
                listString: _listCategory,
                onPressed: (value) => _categoryController.text = value,
              ),
              SizedBox(height: _space),
              MySelectToggleButtons(
                listString: _listSizes,
                onPressed: (value) => _sizeController.text = value,
              ),
              SizedBox(height: _space),
              TextFormField(
                controller: _typeController,
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (_) {
                  _valueController.text = '';
                  _valueFocus.requestFocus();
                },
                onTap: () => _typeController.selection = TextSelection(
                    baseOffset: 0, extentOffset: _typeController.text.length),
                decoration: InputDecoration(
                  labelText: 'Nome do Produto',
                ),
                validator: (_) => _products.list.length > 0
                    ? null
                    : "Adicione ao menos um item ao carrinho!",
              ),
              TextFormField(
                controller: _valueController,
                focusNode: _valueFocus,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _valueController.text.isNotEmpty
                    ? addOrRemoveProduct(true)
                    : null,
                decoration: InputDecoration(
                  labelText: "Valor",
                ),
              ),
              // SizedBox(height: _space),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      iconSize: 28,
                      icon: Icon(
                        Icons.remove_shopping_cart,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () => setState(() {
                            _products.clear();
                            _payments.clear();
                          })),
                  IconButton(
                      iconSize: 28,
                      icon: Icon(
                        Icons.remove_circle,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        addOrRemoveProduct(false);
                      }),
                  IconButton(
                      iconSize: 28,
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        addOrRemoveProduct(true);
                      }),
                ],
              ),
              Divider(height: 20, thickness: 2),
              MyListProducts(
                isLoading: false,
                products: _products,
              ),
              Divider(height: 10, thickness: 2),
              SizedBox(height: 10),
              Text(
                'Dados do Pagamento',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: _space),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 12.0,
                children: StaticLists.getPayments().map((e) {
                  return Container(
                    width: 100,
                    child: RaisedButton(
                      color: e['color'],
                      onPressed: () => _showDialog(e['payment']),
                      child: FittedBox(child: Text(e['payment'])),
                    ),
                  );
                }).toList(),
              ),

              Stack(
                alignment: Alignment.bottomRight,
                overflow: Overflow.visible,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 130,
                    width: double.infinity,
                    child: _payments.length > 0
                        ? SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _payments
                                  .map((e) => Material(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                        elevation: 3.0,
                                        child: SizedBox(
                                          width: 130,
                                          child: Stack(
                                            children: [
                                              ListTile(
                                                title: Text(e.method),
                                                subtitle: Text(
                                                  'R\$ ${e.value.toStringAsFixed(2)}',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Positioned(
                                                right: 5,
                                                top: 5,
                                                child: InkWell(
                                                  child: Icon(Icons.close,
                                                      size: 20),
                                                  onTap: () =>
                                                      removePayment(e.method),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )
                        : Text('Aguardando pagamento'),
                  ),
                  Positioned(
                    bottom: -30,
                    right: 30,
                    child: CircleAvatar(
                      radius: 35,
                      child: Text(pagamentoRecebido().toStringAsFixed(2)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: _space),
              CheckboxListTile(
                value: _checkSaleBySite,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('Venda pelo Site?'),
                onChanged: (value) => setState(() {
                  _checkSaleBySite = value;
                }),
              ),
              CheckboxListTile(
                value: _checkDelivery,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('É entrega?'),
                onChanged: (value) => setState(() {
                  _checkDelivery = value;
                }),
              ),
              Divider(height: 32, thickness: 4),
              Text(
                'Dados do Cliente',
                style: Theme.of(context).textTheme.headline6,
              ),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                onEditingComplete: () => _phoneFocus.requestFocus(),
                validator: (_) => validateWithSize(
                    'Nome e Sobrenome', _nameController.text.trim(), 2),
                decoration: InputDecoration(
                  labelText: "Nome e Sobrenome",
                ),
              ),
              SizedBox(height: _space),
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                inputFormatters: [_phoneMaskFormatter],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Celular",
                ),
              ),
              SizedBox(height: _space),
              TextFormField(
                controller: _observationController,
                focusNode: _observationFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Observação",
                ),
              ),
              SizedBox(height: _space * 2),
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
                    child: isSaving
                        ? Center(child: CircularProgressIndicator())
                        : RaisedButton.icon(
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
      ),
    );
  }
}
