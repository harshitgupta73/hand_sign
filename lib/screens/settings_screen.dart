import 'package:classify/screens/privacy_policy_screen.dart';
import 'package:classify/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../provider/theme_provider.dart';
import 'about_screen.dart';
import 'how_it_works_screen.dart';


class SettingsScreen extends StatelessWidget {

  // --- Helper method for launching URLs ---
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
      print("Could not launch $url");
    }
  }

  // --- Helper method for the "About" dialog ---
  void _showAppAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationIcon: Image.asset('assets/images/app_icon.png', width: 48, height: 48), // Add your app icon to assets
      applicationLegalese: '© 2025 SignDetect',
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('A real-time sign language detection app powered by on-device AI.'),
        )
      ],
    );
  }

  // --- Helper method for the "Change Theme" dialog ---
  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text("Light"),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text("Dark"),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text("System Default"),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setTheme(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("User Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text("Change Theme"),
            onTap: () {
              _showThemeDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("How It Works"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowItWorksScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About The App"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}