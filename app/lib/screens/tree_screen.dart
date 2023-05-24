import 'dart:ui';
import 'dart:io';
import 'package:GenealogyGuru/screens/tree_statistics_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GenealogyGuru/screens/edit_member_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _db = FirebaseFirestore.instance;

class MemberWidget extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userId;
  final String treeId;
  final String memberId;
  final DateTime birthDate;
  final String gender;
  final String? photoUrl;
  final void Function(String) onDeleteMember;
  final Key key = Key('MemberWidget');

  MemberWidget({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.treeId,
    required this.memberId,
    required this.birthDate,
    required this.gender,
    this.photoUrl = '',
    required this.onDeleteMember,
  });

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: Key('DeleteMemberDialog'),
        title: Text('Confirm'),
        content: Text('Are you sure you wish to delete this item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            key: Key("DeleteMemberDialogButton"),
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
      onDismissed: (direction) => onDeleteMember(memberId),
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
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          ),
          title: Text(
            firstName + ' ' + lastName,
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
                    builder: (context) => EditMemberScreen(
                        memberId: memberId, userId: userId, treeId: treeId)),
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
  final Key key = Key('TreeScreen');

  TreeScreen(
      {Key? key,
      required this.treeName,
      required this.userId,
      required this.treeId})
      : super(key: key);

  @override
  _TreeScreenState createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  late Stream<QuerySnapshot> _membersStream;
  String _selectedNationality = '';
  String _selectedGender = '';
  String _selectedLastName = '';

  @override
  void initState() {
    super.initState();
    _membersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('trees')
        .doc(widget.treeId)
        .collection('members')
        .where('gender',
            isEqualTo: _selectedGender.isNotEmpty ? _selectedGender : null)
        .where('lastName',
            isEqualTo: _selectedLastName.isNotEmpty ? _selectedLastName : null)
        .snapshots();
  }

  void _setSelectedNationality(String? nationality) {
    setState(() {
      _selectedNationality = nationality!;
    });
  }

  void addFamilyMember(String firstName, String lastName, String nationality,
      DateTime birthDate, String gender, XFile? photo) async {
    final uid = widget.userId;
    final membersCollection = _db
        .collection('users')
        .doc(uid)
        .collection('trees')
        .doc(widget.treeId)
        .collection('members');

    String? uploadedPhotoUrl;
    if (photo != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('members')
          .child('$uid-${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(File(photo.path));
      final snapshot = await uploadTask.whenComplete(() {});
      uploadedPhotoUrl = await snapshot.ref.getDownloadURL();
    }

    await membersCollection.doc().set({
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'nationality': nationality,
      'photoUrl': uploadedPhotoUrl,
      'birthDate': birthDate,
    });
    _updateFilterOptions();
  }

  void _deleteMember(String memberId) async {
    try {
      final membersCollection = _db
          .collection('users')
          .doc(widget.userId)
          .collection('trees')
          .doc(widget.treeId)
          .collection('members');

      final memberDoc = await membersCollection.doc(memberId).get();
      final memberData = memberDoc.data();
      final photoUrl = memberData?['photoUrl'] as String?;

      await membersCollection.doc(memberId).delete();

      if (photoUrl != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(photoUrl);
        await storageRef.delete();
      }

      _updateFilterOptions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete member: $e'),
        ),
      );
    }
  }

  void _updateFilterOptions() {
    setState(() {});
  }

  Future<List<String>> fetchNationalities() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('trees')
          .doc(widget.treeId)
          .collection('members')
          .get();
      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final Set<String> uniqueNationalities = Set<String>();
      for (var doc in documents) {
        final nationality = doc['nationality'];
        if (nationality != null && nationality is String) {
          uniqueNationalities.add(nationality);
        }
      }

      return uniqueNationalities.toList();
    } catch (e) {
      print('Error fetching nationalities: $e');
      return [];
    }
  }

  Future<List<String>> fetchLastNames() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('trees')
          .doc(widget.treeId)
          .collection('members')
          .get();
      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final Set<String> uniqueLastNames = Set<String>();
      for (var doc in documents) {
        final lastName = doc['lastName'];
        if (lastName != null && lastName is String) {
          uniqueLastNames.add(lastName);
        }
      }

      return uniqueLastNames.toList();
    } catch (e) {
      print('Error fetching last names: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treeName),
        actions: [
          IconButton(
            key: Key('TreeStatisticsButton'),
            tooltip: 'Tree Statistics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TreeStatisticsScreen(
                    treeId: widget.treeId,
                    userId: widget.userId,
                  ),
                ),
              );
            },
            icon: Icon(Icons.bar_chart),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: 106,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        key: Key('GenderFilterDropdown'),
                        value: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                            _membersStream = FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userId)
                                .collection('trees')
                                .doc(widget.treeId)
                                .collection('members')
                                .where('gender',
                                    isEqualTo: _selectedGender.isNotEmpty
                                        ? _selectedGender
                                        : null)
                                .where('lastName',
                                    isEqualTo: _selectedLastName.isNotEmpty
                                        ? _selectedLastName
                                        : null)
                                .snapshots();
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text('All Genders'),
                          ),
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
                        decoration: InputDecoration(
                          hintText: 'Filter by Gender',
                        ),
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 100,
                  child: Column(
                    children: [
                      FutureBuilder<List<String>>(
                        future: fetchLastNames(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final List<String> lastNames = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            key: Key('LastNameFilterDropdown'),
                            value: _selectedLastName,
                            onChanged: (value) {
                              setState(() {
                                _selectedLastName = value!;
                                _membersStream = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.userId)
                                    .collection('trees')
                                    .doc(widget.treeId)
                                    .collection('members')
                                    .where('gender',
                                        isEqualTo: _selectedGender.isNotEmpty
                                            ? _selectedGender
                                            : null)
                                    .where('lastName',
                                        isEqualTo: _selectedLastName.isNotEmpty
                                            ? _selectedLastName
                                            : null)
                                    .snapshots();
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text('All Names'),
                              ),
                              ...lastNames.map((lastName) {
                                return DropdownMenuItem<String>(
                                  value: lastName,
                                  child: Text(lastName),
                                );
                              }).toList(),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Filter by Nationality',
                            ),
                            isExpanded: true,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 137,
                  child: Column(
                    children: [
                      FutureBuilder<List<String>>(
                        future: fetchNationalities(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final List<String> nationalities =
                              snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            key: Key('NationalityFilterDropdown'),
                            value: _selectedNationality,
                            onChanged: _setSelectedNationality,
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text('All Nationalities'),
                              ),
                              ...nationalities.map((nationality) {
                                return DropdownMenuItem<String>(
                                  value: nationality,
                                  child: Text(nationality),
                                );
                              }).toList(),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Filter by Nationality',
                            ),
                            isExpanded: true,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _membersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final List<DocumentSnapshot> members = snapshot.data!.docs;

                List<DocumentSnapshot> filteredMembers = members;
                if (_selectedNationality.isNotEmpty) {
                  filteredMembers = members
                      .where((member) =>
                          member['nationality'] == _selectedNationality)
                      .toList();
                }

                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Text(
                      'No family members matching the filters',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredMembers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final member = filteredMembers[index];
                    return MemberWidget(
                      firstName: member['firstName'],
                      lastName: member['lastName'],
                      userId: widget.userId,
                      treeId: widget.treeId,
                      memberId: member.id,
                      gender: member['gender'],
                      birthDate: member['birthDate'].toDate(),
                      photoUrl: member['photoUrl'],
                      onDeleteMember: _deleteMember,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('AddMemberButton'),
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
  final Key key = Key('AddMemberDialog');
  final Function(String, String, String, DateTime, String, XFile?) onSubmit;

  AddMemberForm({required this.onSubmit});

  @override
  _AddMemberFormState createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedPhoto;
  final ImagePicker _imagePicker = ImagePicker();
  String _firstName = "";
  String _lastName = "";
  DateTime _dateOfBirth = DateTime.now();
  DateTime? _dateOfDeath;
  String _gender = "";
  String _nationality = "";

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedPhoto = File(pickedImage.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      XFile? xFile;
      if (_selectedPhoto != null) {
        xFile = XFile(_selectedPhoto!.path);
      }
      widget.onSubmit(
        _firstName,
        _lastName,
        _nationality,
        _dateOfBirth,
        _gender,
        xFile,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Choose Photo'),
          ),
          SizedBox(height: 16),
          TextFormField(
            key: Key('FirstNameField'),
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
            onSaved: (value) => _firstName = value!,
          ),
          SizedBox(height: 16.0),
          TextFormField(
            key: Key('LastNameField'),
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
            onSaved: (value) => _lastName = value!,
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
            key: Key('GenderDropdown'),
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
            key: Key('NationalityField'),
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
            onSaved: (value) => _nationality = value!,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            key: Key('AddMemberDialogButton'),
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
        ]),
      ),
    );
  }
}
