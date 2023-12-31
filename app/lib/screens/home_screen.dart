import 'package:GenealogyGuru/screens/tree_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_screen.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

enum Menu { itemOne, itemTwo}

class _ProfileIcon extends StatelessWidget {
  final String userId;
  const _ProfileIcon({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
        icon: const Icon(Icons.person),
        offset: const Offset(0, 40),
        onSelected: (Menu item) {},
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
          PopupMenuItem<Menu>(
            value: Menu.itemOne,
            child: GestureDetector(
                key: Key("AccountButton"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountScreen(userId: userId)),
                  );
                },
                child: Text('Account')
            ),
          ),
          PopupMenuItem<Menu>(
            key: Key("SignOutButton"),
            onTap: () async {
              FirebaseAuth.instance.signOut();
            },
            value: Menu.itemTwo,
            child: Text('Sign Out'),
          ),
        ]);
  }
}

class TreeWidget extends StatelessWidget {
  final String treeName;
  final userId;
  final treeId;

  void deleteTree(String treeId) async {
    final uid = userId;
    final treesCollection = _db
        .collection('users')
        .doc(uid)
        .collection('trees');
    await treesCollection.doc(treeId).delete();
  }

  const TreeWidget({Key? key, required this.treeName, required this.userId, required this.treeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TreeScreen(treeName: treeName, userId: userId, treeId: treeId)),
        );
      },
      child: Dismissible(
        onDismissed: (direction) {
          deleteTree(treeId);
        },
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                key: Key("DeleteTreeDialog"),
                title: Text('Confirm'),
                content: Text('Are you sure you want to delete this tree?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('CANCEL'),
                  ),
                  TextButton(
                    key: Key("DeleteTreeDialogButton"),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('DELETE'),
                  ),
                ],
              );
            },
          );
        },
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: const Icon(
              Icons.people_alt_outlined,
              size: 40,
            ),
            title: Text(
              treeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: const Text(
              'Family Tree',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  final user = FirebaseAuth.instance.currentUser;
  final String title;
  Key key = Key('HomeScreen');

  HomeScreen({required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: Text(""),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "GenealogyGuru",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
                child: _ProfileIcon(
                  key: Key("ProfileIcon"),
                  userId: widget.user!.uid,
                )
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').doc(widget.user?.uid).collection('trees').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return Center(
                child: Text('No trees found. Try creating one!',
                style: TextStyle(
                    fontSize: 24,
                ),
                ),
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final tree = documents[index];
              return TreeWidget(
                treeName: tree['name'],
                userId: widget.user!.uid,
                treeId: tree.id,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('CreateTreeButton'),
        onPressed: addTree,
        tooltip: 'Create New Tree',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  late TextEditingController controller;
  String name = '';

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addTree() async {
    final name = await openDialog();
    if (name != null) {
      final uid = widget.user!.uid;
      final treesCollection = _db
          .collection('users')
          .doc(uid)
          .collection('trees');
      await treesCollection.doc().set({'name': name});
    }
  }

  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          key: Key('CreateTreeDialog'),
          title: Text('Create new Tree'),
          content: TextField(
            key: Key('TreeNameField'),
            autofocus: true,
            decoration: InputDecoration(hintText: 'Insert tree name'),
            controller: controller,
          ),
          actions: [
            TextButton(
              key: Key('CreateTreeDialogButton'),
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
