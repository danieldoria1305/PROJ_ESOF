import 'family_member.dart';

class FamilyTree {
  final String id;
  final String name;
  final List<FamilyMember> members;

  FamilyTree({
    required this.id,
    required this.name,
    required this.members,
  });

  get treeId => id;
}
