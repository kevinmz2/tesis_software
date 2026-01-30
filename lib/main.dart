import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/local/local_db_service.dart';
import 'firebase_options.dart';

// AUTH
import 'features/auth/screens/login_screen.dart';

// ADMIN
//import 'features/admin/screens/admin_home_screen.dart';

// DOCENTE
//import 'features/docente/screens/docente_home_screen.dart';


//admin
import 'features/admin/screens/admin_dashboard_screen.dart';
//docente
import 'features/docente/screens/docente_dashboard_screen.dart';


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

      /// 🔹 THEME GLOBAL (NEGRO + MORADO SUAVE)
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),

        // Color principal (morado suave)
        primaryColor: const Color(0xFF5E548E),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5E548E), // morado suave
          foregroundColor: Colors.white,
          elevation: 1,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5E548E),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E548E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 14,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF1C1C1C),
            fontWeight: FontWeight.w600,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF5E548E), // morado solo como acento
        ),
      ),

      /// 🔹 RUTA INICIAL
      initialRoute: '/login',

      /// 🔹 RUTAS DEL SISTEMA
      routes: {
        '/login': (_) => const LoginScreen(),

        /// 👉 PANEL ADMINISTRADOR
        //'/admin': (_) => const AdminHomeScreen(),
        '/admin': (_) => const AdminDashboardScreen(),


        /// 👉 PANEL DOCENTE
        //'/docente': (_) => const DocenteHomeScreen(),
        '/docente': (_) => const DocenteDashboardScreen(),

      
      },
    );
  }
}
