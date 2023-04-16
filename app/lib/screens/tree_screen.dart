import 'package:flutter/material.dart';
import 'package:GenealogyGuru/model/tree_member.dart';
import 'package:intl/intl.dart';

class TreeScreen extends StatefulWidget {
  final String treeName;

  const TreeScreen({Key? key, required this.treeName}) : super(key: key);

  @override
  _TreeScreenState createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  List<FamilyMember> familyMembers = [];

  void addFamilyMember(FamilyMember member) {
    setState(() {
      familyMembers.add(member);
    });
  }

  Widget chooseList() {
    if (familyMembers.isEmpty) {
      return
        Center(
          child: Text('No family members yet!',
            style: TextStyle(fontSize: 24)
            ),
          );
    } else {

      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: familyMembers.map((member) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(member.photo ?? ''),
                ),
                title: Text(member.name,
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                subtitle: Text(DateFormat.yMMMd().format(member.dateOfBirth)),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      familyMembers.remove(member);
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treeName),
      ),
      body: chooseList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: AddMemberForm(onSubmit: addFamilyMember),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
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
  final Function(FamilyMember) onSubmit;

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
      widget.onSubmit(FamilyMember(
        photo: _photo,
        name: _name,
        dateOfBirth: _dateOfBirth,
        //dateOfDeath: _dateOfDeath,
        gender: _gender,
        occupation: _occupation,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Date of Birth'),
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
                  text: DateFormat.yMMMMd().format(_dateOfBirth)),
            ),
            /*TextFormField(
              decoration: InputDecoration(labelText: 'Date of Death'),
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: _dateOfDeath ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _dateOfDeath = date;
                  });
                }
              },
              readOnly: true,
              controller: TextEditingController(
                  text: _dateOfDeath != null
                      ? DateFormat.yMMMMd().format(_dateOfDeath!)
                      : ""),
            ),*/
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female', 'Non-binary', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
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
            TextFormField(
              decoration: InputDecoration(labelText: 'Occupation'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an occupation';
                }
                return null;
              },
              onSaved: (value) => _occupation = value!,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
