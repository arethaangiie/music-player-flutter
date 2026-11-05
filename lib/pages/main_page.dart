// FILE INI: kerangka aplikasi dengan bottom navigation.
// Tiga tab: Home, Favorit, Profil.
// IndexedStack menjaga halaman tetap hidup, jadi pindah tab tidak memuat ulang data.

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tabAktif = 0;

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: tabAktif,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          tabAktif = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabAktif,
        children: const [
          HomePage(),
          FavoritePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}