import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appName = 'Hand Speaks';
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  void _getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("About $_appName"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/hand_img_3.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16),

            Text(
              _appName,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),

            Text(
              "Version $_version",
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            _buildSectionTitle(context, "Our Mission"),
            SizedBox(height: 12),
            Text(
              "To provide a simple, real-time, and private way to bridge communication gaps using the power of on-device AI for sign language detection.",
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            _buildSectionTitle(context, "Privacy First"),
            SizedBox(height: 12),
            Text(
              "All sign language detection happens directly on your device. Your camera feed never leaves your phone, ensuring your privacy is always protected.",
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            OutlinedButton(
              child: Text("View Open Source Licenses"),
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: _appName,
                  applicationVersion: _version,
                  applicationIcon: Image.asset(
                    'assets/images/hand_img_3.png',
                    width: 48,
                    height: 48,
                  ),
                );
              },
            ),

            SizedBox(height: 24),
            Text(
              "© 2025 Hand Speaks",
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}