import 'dart:core';
import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Palette {
  static MaterialColor customGreen = MaterialColor(const Color.fromRGBO(22, 166, 55, 1).value, const <int, Color>{
      50: Color.fromRGBO(22, 166, 55, 0.1),
      100: Color.fromRGBO(22, 166, 55, 0.2),
      200: Color.fromRGBO(22, 166, 55, 0.3),
      300: Color.fromRGBO(22, 166, 55, 0.4),
      400: Color.fromRGBO(22, 166, 55, 0.5),
      500: Color.fromRGBO(22, 166, 55, 0.6),
      600: Color.fromRGBO(22, 166, 55, 0.7),
      700: Color.fromRGBO(22, 166, 55, 0.8),
      800: Color.fromRGBO(22, 166, 55, 0.9),
      900: Color.fromRGBO(22, 166, 55, 1)
    },
  );
}

class TreeWidget extends StatelessWidget {
  final String treeName;

  const TreeWidget({Key? key, required this.treeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(treeName),
          const Icon(Icons.star),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Palette.customGreen,
      ),
      home: const MyHomePage(title: 'GenealogyGuru'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> noTrees = [
      const Text(
      'No trees found. Try creating one!',
        style: TextStyle(
          fontFamily: "Times New Roman",
          fontSize: 24,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      const SizedBox(
        height: 100,
      ),
  ];
  int _counter = 0;

  List<Widget> myTrees = [];

  late TextEditingController controller;
  String name='';

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  List<Widget> chooseList() {
    if (myTrees.isEmpty) return noTrees;
    return myTrees;
  }

  /*
  void _addTree() {
    if ( _counter < 5 ) {
      setState(() {
        Widget treeWidget = Container(
          width: 300,
          height: 67,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                'Family Tree ${myTrees.length + 1}',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Times New Roman",
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Spacer(),
            const Icon(Icons.star_border),
          ],
        ),
        );
        myTrees.add(treeWidget);

        _counter++;
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot add more than 5 trees.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } */

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created...
        title: Text(widget.title),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chooseList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                onPressed: () async {
                  final name = await openDialog();
                  if (name == null || name.isEmpty) return;

                  setState(() {
                    myTrees.add(TreeWidget(treeName: name));

                  });
                },
                tooltip: 'Add Tree',
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Create new Tree'),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(hintText: 'Tree Name'),
        controller: controller,
      ),
      actions: [
        TextButton(
          child: Text('Create'),
          onPressed: submit,

        )
      ],
    ),
  );

  void submit() {
    Navigator.of(context).pop(controller.text);

    controller.clear();
  }


/* @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style:
        TextStyle(
            fontFamily: "Times New Roman",
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        // Set the padding to move the list of widgets up
        padding: EdgeInsets.only(top: 75),
        children: [
          Center(
            child: Column(
              children: chooseList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 75.0),
        child: FloatingActionButton(
          tooltip: 'Create a new tree',
          onPressed: _addTree,
          elevation: 1,
          child: Icon(Icons.add),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  } */


}

