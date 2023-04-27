import 'package:GenealogyGuru/screens/tree_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Settings',
];

final FirebaseFirestore _db = FirebaseFirestore.instance;

enum Menu { itemOne, itemTwo, itemThree }

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
        icon: const Icon(Icons.person),
        offset: const Offset(0, 40),
        onSelected: (Menu item) {},
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
          const PopupMenuItem<Menu>(
            value: Menu.itemOne,
            child: Text('Account'),
          ),
          const PopupMenuItem<Menu>(
            value: Menu.itemTwo,
            child: Text('Settings'),
          ),
          PopupMenuItem<Menu>(
            onTap: () async {
              FirebaseAuth.instance.signOut();
            },
            value: Menu.itemThree,
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
                title: Text('Confirm'),
                content: Text('Are you sure you want to delete this tree?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('CANCEL'),
                  ),
                  TextButton(
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

  HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: isLargeScreen
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "GenealogyGuru",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (isLargeScreen) Expanded(child: _navBarItems())
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: _ProfileIcon()),
          )
        ],
      ),
      drawer: isLargeScreen ? null : _drawer(),
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
        onPressed: addTree,
        tooltip: 'Add Tree',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _drawer() => Drawer(
    child: ListView(
      children: _menuItems
          .map((item) => ListTile(
        onTap: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        title: Text(item),
      ))
          .toList(),
    ),
  );

  Widget _navBarItems() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _menuItems
        .map(
          (item) => InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 24.0, horizontal: 16),
          child: Text(
            item,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    )
        .toList(),
  );

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
      // Add the tree to the database
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
