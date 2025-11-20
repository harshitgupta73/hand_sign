import 'package:classify/provider/theme_provider.dart';
import 'package:classify/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classify/screens/HomeScreen.dart';

// --- Define your app's themes ---
class MyAppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue.shade300,
      secondary: Colors.blueAccent.shade100,
    ),
  );
}
// ---------------------------------

bool hasSeenOnboarding = false;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check if onboarding has been seen
  final prefs = await SharedPreferences.getInstance();
  hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Run the ProviderSetup widget, which will CREATE the provider
  runApp(ProviderSetup());
}


// --- NEW WIDGET ---
// This widget's job is to create the providers
// and have MyApp as its child.
class ProviderSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(), // Now, MyApp is correctly a descendant
    );
  }
}


// This is your original MyApp widget.
// Its context is now a descendant of ProviderSetup,
// so Provider.of() will find ThemeProvider.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Consume the provider
    // THIS WILL WORK NOW
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SignDetect',
      debugShowCheckedModeBanner: false,

      // --- Configure Themes ---
      theme: MyAppThemes.lightTheme,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: themeProvider.themeMode, // This tells Flutter which theme to use
      // --------------------------

      home: hasSeenOnboarding ? HomeScreen() : OnboardingScreen(),
    );
  }
}