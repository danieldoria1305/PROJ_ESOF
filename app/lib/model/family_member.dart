class FamilyMember {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String gender;
  final String? photoUrl;
  final String? parent1Id;
  final String? parent2Id;

  FamilyMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
    this.parent1Id,
    this.parent2Id,
  });

  get memberId => memberId;
  get memberFirstName => firstName;
  get memberLastName => lastName;
  get memberBirthDate => birthDate;
  get memberGender => gender;
  get memberPhotoUrl => photoUrl;
}
