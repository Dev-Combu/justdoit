import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class WindowViewModel with ChangeNotifier {
  bool _isLocked = true;
  static const MethodChannel _windowChannel =
      MethodChannel('com.example.justdoit/window');

  bool get isLocked => _isLocked;

  WindowViewModel() {
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLocked = prefs.getBool('isLocked') ?? true;
    notifyListeners();
    await _applyLockState();
  }

  Future<void> toggleLock() async {
    _isLocked = !_isLocked;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocked', _isLocked);
    await _applyLockState();
  }

  Future<void> _applyLockState() async {
    try {
      await _windowChannel
          .invokeMethod('setWindowLocked', {'locked': _isLocked});
      await windowManager.setResizable(!_isLocked);
    } on PlatformException catch (e) {
      debugPrint('Failed to set window lock state: ${e.message}');
    }
  }
}
