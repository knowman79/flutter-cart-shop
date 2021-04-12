import 'package:testing_flutter/cart.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'dart:io';


main() => runApp(Store());

class Store extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Store();
  }
}

class Products {
  String productName;
  String productCode;
  int productStock;
  String description;
  double price;
  int countCart;
  Products({this.productName, this.productCode, this.productStock, this.description, this.price, this.countCart});
}

class _Store extends State<Store> {
  String _path;
  var countController = new TextEditingController();
  List<Products> products = new List<Products>();
  List<Products> listItemCart = new List<Products>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: 
          Builder( builder: (context) =>  
              FloatingActionButton(
                onPressed: () { 
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(
                            listItemCart: this.listItemCart, 
                            onConfirmBuy: this._onConfirmBuy, 
                            onCancelBuy: this._onCancelBuy
                          ),
                        ),
                      );
                    },
                tooltip: 'Cart',
                child: const Icon(Icons.store),
              ),
          ),
        resizeToAvoidBottomPadding:false ,
        appBar: AppBar(
          title: Text("Online Store - Example Case"),
        ),
        body: Builder(
          builder: (context) => Container(
            child: Center(
              child: ListView(
                children: <Widget>[
                  
                  // Button untuk memilih file excell
                  new Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new RaisedButton(
                      onPressed: () => _openFileExplorer(),
                      child: new Text("Import Data Product"),
                    ),
                  ),
                  
                  // List product yang didapatkan dari data excell 
                  Column(
                    children: products.map((product) => cardTemplate(product, context)).toList()
                  ),
                  // RaisedButton.icon(
                  //   icon: Icon(Icons.store),
                  //   label: Text("Cart"),
                  //   onPressed: () { Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => Cart(
                  //           listItemCart: this.listItemCart, 
                  //           onConfirmBuy: this._onConfirmBuy, 
                  //           onCancelBuy: this._onCancelBuy
                  //         ),
                  //       ),
                  //     );
                  //   }
                  // )
                ],
              )),
          ),
        ),
      ),
    );
  }
  

  void _openFileExplorer() async {
      try {
          _path = await FilePicker.getFilePath(
              type: FileType.custom, 
              allowedExtensions: ['.xls', 'xlsx']
            );
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;

      var bytes = File(_path).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Products> listProduct = new List<Products>();
      
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table].rows) {
          Products prod = new Products();
          if (row.indexOf('Product_Name') == -1) {
            prod.productName = row[0].toString();
            prod.productCode = row[1].toString();
            prod.productStock = int.parse(row[2]);
            prod.description = row[3].toString();
            prod.price = double.parse(row[4]);
            bool exist = false;
            if (listProduct.length > 0) {
              listProduct.forEach((items) => {
                if (items.productCode == prod.productCode) {
                  items.productStock = items.productStock + prod.productStock,
                  exist = true
                } else {
                  exist = false
                }
              });
            }
            if (exist == false ) {
              listProduct.add(prod);
            }
          }
        }
      }      
      setState(() {
        products = listProduct;
      });
  }

  Widget cardTemplate(Products prod, BuildContext context) {
    return 
    Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: Text(prod.productCode, style: TextStyle(color: Colors.blue, fontSize: 15),),
              title: Text(prod.productName),
              subtitle: Text(prod.description),
              trailing: 
                Column(children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _onOpenDrawer(context, prod),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 8),
                Text('Stock: ' + prod.productStock.toString()),
                const SizedBox(width: 8),
                Text('Price: Rp.' + prod.price.toString()),
              ],
            )
          ],
        ),
      )
    );
  }

  void _onOpenDrawer(BuildContext context, Products product) {
    this.countController.text = '0';
    showModalBottomSheet(context: context, builder: (context){
      return Column(
        children: <Widget>[
          ListTile(
              title: Text(product.productName, style: TextStyle(color: Colors.blue, fontSize: 25),),
              subtitle: Row(children: [
                  Container(
                    child: Text("Stock: " + product.productStock.toString()),
                  ),
              ]),
              trailing: 
                  Container(
                    child: Text("Rp." + product.price.toString(), style: TextStyle(color: Colors.redAccent, fontSize: 25)),
                  ),                       
          ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.do_disturb_on_outlined),
                      onPressed: () => {
                        if (int.parse(countController.text) > 0)
                          countController.text = (int.parse(countController.text) - 1).toString()
                      },
                    ),
                    Container(
                      width: 40, // do it in both Container
                      child: TextField(
                        readOnly: true,
                        controller: countController,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.control_point),
                      onPressed: () => {
                        if (int.parse(countController.text) < product.productStock)
                        countController.text = (int.parse(countController.text) + 1).toString()
                      },
                    ),                    
                  ]
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                SizedBox(height: 230),
                new RaisedButton(
                  child: Text("Submit"),
                  color: Colors.blue,
                  onPressed: () {
                    Products temp = new Products();
                    temp = product;
                    temp.countCart = int.parse(countController.text);
                    this.listItemCart.add(temp);
                    Navigator.pop(context);
                  },
                )
              ],
            )
          ],
      );
    }); 
  }

  void _onConfirmBuy() {
    this.products.forEach((items) => {
      this.listItemCart.forEach((cart) => {
        if (cart.productCode == items.productCode) {
          items.productStock = items.productStock - cart.countCart
        }
      })
    });
    this.setState(() {
          products = this.products;
        });
  }

  void _onCancelBuy() {
    this.listItemCart.clear();
  }
}