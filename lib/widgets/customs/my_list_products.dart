import 'package:flutter/material.dart';
import 'package:store_control/providers/products.dart';

class MyListProducts extends StatefulWidget {
  final Products products;
  final bool isLoading;
  final void Function(int index) actionIndex;

  MyListProducts({
    Key key,
    this.products,
    this.isLoading,
    this.actionIndex,
  });

  @override
  _MyListProductsState createState() => _MyListProductsState();
}

class _MyListProductsState extends State<MyListProducts> {
  final _listKey = GlobalKey<AnimatedListState>();
  final scrollListController = ScrollController();

  @override
  void didUpdateWidget(MyListProducts oldWidget) {
    super.didUpdateWidget(oldWidget);
    rolar();
  }

  void rolar() async {
    if (widget.products.list.length > 3) {
      await Future.delayed(Duration(milliseconds: 100));
      await scrollListController.animateTo(
        scrollListController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(15)),
          height: 160,
          width: double.infinity,
          child: widget.isLoading
              ? Center(child: CircularProgressIndicator())
              : widget.products.list.length > 0
                  ? ListView.builder(
                      itemCount: widget.products.size(),
                      key: _listKey,
                      controller: scrollListController,
                      itemBuilder: (context, index) {
                        return _buildListTile(
                          context,
                          index,
                        );
                      },
                    )
                  : Text('Sem produtos no carrinho'),
        ),
        ListTile(
          title: Text(
              '${widget.products.list.length} Item(s)     ${widget.products.pieces()} Peça(s)'),
          trailing: Text(
            'R\$ ${widget.products.total()}',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, int index) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 1.0, right: 0.0),
      leading: Wrap(
        children: [
          InkWell(
            splashColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            onTap: () => setState(() {
              if (widget.actionIndex != null) widget.actionIndex(index);
              widget.products.addByIndex(index);
            }),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 1, color: Colors.blueGrey, spreadRadius: 1)
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
            onTap: () => setState(() {
              if (widget.actionIndex != null) widget.actionIndex(index);
              widget.products.removeByUnitAndZero(index);
            }),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 1, color: Colors.blueGrey, spreadRadius: 1)
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
          "${widget.products.list[index].category} ${widget.products.list[index].type}\n${widget.products.list[index].color} (${widget.products.list[index].size})"),
      trailing: Wrap(
        spacing: 5,
        children: [
          Text(
            "${widget.products.list[index].quantity} x R\$ ${widget.products.list[index].value.toStringAsFixed(2)}",
          ),
          InkWell(
            onTap: () {
              setState(() {
                widget.products.list.removeAt(index);
              });
            },
            child: Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
    );
  }
}
