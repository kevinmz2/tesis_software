import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart'; //para inicializar HIVE
import 'services/local/local_db_service.dart';


import 'firebase_options.dart';

// AUTH
import 'features/auth/screens/login_screen.dart';

// ADMIN
import 'features/admin/screens/admin_home_screen.dart';

// DOCENTE (por ahora placeholder)
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

      /// 🔹 RUTA INICIAL
      initialRoute: '/login',

      /// 🔹 RUTAS DEL SISTEMA
      routes: {
        '/login': (_) => const LoginScreen(),

        /// 👉 PANEL ADMINISTRADOR (PRIMERO SIEMPRE)
        '/admin': (_) => const AdminHomeScreen(),

        /// 👉 PANEL DOCENTE
        '/docente': (_) => const DocenteHomeScreen(),
      },
    );
  }
}
