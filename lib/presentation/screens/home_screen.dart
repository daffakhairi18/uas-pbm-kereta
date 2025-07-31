import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/theme_toggle_widget.dart';
import 'admin/admin_dashboard_screen.dart';
import 'passenger/passenger_dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        return authProvider.isAdmin
            ? const AdminDashboardScreen()
            : const PassengerDashboardScreen();
      },
    );
  }
} 