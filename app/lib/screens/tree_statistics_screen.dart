import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StatisticsWidget extends StatelessWidget {
  final String title;
  final int count;
  final String text;
  final String description;
  final Key key;

  StatisticsWidget({
    required this.title,
    this.count = -1,
    this.text = '',
    required this.description,
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count != -1 ? count.toString() : text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TreeStatisticsScreen extends StatefulWidget {
  final String userId;
  final String treeId;
  final FirebaseFirestore firestore;
  final Key key = Key('TreeStatisticsScreen');

  TreeStatisticsScreen({required this.userId, required this.treeId, required this.firestore});

  @override
  _TreeStatisticsScreenState createState() => _TreeStatisticsScreenState();
}

class _TreeStatisticsScreenState extends State<TreeStatisticsScreen> {
  int maleCount = 0;
  int femaleCount = 0;
  int nonBinaryCount = 0;
  int otherCount = 0;
  String mostCommonNationality = '';

  @override
  void initState() {
    super.initState();
    fetchTreeStatistics();
  }

  Future<void> fetchTreeStatistics() async {
    try {
      final treeSnapshot = await widget.firestore
          .collection('users')
          .doc(widget.userId)
          .collection('trees')
          .doc(widget.treeId)
          .collection('members')
          .get();

      Map<String, int> nationalityCounts = {};

      treeSnapshot.docs.forEach((doc) {
        final nationality = doc['nationality'];
        if (nationality != null) {
          nationalityCounts[nationality] =
              (nationalityCounts[nationality] ?? 0) + 1;
        }
      });

      final sortedNationalityCounts = nationalityCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        maleCount =
            treeSnapshot.docs.where((doc) => doc['gender'] == 'Male').length;
        femaleCount =
            treeSnapshot.docs.where((doc) => doc['gender'] == 'Female').length;
        nonBinaryCount = treeSnapshot.docs
            .where((doc) => doc['gender'] == 'Non-binary')
            .length;
        otherCount =
            treeSnapshot.docs.where((doc) => doc['gender'] == 'Other').length;

        if (sortedNationalityCounts.isNotEmpty) {
          mostCommonNationality = sortedNationalityCounts.first.key;
        }
      });
    } catch (e) {
      print('Error fetching tree statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tree Statistics'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Gender related statistics',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatisticsWidget(
                  key:Key('MaleCountWidget'),
                  title: 'Male',
                  count: maleCount,
                  description: 'Male members',
                ),
                StatisticsWidget(
                  key:Key('FemaleCountWidget'),
                  title: 'Female',
                  count: femaleCount,
                  description: 'Female members',
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatisticsWidget(
                  key:Key('NonBinaryCountWidget'),
                  title: 'Non-binary',
                  count: nonBinaryCount,
                  description: 'Non-binary members',
                ),
                StatisticsWidget(
                  key:Key('OtherCountWidget'),
                  title: 'Other',
                  count: otherCount,
                  description: 'Other members',
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Other relevant statistics',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            StatisticsWidget(
              key:Key('MostCommonNationalityWidget'),
              title: 'Most Common Nationality',
              text: mostCommonNationality,
              description: 'Most common nationality',
            ),
          ],
        ),
      ),
    );
  }
}
