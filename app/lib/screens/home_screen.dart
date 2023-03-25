import 'package:app/screens/tree_screen.dart';
import 'package:flutter/material.dart';

class TreeWidget extends StatelessWidget {
  final String treeName;

  const TreeWidget({Key? key, required this.treeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TreeScreen(treeName: treeName)),
        );
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
        child: ListTile(
          trailing: Icon(Icons.star_border_outlined, color: Colors.amber[400]),
          title: Text(treeName),
        ),
      ),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    /*
    return Container(
      padding: EdgeInsets.fromLTRB(65, 0, 65, 0),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(treeName),
          const Icon(Icons.star),
        ],
      ),
    );*/
    return Card(
      margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: ListTile(
        trailing: Icon(Icons.star_border_outlined,
            color: Colors.amber[400]
        ),
        title: Text(treeName),
      ),
    );
  } */
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    if (trees.isEmpty) return Container(
      child: noTrees,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: trees,
      ),
    );
  }

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

      body: chooseList(),

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