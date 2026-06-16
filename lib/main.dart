// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justdoit/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'viewmodels/window_viewmodel.dart';
import 'views/screens/dashboard_screen.dart';

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
    await windowManager.setAlwaysOnBottom(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: const JustDoItApp()));
}

class JustDoItApp extends StatelessWidget {
  const JustDoItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
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
        home: const DashboardScreen(),
      ),
    );
  }
}
