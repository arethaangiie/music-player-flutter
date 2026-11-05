// FILE INI: titik mulai aplikasi.
// - Memuat data favorit yang tersimpan sebelum app tampil
// - Mengatur tema terang/gelap
// - Halaman pertama: MainPage (bottom navigation)

import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'services/favorite_service.dart';
import 'services/tema_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteService.muat();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // setiap kali temaNotifier berubah, MaterialApp dibangun ulang
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const MainPage(),
        );
      },
    );
  }
}