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

  String? _firstName;
  String? _lastName;
  DateTime _birthDate = DateTime.now();
  String? _gender;
  String? _nationality;

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
          _firstName = memberDoc['firstName'];
          _lastName = memberDoc['lastName'];
          _birthDate = memberDoc['birthDate'].toDate();
          _gender = memberDoc['gender'];
          _nationality = memberDoc['nationality'];
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
          'firstName': _firstName,
          'lastName': _lastName,
          'birthDate': _birthDate,
          'gender': _gender,
          'nationality': _nationality,
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
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _firstName,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value ?? '',
                onChanged: (value) {
                  setState(() {
                    _firstName = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _lastName,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value ?? '',
                onChanged: (value) {
                  setState(() {
                    _lastName = value;
                  });
                },
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
                  DropdownMenuItem<String>(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Non-binary',
                    child: Text('Non-binary'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value ?? '';
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _nationality,
                decoration: InputDecoration(
                  labelText: 'Nationality',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nationality';
                  }
                  return null;
                },
                onSaved: (value) => _nationality = value ?? '',
                onChanged: (value) {
                  setState(() {
                    _nationality = value;
                  });
                },
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
