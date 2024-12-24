import 'package:flutter/foundation.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final AuthService _authService = AuthService();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService().login(email, password);
      await fetchCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.checkLogin();
    } catch (e) {
      _currentUser = null;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> logout() async {
  //   try {
  //     await _authService.logout();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   } finally {
  //     _currentUser = null;
  //     notifyListeners();
  //   }
  // }
}
