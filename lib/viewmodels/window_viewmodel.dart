import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

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
    // 윈도우에서는 이 커스텀 채널 호출을 아예 건너뛰도록 고칩니다.
    if (!Platform.isWindows) {
      await _windowChannel
          .invokeMethod('setWindowLocked', {'locked': _isLocked});
    }
    
    // 리사이즈 가능 여부 제어
    await windowManager.setResizable(!_isLocked);
    // 창 레벨(alwaysOnBottom/Top) 제어는 Swift 네이티브 코드에서 처리
    
  } on PlatformException catch (e) {
    debugPrint('Failed to set window lock state: ${e.message}');
  }
}
}
