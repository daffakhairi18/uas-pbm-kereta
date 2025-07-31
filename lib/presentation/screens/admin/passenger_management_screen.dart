import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/passenger_model.dart';
import '../../../domain/usecases/auth_usecase.dart';

class PassengerManagementScreen extends StatefulWidget {
  const PassengerManagementScreen({super.key});

  @override
  State<PassengerManagementScreen> createState() =>
      _PassengerManagementScreenState();
}

class _PassengerManagementScreenState extends State<PassengerManagementScreen> {
  List<PassengerModel> passengers = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPassengers();
  }

  Future<void> _loadPassengers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authUseCase = Provider.of<AuthUseCase>(context, listen: false);
      final allPassengers = await authUseCase.getAllPassengers();
      setState(() {
        passengers = allPassengers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<PassengerModel> get filteredPassengers {
    if (searchQuery.isEmpty) {
      return passengers;
    }
    return passengers.where((passenger) {
      return passenger.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          passenger.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          passenger.phone.contains(searchQuery) ||
          passenger.idNumber.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Penumpang'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPassengers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari penumpang...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Stats header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Penumpang: ${passengers.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Penumpang: ${passengers.where((p) => p.userType == AppConstants.userTypePassenger).length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Admin: ${passengers.where((p) => p.userType == AppConstants.userTypeAdmin).length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Passengers list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPassengers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada penumpang',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredPassengers.length,
                        itemBuilder: (context, index) {
                          final passenger = filteredPassengers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: passenger.userType ==
                                        AppConstants.userTypeAdmin
                                    ? Colors.green
                                    : Colors.blue,
                                child: Icon(
                                  passenger.userType ==
                                          AppConstants.userTypeAdmin
                                      ? Icons.admin_panel_settings
                                      : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                passenger.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${passenger.email}'),
                                  Text('Phone: ${passenger.phone}'),
                                  Text('ID: ${passenger.idNumber}'),
                                  Text(
                                    'Tipe: ${passenger.userType == AppConstants.userTypeAdmin ? 'Admin' : 'Penumpang'}',
                                    style: TextStyle(
                                      color: passenger.userType ==
                                              AppConstants.userTypeAdmin
                                          ? Colors.green
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Daftar: ${DateFormat('dd/MM/yyyy').format(passenger.createdAt)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: passenger.userType !=
                                      AppConstants.userTypeAdmin
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) =>
                                          _handlePassengerAction(
                                              value, passenger),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Hapus',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPassengerDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _handlePassengerAction(String action, PassengerModel passenger) {
    switch (action) {
      case 'edit':
        _showAddPassengerDialog(passenger: passenger);
        break;
      case 'delete':
        _deletePassenger(passenger);
        break;
    }
  }

  Future<void> _deletePassenger(PassengerModel passenger) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus penumpang ${passenger.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authUseCase = Provider.of<AuthUseCase>(context, listen: false);
        await authUseCase.deletePassenger(passenger.id!);
        _loadPassengers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Penumpang berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showAddPassengerDialog({PassengerModel? passenger}) {
    final isEditing = passenger != null;
    final nameController = TextEditingController(text: passenger?.name ?? '');
    final idNumberController =
        TextEditingController(text: passenger?.idNumber ?? '');
    final phoneController = TextEditingController(text: passenger?.phone ?? '');
    final emailController = TextEditingController(text: passenger?.email ?? '');
    final usernameController =
        TextEditingController(text: passenger?.username ?? '');
    final passwordController =
        TextEditingController(text: passenger?.password ?? '');

    String selectedUserType =
        passenger?.userType ?? AppConstants.userTypePassenger;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Penumpang' : 'Tambah Penumpang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor KTP',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  decoration: const InputDecoration(
                    labelText: 'Tipe Pengguna',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AppConstants.userTypePassenger,
                      child: const Text('Penumpang'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.userTypeAdmin,
                      child: const Text('Admin'),
                    ),
                  ],
                  onChanged: (value) => selectedUserType = value!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: isEditing
                        ? 'Password (kosongkan jika tidak diubah)'
                        : 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_validatePassengerForm(
                  nameController.text,
                  idNumberController.text,
                  phoneController.text,
                  emailController.text,
                  usernameController.text,
                  passwordController.text,
                  isEditing,
                )) {
                  await _savePassenger(
                    isEditing,
                    passenger,
                    nameController.text,
                    idNumberController.text,
                    phoneController.text,
                    emailController.text,
                    selectedUserType,
                    usernameController.text,
                    passwordController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Update' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validatePassengerForm(
    String name,
    String idNumber,
    String phone,
    String email,
    String username,
    String password,
    bool isEditing,
  ) {
    if (name.isEmpty) {
      _showError('Nama tidak boleh kosong');
      return false;
    }
    if (idNumber.isEmpty) {
      _showError('Nomor KTP tidak boleh kosong');
      return false;
    }
    if (phone.isEmpty) {
      _showError('Nomor telepon tidak boleh kosong');
      return false;
    }
    if (email.isEmpty) {
      _showError('Email tidak boleh kosong');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Format email tidak valid');
      return false;
    }
    if (username.isEmpty) {
      _showError('Username tidak boleh kosong');
      return false;
    }
    if (!isEditing && password.isEmpty) {
      _showError('Password tidak boleh kosong');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _savePassenger(
    bool isEditing,
    PassengerModel? passenger,
    String name,
    String idNumber,
    String phone,
    String email,
    String userType,
    String username,
    String password,
  ) async {
    try {
      final authUseCase = Provider.of<AuthUseCase>(context, listen: false);

      if (isEditing && passenger != null) {
        final updatedPassenger = passenger.copyWith(
          name: name,
          idNumber: idNumber,
          phone: phone,
          email: email,
          userType: userType,
          username: username,
          password: password.isEmpty ? passenger.password : password,
        );
        await authUseCase.updatePassenger(updatedPassenger);
      } else {
        final newPassenger = PassengerModel(
          name: name,
          idNumber: idNumber,
          phone: phone,
          email: email,
          userType: userType,
          username: username,
          password: password,
          createdAt: DateTime.now(),
        );
        await authUseCase.register(newPassenger);
      }

      _loadPassengers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Penumpang berhasil diupdate'
                : 'Penumpang berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
