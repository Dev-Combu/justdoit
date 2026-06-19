// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justdoit/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'viewmodels/window_viewmodel.dart';
import 'views/screens/dashboard_screen.dart';
import 'views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const windowOptions = WindowOptions(
    size: Size(700, 500),
    minimumSize: Size(300, 400),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    skipTaskbar: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.show();
  });

  runApp(ProviderScope(child: const JustDoItApp()));
}

class JustDoItApp extends StatelessWidget {
  const JustDoItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => WindowViewModel()),
      ],
      child: MaterialApp(
        title: 'Just Do It Widget',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
        ),
        themeMode: ThemeMode.light,
        home: const _AppRoot(),
      ),
    );
  }
}

/// 로그인 상태에 따라 로그인 화면 or 대시보드 전환
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    // 앱 시작 시 세션 복원 중
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 로그인 안됨 → 로그인 화면
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    // 로그인됨 → TodoViewModel을 userId로 생성해서 대시보드 제공
    return ChangeNotifierProvider(
      key: ValueKey(auth.userId), // userId가 바뀌면 ViewModel 재생성
      create: (_) => TodoViewModel(userId: auth.userId!),
      child: const DashboardScreen(),
    );
  }
}
