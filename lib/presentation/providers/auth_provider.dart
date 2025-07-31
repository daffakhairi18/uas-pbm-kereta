import 'package:flutter/material.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../data/models/passenger_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthUseCase _authUseCase;
  PassengerModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authUseCase);

  PassengerModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.userType == 'admin';

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authUseCase.login(username, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(PassengerModel passenger) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _authUseCase.register(passenger);
      if (id > 0) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Gagal mendaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 