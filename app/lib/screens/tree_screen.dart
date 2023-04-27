import 'dart:ui';

import 'package:GenealogyGuru/screens/edit_member_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _db = FirebaseFirestore.instance;

class MemberWidget extends StatelessWidget {
  final String name;
  final String userId;
  final String treeId;
  final String memberId;
  final DateTime birthDate;
  final String gender;
  final String photoUrl;

  const MemberWidget({
    required this.name,
    required this.userId,
    required this.treeId,
    required this.memberId,
    required this.birthDate,
    required this.gender,
    this.photoUrl = '',
  });

  void _deleteMember(BuildContext context) async {
    try {
      final membersCollection = _db
          .collection('users')
          .doc(userId)
          .collection('trees')
          .doc(treeId)
          .collection('members');
      await membersCollection.doc(memberId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete member: $e'),
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Are you sure you wish to delete this item?'),
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
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(memberId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteMember(context),
      confirmDismiss: (direction) => _showDeleteConfirmationDialog(context),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
          ),
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4.0),
              Text(
                'Gender: $gender',
                style: TextStyle(fontSize: 12.0),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Birth Date: ${DateFormat('yyyy-MM-dd').format(birthDate)}',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditMemberScreen(memberId: memberId, userId: userId, treeId: treeId)),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}

class TreeScreen extends StatefulWidget {
  final String treeName;
  final treeId;
  final userId;

  const TreeScreen({Key? key, required this.treeName, required this.userId, required this.treeId}) : super(key: key);

  @override
  _TreeScreenState createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  late Stream<QuerySnapshot> _membersStream;

  @override
  void initState() {
    super.initState();
    _membersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('trees')
        .doc(widget.treeId)
        .collection('members')
        .snapshots();
  }

  void addFamilyMember(String name, String occupation, String? photoUrl, DateTime birthDate, String gender) async {
    final uid = widget.userId;
    final membersCollection = _db
        .collection('users')
        .doc(uid)
        .collection('trees')
        .doc(widget.treeId)
        .collection('members');
    await membersCollection.doc().set({
      'name': name,
      'gender': gender,
      'occupation': occupation,
      'photoUrl': photoUrl,
      'birthDate': birthDate,
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treeName),
      ),
      // body: chooseList(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _membersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final List<DocumentSnapshot> members = snapshot.data!.docs;
          if (members.isEmpty) {
            return Center(
              child: Text('No family members yet!',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (BuildContext context, int index) {
              final member = members[index];
              return MemberWidget(
                name: member['name'],
                userId: widget.userId,
                treeId: widget.treeId,
                memberId: member.id,
                gender: member['gender'],
                birthDate: member['birthDate'].toDate(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: AddMemberForm(onSubmit: addFamilyMember),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMemberForm extends StatefulWidget {
  final Function(String, String, String?, DateTime, String) onSubmit;

  AddMemberForm({required this.onSubmit});

  @override
  _AddMemberFormState createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();

  String? _photo;
  String _name = "";
  DateTime _dateOfBirth = DateTime.now();
  DateTime? _dateOfDeath;
  String _gender = "";
  String _occupation = "";

  void _submitForm() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(
        _name,
        _occupation,
        _photo,
        _dateOfBirth,
        //dateOfDeath: _dateOfDeath,
        _gender,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date of birth';
                  }
                  return null;
                },
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dateOfBirth = date;
                    });
                  }
                },
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat.yMMMMd().format(_dateOfBirth),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Male',
                  'Female',
                  'Non-binary',
                  'Other',
                ]
                    .map(
                      (gender) =>
                      DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ),
                )
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => _gender = value!),
                value: _gender.isNotEmpty == true ? _gender : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an occupation';
                  }
                  return null;
                },
                onSaved: (value) => _occupation = value!,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  'Add Member',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}
