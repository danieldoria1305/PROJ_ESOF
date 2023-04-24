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


  /*
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
  } */

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

/*
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
}*/