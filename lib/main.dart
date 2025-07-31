import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/constants/app_constants.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/passenger_repository.dart';
import 'data/repositories/schedule_repository.dart';
import 'data/repositories/ticket_repository.dart';
import 'domain/usecases/auth_usecase.dart';
import 'domain/usecases/schedule_usecase.dart';
import 'domain/usecases/ticket_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for cross-platform support
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize database
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        // Repositories
        Provider<PassengerRepository>(
          create: (_) => PassengerRepository(),
        ),
        Provider<ScheduleRepository>(
          create: (_) => ScheduleRepository(),
        ),
        Provider<TicketRepository>(
          create: (_) => TicketRepository(),
        ),

        // Use Cases
        Provider<AuthUseCase>(
          create: (context) => AuthUseCase(
            context.read<PassengerRepository>(),
          ),
        ),
        Provider<ScheduleUseCase>(
          create: (context) => ScheduleUseCase(
            context.read<ScheduleRepository>(),
          ),
        ),
        Provider<TicketUseCase>(
          create: (context) => TicketUseCase(
            context.read<TicketRepository>(),
            context.read<ScheduleRepository>(),
          ),
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthUseCase>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.currentTheme,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
