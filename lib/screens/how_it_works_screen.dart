import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("How It Works"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildStep(
            context: context,
            icon: Icons.camera_alt,
            title: "Real-Time Detection",
            description: "Simply point your front camera at your hand. The app will detect the sign and speak the result.",
          ),
          _buildStep(
            context: context,
            icon: Icons.privacy_tip,
            title: "Privacy First",
            description: "All processing happens on your device. Your camera feed never leaves your phone.",
          ),
          _buildStep(
            context: context,
            icon: Icons.volume_up,
            title: "Audio Feedback",
            description: "The detected sign is spoken aloud automatically, providing instant feedback.",
          ),
        ],
      ),
    );
  }

  // Helper widget for steps
  Widget _buildStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            SizedBox(height: 12.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}