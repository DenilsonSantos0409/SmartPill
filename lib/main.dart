import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Pastikan Anda mengimpor ini
import 'package:pill_test/pages/main_page.dart';
import 'package:pill_test/pages/tentang_aplikasi.dart';
import 'package:provider/provider.dart';
import 'providers/obat_provider.dart';
import 'providers/theme_provider.dart';
import 'pages/edit_page.dart';
import 'pages/profile_page.dart';
import 'pages/home_page.dart';
import 'pages/riwayat_obat.dart';
import 'pages/login_screen.dart';
import 'pages/tambah_obat.dart';
import 'pages/register_screen.dart';
import 'pages/notification_page.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ObatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SmartPill',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // Hapus duplikat home, gunakan SplashScreen sebagai layar awal
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/main-page': (context) => const MainPage(),
        '/register': (context) => const RegisterScreen(),
        '/tambah-obat': (context) => const TambahObatPage(),
        '/riwayat-obat': (context) => const RiwayatObatPage(),
        '/profile': (context) => const ProfilePage(),
        // '/notifications': (context) => const NotifikasiPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/tentang-aplikasi': (context) => TentangAplikasiPage(),
      },
    );
  }
}
