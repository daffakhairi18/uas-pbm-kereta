import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: const [
          ThemeToggleWidget(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengaturan Aplikasi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sesuaikan preferensi Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Sections
                Expanded(
                  child: ListView(
                    children: [
                      // Appearance Section
                      _buildSectionHeader('Tampilan'),
                      const SizedBox(height: 8),
                      _buildThemeToggleCard(context),
                      const SizedBox(height: 16),

                      // Account Section
                      _buildSectionHeader('Akun'),
                      const SizedBox(height: 8),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final user = authProvider.currentUser;
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(user?.name ?? 'User'),
                                  subtitle:
                                      Text(user?.email ?? 'user@example.com'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Fitur edit profil akan segera tersedia'),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: Icon(
                                    Icons.security,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  title: const Text('Ubah Password'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Fitur ubah password akan segera tersedia'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notifications Section
                      _buildSectionHeader('Notifikasi'),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Notifikasi Pemesanan'),
                              subtitle: const Text(
                                  'Dapatkan notifikasi saat pemesanan berhasil'),
                              value: true,
                              onChanged: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Pengaturan notifikasi akan segera tersedia'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('Notifikasi Jadwal'),
                              subtitle: const Text(
                                  'Dapatkan pengingat jadwal keberangkatan'),
                              value: false,
                              onChanged: (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Pengaturan notifikasi akan segera tersedia'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // About Section
                      _buildSectionHeader('Tentang'),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.info,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Versi Aplikasi'),
                              subtitle: const Text('1.0.0'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.description,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Kebijakan Privasi'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Kebijakan privasi akan segera tersedia'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.help,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: const Text('Bantuan'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Halaman bantuan akan segera tersedia'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Logout'),
                                content: const Text(
                                    'Apakah Anda yakin ingin keluar dari aplikasi?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .logout();
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      foregroundColor:
                                          Theme.of(context).colorScheme.onError,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeToggleCard(BuildContext context) {
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
