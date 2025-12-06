import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/guest_home.dart';
import 'screens/staff_home.dart';
import 'screens/manager_home.dart';
import 'theme/app_theme.dart';  // ← Make sure this import path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sphinx Hotel',
      theme: AppTheme.darkTheme,      // ← Use your custom theme
      darkTheme: AppTheme.darkTheme,  // ← Same for dark mode
      themeMode: ThemeMode.dark,      // ← Force dark mode (or use ThemeMode.system later)
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/guest-home': (context) => const GuestHome(),
        '/staff-home': (context) => const StaffHome(),
        '/manager-home': (context) => const ManagerHome(),
      },
    );
  }
}
