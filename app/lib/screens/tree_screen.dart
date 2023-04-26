import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _db = FirebaseFirestore.instance;

class MemberWidget extends StatelessWidget {
  final String name;
  final userId;
  final treeId;
  final memberId;

  void deleteMember(String memberId) async {
    // Delete the member from the database
    final uid = userId;
    final membersCollection = _db
        .collection('users')
        .doc(uid)
        .collection('trees')
        .doc(treeId)
        .collection('members');
    await membersCollection.doc(memberId).delete();
  }

  MemberWidget({
    required this.name,
    required this.userId,
    required this.treeId,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        deleteMember(memberId);
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm'),
              content: Text('Are you sure you wish to delete this item?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('CANCEL')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('DELETE'),
                ),
              ],
            );
          },
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(name.substring(0, 1).toUpperCase()),
          ),
          title: Text(name),
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
  void addFamilyMember(String name, String occupation, String? photo, DateTime birthDate, String gender) async {
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
      'photo': photo,
      'birthDate': birthDate,
    });
  }
  /*
  Widget chooseList() {
    if (familyMembers.isEmpty) {
      return Center(
        child: Text(
          'No family members yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: familyMembers.length,
          itemBuilder: (context, index) {
            final member = familyMembers[index];
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Are you sure you want to delete this member?'),
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
              onDismissed: (direction) {
                setState(() {
                  familyMembers.removeAt(index);
                });
              },
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(member.photo ?? ''),
                  ),
                  title: Text(
                    member.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Date of Birth: ${DateFormat.yMMMd().format(member.dateOfBirth)}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gender: ${member.gender}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Occupation: ${member.occupation}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
*/
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treeName),
      ),
      // body: chooseList(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').doc(widget.userId).collection('trees').doc(widget.treeId).collection('members').snapshots(),
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
              child: Text('No members found. Try adding one!',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final member = documents[index];
              return MemberWidget(
                name: member['name'],
                userId: widget.userId,
                treeId: widget.treeId,
                memberId: member.id,
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
                /* actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ], */
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
                value: _gender?.isNotEmpty == true ? _gender : null,
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
