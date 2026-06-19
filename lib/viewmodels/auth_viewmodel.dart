import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel with ChangeNotifier {
  String? _userId; // 비밀번호 = 사용자 ID
  bool _isLoading = true;

  String? get userId => _userId;
  bool get isLoggedIn => _userId != null;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _restoreSession();
  }

  /// 앱 시작 시 저장된 세션 복원
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _isLoading = false;
    notifyListeners();
  }

  /// 비밀번호로 로그인 (비밀번호 = userId)
  Future<void> login(String password) async {
    final trimmed = password.trim();
    if (trimmed.isEmpty) return;
    _userId = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', trimmed);
    notifyListeners();
  }

  /// 로그아웃
  Future<void> logout() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}
