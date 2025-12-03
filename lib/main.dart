import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'transaction_page.dart';
import 'service_page.dart';
import 'history_page.dart';
import 'laporan_page.dart';
import 'laporan_pengeluaran_page.dart';
import 'laporan_transaksi_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF203A43)),
        useMaterial3: true,
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF203A43),
              body: Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
            );
          } else if (snapshot.hasData) {
            return const DashboardPage();
          } else {
            return const LoginPage();
          }
        },
      ),

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/transactions': (context) => const TransactionPage(),
        '/services': (context) => const ServicePage(),
        '/history': (context) => const HistoryPage(),
        '/reports': (context) => const LaporanPage(),
        '/money_out': (context) => const LaporanPengeluaranPage(),
        '/transactions_report': (context) => const LaporanTransaksiPage(),
      },
    );
  }
}
