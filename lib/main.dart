import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqlite_database/Item.dart';
import 'package:sqlite_database/DatabaseHelper.dart';

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbhelper = DatabaseHelper.instance;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  List<Item> items = <Item>[];

  @override
  void initState() {
    super.initState();
    _qurey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("SQLite DataBase"),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            namecontroller = TextEditingController();
            numbercontroller = TextEditingController();
            insertdailog(context);
          },
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: ProductBox(item: items[index]),
                onTap: () {
                  namecontroller.text = items[index].name;
                  numbercontroller.text = items[index].number;
                  updatedailog(context, items[index].id, index);
                });
          },
        ));
  }

  Future insertdailog(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Insert Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(
                keyboardType: TextInputType.text,
                controller: namecontroller,
                decoration: const InputDecoration(hintText: "Enter Name"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: numbercontroller,
                decoration: const InputDecoration(hintText: "Enter Number"),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _insert(namecontroller.text, numbercontroller.text);
                  });
                  Navigator.pop(context);
                },
                child: const Text("ADD"))
          ],
        ),
      );

  Future updatedailog(BuildContext context, int id, int index) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("update Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(
                keyboardType: TextInputType.text,
                controller: namecontroller,
                decoration: const InputDecoration(hintText: "Enter Name"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: numbercontroller,
                decoration: const InputDecoration(hintText: "Enter Number"),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Item item =
                      Item(namecontroller.text, numbercontroller.text, id);
                  items.removeAt(index);
                  setState(() => items.insert(index, item));
                  _update(namecontroller.text, numbercontroller.text, id);
                  Navigator.pop(context);
                },
                child: const Text("UPDATE")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deletedialog(context, index, id);
                },
                child: const Text("DELETE"))
          ],
        ),
      );

  Future deletedialog(BuildContext context, int index, int id) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Delete Data'),
            content: const Text("Are Sure Delete This Data?"),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      items.removeAt(index);
                    });
                    _delete(id);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(onPressed: () {}, child: const Text("No"))
            ],
          ));

  // Insert Data
  void _insert(String name, String number) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnNumber: number,
    };

    final id = await dbhelper.insert(row);
    Item item = Item(name, number, id);
    setState(() {
      items.add(item);
    });

    Fluttertoast.showToast(
      msg: 'Insert Success',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  // Displayed Data
  void _qurey() async {
    items = <Item>[];
    final allRows = await dbhelper.queryAllRows();
    for (var item in allRows) {
      var item1 = Item(item['_name'], item['_number'], item['_id']);

      setState(() {
        items.add(item1);
      });
    }
  }

  // Update Data
  void _update(String name, String number, int id) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnNumber: number,
      DatabaseHelper.columnId: id,
    };
    dbhelper.update(row);
  }

  // Delete Data
  void _delete(int id) {
    dbhelper.delete(id);
  }
}

class ProductBox extends StatelessWidget {
  const ProductBox({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(2),
        child: Card(
          child: Row(
            children: [
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      item.name,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(item.number,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.end),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
