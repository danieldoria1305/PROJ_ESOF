class FamilyMember {
  final String? photo;
  final String name;
  final DateTime dateOfBirth;
  //final DateTime? dateOfDeath;
  final String gender;
  final String occupation;

  FamilyMember({
    this.photo,
    required this.name,
    required this.dateOfBirth,
    //this.dateOfDeath,
    required this.gender,
    required this.occupation,
  });
}