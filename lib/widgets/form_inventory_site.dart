import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_control/api/general_request.dart';
import 'package:store_control/providers/products.dart';
import 'package:store_control/providers/security_app.dart';
import 'package:store_control/providers/static_lists.dart';
import 'package:store_control/widgets/customs/my_select_toggle_buttons.dart';
import 'package:store_control/widgets/customs/my_snackbar.dart';

class FormInventorySite extends StatefulWidget {
  @override
  _FormInventorySiteState createState() => _FormInventorySiteState();
}

class _FormInventorySiteState extends State<FormInventorySite> {
  final _categoryController = TextEditingController();
  final _sizeController = TextEditingController();
  final _productController = TextEditingController();
  final _valueController = TextEditingController();
  final _colorController = TextEditingController();

  final _scrollController = ScrollController();
  final _scrollListController = ScrollController();

  final animations = <int, Animation<double>>{};
  final _formKey = GlobalKey<FormState>();
  final _listKey = GlobalKey<AnimatedListState>();
  final _space = 15.0;

  bool _isButtonsWaitSave = false;
  bool _isButtonsWaitLoad = false;
  bool _isProductListWait = false;

  Products _products;
  List<String> _catetogies;
  List<String> _sizes;
  List<String> _prices;
  List<Map<String, dynamic>> _colors;

  String _labelScroll = 'Variações (Tamanho e Cores)';
  @override
  void initState() {
    super.initState();
    _catetogies = StaticLists.getCategories();
    _sizes = StaticLists.getSizes();
    _prices = StaticLists.getPrices();
    _colors = StaticLists.getColors();
    _products = Products();
  }

  bool validate() {
    if (_categoryController.text.isEmpty)
      MySnackBar.showSnack(context, 'INFO', 'Informe o tipo: Blusa, Body ...');
    if (_productController.text.isEmpty)
      MySnackBar.showSnack(context, 'INFO', 'Informe o nome do produto!');
    if (_valueController.text.isEmpty)
      MySnackBar.showSnack(context, 'INFO', 'Informe o valor!');
    if (_sizeController.text.isEmpty)
      MySnackBar.showSnack(context, 'INFO', 'Informe o tamanho!');

    if (_categoryController.text.isEmpty ||
        _productController.text.isEmpty ||
        _valueController.text.isEmpty ||
        _sizeController.text.isEmpty)
      return false;
    else
      return true;
  }

  Future<void> _addProduct({int index = -1}) async {
    if (!validate()) {
      return Future.value();
    }

    setState(() {
      if (index < 0) {
        var p = Product(
          category: _categoryController.text,
          size: _sizeController.text,
          type: _productController.text.trim(),
          color: _colorController.text.trim(),
          quantity: 1,
          value: double.parse(_valueController.text),
        );

        if (_products.list.length > 0 && _products.notExists(p)) {
          _listKey.currentState.insertItem(_products.list.length,
              duration: const Duration(milliseconds: 400));
        }
        _products.add(p);
      } else {
        _products.addByIndex(index);
      }
    });

    if (_products.list.length > 3 && index < 0) {
      //Foi necessário, acredito que seja para aguardar o novo item entrar.
      await Future.delayed(Duration(milliseconds: 100));
      await _scrollListController.animateTo(
        _scrollListController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  void _removeProduct(int index) {
    if (_products.list.length == 0) return;
    setState(() {
      _listKey.currentState.removeItem(
          index, (context, animation) => _buildListTile(context, 0, animation),
          duration: Duration(milliseconds: 300));
      _products.removeByIndex(index);
    });
  }

  void _removeUnit(int index) {
    setState(() {
      _products.removeByUnit(index);
      if (_products.list[index].quantity == 0) _removeProduct(index);
    });
  }

  _copyToSend() {
    if (_products.list.length == 0) {
      MySnackBar.showSnack(context, 'INFO', 'Adicione produtos para copiar!');
      return;
    }

    _products.copyDataToInventory();

    MySnackBar.showSnack(
        context, 'OK', 'Linhas copiadas para área de transferência');
  }

  Future<void> saveFirebase(String description) async {
    setState(() {
      _isButtonsWaitSave = true;
    });

    var reqs = GeneralRequests(
        securityApp: Provider.of<SecurityApp>(context, listen: false));

    await reqs
        .postRequest(
            collection: 'inventory', body: _products.getJson(description))
        .then((value) {
      if (value) {
        MySnackBar.showSnack(context, 'OK', 'Inventário foi salvo!');
      } else {
        MySnackBar.showSnack(context, 'ERRO', 'Erro ao salvar!');
      }
    });

    setState(() {
      _isButtonsWaitSave = false;
    });
  }

  Future<void> _loadInventories() async {
    if (_products.list.length > 0) {
      var follow = await buildShowDialog(context);
      if (!follow) return;
    }

    setState(() {
      _products.clear();
      _isButtonsWaitLoad = true;
    });

    var reqs = GeneralRequests(
        securityApp: Provider.of<SecurityApp>(context, listen: false));
    var list = await reqs.getRequestItems(
      collection: 'inventory',
    );

    if (list == null || list.length == 0) {
      MySnackBar.showSnack(
          context, 'INFO', 'Nenhum inventário foi encontrado!');

      setState(() {
        _isButtonsWaitLoad = false;
      });

      return Future.value();
    }

    List<ListTile> listTiles = List<ListTile>();
    list.forEach((key, value) {
      var createdAt = DateFormat('dd/MM/yyyy HH:mm')
          .format(DateTime.parse(value['createdAt']));

      listTiles.add(ListTile(
        trailing: Text(createdAt, style: TextStyle(fontSize: 13)),
        title: Text(value['description']),
        onTap: () {
          Navigator.of(context).pop(key);
        },
      ));
    });

    listTiles = List.from(listTiles.reversed);
    setState(() {
      _isButtonsWaitLoad = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: Text('Inventários Salvos\nclique para carregar'),
          content: Container(
            height: 280,
            child: SingleChildScrollView(
              child: Column(
                children: listTiles,
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop('');
              },
            ),
          ],
        );
      },
    ).then((value) async {
      if (value.toString().isNotEmpty) {
        setState(() {
          _isProductListWait = true;
        });

        var items = await reqs.getRequestItems(collection: 'inventory/$value');

        setState(() {
          _isProductListWait = false;
          _products.list = (items['products'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        });
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
                MySelectToggleButtons(
                  listString: _catetogies,
                  onPressed: (value) => _categoryController.text = value,
                ),
                TextFormField(
                  controller: _productController,
                  textCapitalization: TextCapitalization.words,
                  onTap: () => _productController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _productController.text.length),
                  decoration: InputDecoration(
                    labelText: 'Nome do Produto',
                  ),
                  validator: (_) => _products.list.length > 0
                      ? null
                      : "Adicione ao menos um item ao carrinho!",
                ),
                SizedBox(height: _space),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  onTap: () => _valueController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _valueController.text.length),
                  decoration: InputDecoration(
                    prefixText: 'R\$ ',
                    labelText: "Valor",
                  ),
                ),
                SizedBox(height: _space),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                      spacing: -12.0,
                      children: _prices
                          .map(
                            (e) => IconButton(
                              onPressed: () => _valueController.text = e,
                              iconSize: 48,
                              icon: CircleAvatar(
                                radius: 24,
                                child: Text(e, style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          )
                          .toList()),
                ),
                // SizedBox(height: _space * 2),
                Divider(height: 40, thickness: 3),
                Text(
                  _labelScroll,
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: _space),
                MySelectToggleButtons(
                  listString: _sizes,
                  onPressed: (value) {
                    _scrollController.animateTo(300,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.decelerate);
                    _sizeController.text = value;
                    setState(() {
                      _labelScroll =
                          '${_categoryController.text} ${_productController.text} (${_valueController.text})';
                    });
                  },
                ),
                SizedBox(height: _space * 2),
                Wrap(
                  spacing: -4.0,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.center,
                  children: _colors
                      .map((e) => IconButton(
                            onPressed: () {
                              _colorController.text = e['label'];
                              _addProduct();
                            },
                            iconSize: 40,
                            icon: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      color: e['color'],
                                      spreadRadius: 2)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: e['color'],
                                child:
                                    Text(e['label'].toString().substring(0, 2)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: _space),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: TextFormField(
                          controller: _colorController,
                          textCapitalization: TextCapitalization.words,
                          onTap: () => _colorController.selection =
                              TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _colorController.text.length),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Cor",
                          ),
                        ),
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      buttonPadding: EdgeInsets.all(8.0),
                      children: [
                        IconButton(
                            iconSize: 48,
                            icon: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              _addProduct();
                            }),
                      ],
                    ),
                  ],
                ),
                Divider(height: 20, thickness: 3),
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(15)),
                  height: 160,
                  width: double.infinity,
                  child: _isProductListWait
                      ? Center(child: CircularProgressIndicator())
                      : _products.list.length > 0
                          ? AnimatedList(
                              key: _listKey,
                              initialItemCount: _products.list.length,
                              controller: _scrollListController,
                              itemBuilder: (context, index, animation) {
                                return _buildListTile(
                                  context,
                                  index,
                                  animation,
                                );
                              },
                            )
                          : Text('Sem produtos no carrinho'),
                ),
                ListTile(
                  title: Text(
                      '${_products.list.length} Item(s)     ${_products.pieces()} Peça(s)'),
                  trailing: Text(
                    'R\$ ${_products.total()}',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown[900],
                    borderRadius: BorderRadius.circular(15),
                    // boxShadow: [
                    //   BoxShadow(
                    //     blurRadius: 1.0,
                    //     spreadRadius: 1.0,
                    //     color: Colors.brown[900].withOpacity(0.85),
                    //     offset: Offset(0.5, 0.5),
                    //   ),
                    // ],
                  ),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.delete, color: Colors.brown[200]),
                        tooltip: 'Limpar Itens',
                        onPressed: () => buildShowDialog(context).then((value) {
                          if (value)
                            setState(() {
                              _products.clear();
                            });
                        }),
                      ),
                      IconButton(
                          iconSize: 32,
                          tooltip: 'Excluir o último',
                          icon: Icon(Icons.cancel, color: Colors.brown[200]),
                          onPressed: () =>
                              _removeProduct(_products.list.length - 1)),
                      IconButton(
                          iconSize: 32,
                          tooltip: 'Copiar para enviar',
                          icon: Icon(Icons.cloud_download,
                              color: Colors.brown[200]),
                          onPressed: () => _copyToSend()),
                      _isButtonsWaitLoad
                          ? CircularProgressIndicator()
                          : IconButton(
                              iconSize: 32,
                              tooltip: 'Inventários Salvos',
                              icon: Icon(Icons.dashboard,
                                  color: Colors.brown[200]),
                              onPressed: () => _loadInventories()),
                      _isButtonsWaitSave
                          ? CircularProgressIndicator()
                          : IconButton(
                              iconSize: 32,
                              tooltip: 'Salvar',
                              icon: Icon(Icons.save, color: Colors.brown[200]),
                              onPressed: () {
                                if (_products.list.length == 0) {
                                  MySnackBar.showSnack(context, 'INFO',
                                      'Não há itens a serem salvos!');
                                  return Future.value();
                                }

                                final textController = TextEditingController();

                                return showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    title: Text('Salvar Inventário'),
                                    content: TextFormField(
                                      controller: textController,
                                      decoration: InputDecoration(
                                          labelText: 'Informe uma descrição'),
                                    ),
                                    actions: <Widget>[
                                      // define os botões na base do dialogo
                                      FlatButton(
                                        child: Text("Fechar"),
                                        onPressed: () {
                                          Navigator.of(context).pop('');
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("Aceitar"),
                                        onPressed: () {
                                          if (textController.text.isNotEmpty)
                                            Navigator.of(context)
                                                .pop(textController.text);
                                        },
                                      ),
                                    ],
                                  ),
                                ).then((value) {
                                  if (value.toString().isNotEmpty) {
                                    saveFirebase(value);
                                  }
                                });
                              }),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: Text('Alerta!'),
          content: Text('Deseja excluir os itens?'),
          actions: <Widget>[
            FlatButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text("Excluir todos"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListTile(
      BuildContext context, int index, Animation<double> animation) {
    // return SizeTransition( //Exemplo 1
    //   key: ValueKey<int>(index),
    //   axis: Axis.vertical,
    //   sizeFactor: animation,
    // return FadeTransition( //Exemplo 2
    //   opacity: animation,
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
            reverseCurve: Curves.decelerate),
      ),
      child: SizedBox(
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 1.0, right: 0.0),
          leading: Wrap(
            children: [
              InkWell(
                splashColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                onTap: () => _addProduct(index: index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 1,
                          color: Colors.blueGrey,
                          spreadRadius: 1)
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    child: Icon(
                      Icons.expand_less,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _removeUnit(index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 1,
                          color: Colors.blueGrey,
                          spreadRadius: 1)
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    child: Icon(
                      Icons.expand_more,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
              "${_products.list[index].category} ${_products.list[index].type}\n${_products.list[index].color} (${_products.list[index].size})"),
          trailing: Wrap(
            spacing: 5,
            children: [
              Text(
                "${_products.list[index].quantity} x R\$ ${_products.list[index].value.toStringAsFixed(2)}",
              ),
              InkWell(
                onTap: () => _removeProduct(index),
                child: Icon(
                  Icons.delete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
