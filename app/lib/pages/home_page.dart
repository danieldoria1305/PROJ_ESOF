import 'dart:core';
import 'package:flutter/material.dart';

class TreeWidget extends StatelessWidget {
  final String treeName;

  const TreeWidget({Key? key, required this.treeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: ListTile(
        trailing: Icon(Icons.star_border_outlined,
            color: Colors.amber[400]
        ),
        title: Text(treeName),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget noTrees =
  Center(
    child: const Text(
      'No trees found. Try creating one!',
      style: TextStyle(
        fontFamily: "Times New Roman",
        fontSize: 24,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
  );

  List<Widget> trees = [];

  late TextEditingController controller;
  String name = '';

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

  Widget chooseList() {
    if (trees.isEmpty) {
      return Container(
        child: noTrees,
      );
    }
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: trees,
      ),
    );
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
        title: Center(
            child: Text(widget.title)
        ),
      ),

      body: chooseList(),
      /*
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chooseList(),
          ),
        ),
      ),*/
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
                    trees.add(TreeWidget(treeName: name));

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
        decoration: InputDecoration(hintText: 'Insert tree name'),
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

}

