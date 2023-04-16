import 'package:GenealogyGuru/screens/tree_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TreeWidget extends StatelessWidget {
  final String treeName;
  final VoidCallback onDelete;

  const TreeWidget({Key? key, required this.treeName, required this.onDelete}) : super(key: key);

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
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
          title: Text(treeName),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final user = FirebaseAuth.instance.currentUser;
  final String title;

  HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static List<Widget> trees = [];

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
      child: Center(
        child: const Text(
          'No trees found. Try creating one!',
          style: TextStyle(
            fontSize: 24,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
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
        title: Text('Signed in as ${widget.user!.email}'),
        backgroundColor: Colors.brown[700],
        leading: MaterialButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: Icon(Icons.logout),
        ),
      ),

      body: chooseList(),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                backgroundColor: Colors.brown[700],
                onPressed: () async {
                  final name = await openDialog();
                  if (name == null || name.isEmpty) return;

                  setState(() {
                    trees.add(TreeWidget(
                        treeName: name,
                    onDelete: () {
                      setState(() {
                        trees.removeWhere((widget) => widget is TreeWidget && widget.treeName == name);
                      });
                    }),
                    );
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