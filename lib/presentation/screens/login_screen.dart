import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/theme_toggle_widget.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedUserType = AppConstants.userTypePassenger;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo/Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.train,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // App Title
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan login untuk melanjutkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // User Type Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedUserType,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Tipe Pengguna',
                              prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: AppConstants.userTypePassenger,
                                child: Text('Penumpang'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.userTypeAdmin,
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedUserType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.login),
                                label: authProvider.isLoading
                                    ? const Text('Loading...')
                                    : const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleLogin,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Error Message
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.error != null) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).colorScheme.error),
                                ),
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('Daftar'),
                            ),
                          ],
                        ),

                        // Demo Credentials
                        if (_selectedUserType == AppConstants.userTypeAdmin) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Demo Admin Credentials:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Username: ${AppConstants.defaultAdminUsername}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                                Text(
                                  'Password: ${AppConstants.defaultAdminPassword}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }
}
