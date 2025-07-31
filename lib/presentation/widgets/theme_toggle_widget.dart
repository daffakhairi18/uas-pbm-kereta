import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
          tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
        );
      },
    );
  }
}

class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: ListTile(
            leading: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value);
              },
            ),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
        );
      },
    );
  }
}
