import 'package:testing_flutter/store.dart' as store;
import 'package:flutter/material.dart';
import 'package:testing_flutter/store.dart';

class Cart extends StatelessWidget {
  final List<store.Products> listItemCart; 
  final VoidCallback onConfirmBuy;
  final VoidCallback onCancelBuy;

  Cart({
   Key key,
   @required this.listItemCart,
   @required this.onConfirmBuy, 
   @required this.onCancelBuy
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding:false ,
        appBar: AppBar(
          title: Text("Online Store - Cart"),
        ),
        body: Builder(
          builder: (context) => Container(
            child: Center(
              child: ListView(
                children: <Widget>[
                  Column(
                    children: listItemCart.map((product) => card(product, context)).toList()
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      SizedBox(width: 150),
                      RaisedButton(
                        child: Text("Cancel"),
                        onPressed: (){
                          onCancelBuy;
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Store()),
                        );
                        }
                      ),
                      SizedBox(width: 30),
                      RaisedButton(
                        child: Text("Buy"),
                        onPressed: (){
                          onConfirmBuy;
                          AlertDialog alert = AlertDialog(
                            title: Text("Notification"),
                            content: Text("Thank you for shopping in our store"),
                          );

                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                            );
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Store()),
                        );
                      }
                      )
                    ],
                  )
                ],
              )),
          ),
        ),
      ),
    );
  }
  
  Widget card(store.Products prod, BuildContext context) {
    return 
    Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(prod.productName),
              subtitle: Text(prod.description),
              trailing: 
                  Container(
                    child: Text("Rp." + (prod.price*prod.countCart).toString(), style: TextStyle(color: Colors.redAccent, fontSize: 25)),
                  ),  
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10),
                Text('Qty: ' + prod.countCart.toString()),
              ],
            )
          ],
        ),
      )
    );
  }
}
