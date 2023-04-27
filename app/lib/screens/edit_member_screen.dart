import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _db = FirebaseFirestore.instance;

class EditMemberScreen extends StatefulWidget {
  final String userId;
  final String treeId;
  final String memberId;

  const EditMemberScreen({
    required this.userId,
    required this.treeId,
    required this.memberId,
  });

  @override
  _EditMemberScreenState createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  DateTime _birthDate = DateTime.now();
  String _gender = '';
  String _occupation = '';

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  void _fetchMemberData() async {
    try {
      final memberDoc = await _db
          .collection('users')
          .doc(widget.userId)
          .collection('trees')
          .doc(widget.treeId)
          .collection('members')
          .doc(widget.memberId)
          .get();

      if (memberDoc.exists) {
        setState(() {
          _name = memberDoc['name'];
          _birthDate = memberDoc['birthDate'].toDate();
          _gender = memberDoc['gender'];
          _occupation = memberDoc['occupation'];
        });
      }
    } catch (e) {
      print('Error fetching member data: $e');
    }
  }

  void _updateMemberData() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        final memberRef = _db
            .collection('users')
            .doc(widget.userId)
            .collection('trees')
            .doc(widget.treeId)
            .collection('members')
            .doc(widget.memberId);

        await memberRef.update({
          'name': _name,
          'birthDate': _birthDate,
          'gender': _gender,
          'occupation': _occupation,
        });

        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating member data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Member'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
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
                onSaved: (value) => _name = value ?? '',
              ),
              SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_birthDate),
                ),
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _birthDate = date;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _gender,
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
                      (gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _occupation,
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a occupation';
                  }
                  return null;
                },
                onSaved: (value) => _occupation = value ?? '',
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _updateMemberData,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.0),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
