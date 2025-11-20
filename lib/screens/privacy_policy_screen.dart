import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Helper widget for a policy section
    Widget _buildPolicySection(String title, String content) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          SizedBox(height: 24),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy for SignDetect",
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Last updated: November 17, 2025",
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),

            _buildPolicySection(
              "Introduction",
              "Welcome to SignDetect. We are committed to protecting your privacy. This policy outlines how we handle your information.",
            ),

            _buildPolicySection(
              "Information We Don't Collect",
              "We designed SignDetect with privacy as a priority. We do not collect, store, or share any personally identifiable information. You are not required to create an account or provide a name or email address to use this app.",
            ),

            _buildPolicySection(
              "Camera Access",
              "SignDetect requires access to your device's camera to perform its core function: real-time sign language detection.\n\n"
                  "**All processing happens 100% on your device.** Your camera feed, images, or video data **never leave your phone**. This data is not sent to any server, is not stored by the app, and is not shared with us or any third party.",
            ),

            _buildPolicySection(
              "App Settings",
              "To improve your experience, the app locally saves your preferences, such as your chosen theme (Light/Dark/System) and whether you have completed the onboarding. This information is stored only on your device and is not linked to you personally.",
            ),

            _buildPolicySection(
              "Children's Privacy",
              "This app is not intended for use by children, and we do not knowingly collect any information from them. All processing remains on-device regardless of user age.",
            ),

            _buildPolicySection(
              "Changes to This Policy",
              "We may update this privacy policy from time to time. Any changes will be posted on this page.",
            ),

            _buildPolicySection(
              "Contact Us",
              "If you have any questions or concerns about this privacy policy, please contact us at:\n\n"
                  "hg832004@gmail.com\nsidrai11@gmail.com", // <-- IMPORTANT: Add your email here
            ),
          ],
        ),
      ),
    );
  }
}