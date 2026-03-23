import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/local/local_db_service.dart';
import 'firebase_options.dart';

// AUTH
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/session_gate_screen.dart';

// ADMIN
import 'features/admin/screens/admin_home_screen.dart';

// DOCENTE
import 'features/docente/screens/docente_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await LocalDbService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplicación Académica Offline-First',
      initialRoute: '/session-gate',
      routes: {
        '/session-gate': (_) => const SessionGateScreen(),
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminHomeScreen(),
        '/docente': (_) => const DocenteHomeScreen(),
      },
    );
  }
}