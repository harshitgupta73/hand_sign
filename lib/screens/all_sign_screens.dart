import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// A simple class to hold our sign data
class Sign {
  final String label;
  final String imagePath; // Path to an example image in your assets

  Sign({required this.label, required this.imagePath});
}

class AllSignsScreen extends StatefulWidget {
  @override
  _AllSignsScreenState createState() => _AllSignsScreenState();
}

class _AllSignsScreenState extends State<AllSignsScreen> {
  List<Sign> _signs = [];

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  // Load the labels from your assets/labels.txt
  Future<void> _loadSigns() async {
    final labelsString = await rootBundle.loadString('assets/label.txt');
    final labels = labelsString.split('\n');

    List<Sign> tempSigns = [];
    for (var label in labels) {
      if (label.isNotEmpty) {
        final parts = label.split(' ');
        final signLabel = parts.last;

        final imagePath = 'assets/images/$signLabel.png';

        tempSigns.add(Sign(label: signLabel, imagePath: imagePath));
      }
    }

    setState(() {
      _signs = tempSigns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn Signs"),
      ),
      body: _signs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Makes the cards square
        ),
        itemCount: _signs.length,
        itemBuilder: (context, index) {
          final sign = _signs[index];
          return Card(
            elevation: 4.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   sign.imagePath,
                //   height: 100,
                //   // Show an icon if the image fails to load
                //   errorBuilder: (context, error, stackTrace) {
                //     return Icon(Icons.sign_language, size: 100, color: Colors.grey);
                //   },
                // ),
                Icon(Icons.sign_language_outlined, size: 80, color: Theme.of(context).primaryColor),
                SizedBox(height: 16),
                Text(
                  sign.label,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}