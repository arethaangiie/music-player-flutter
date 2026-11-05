// FILE INI: halaman profil (tab Profil).
// Menampilkan data diri, jumlah lagu favorit, dan switch dark mode.
// Data diri diisi langsung di bagian atas class.

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorite_service.dart';
import '../services/tema_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  final String nama = 'Seisha Aretha Angie';
  final String nim = '825240138';

  Widget _buildAvatar() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          nama,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Column(
        children: [
          _buildInfoItem(Icons.badge, 'NIM', nim),
        ],
      ),
    );
  }

  // jumlah favorit ikut berubah otomatis
  Widget _buildStatistik() {
    return Card(
      child: ValueListenableBuilder<List<Song>>(
        valueListenable: FavoriteService.daftar,
        builder: (context, daftar, child) {
          return ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('Lagu Favorit'),
            trailing: Text(
              '${daftar.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDarkMode() {
    return Card(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: temaNotifier,
        builder: (context, mode, child) {
          return SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.blue),
            title: const Text('Dark Mode'),
            value: mode == ThemeMode.dark,
            onChanged: (nilai) {
              temaNotifier.value = nilai ? ThemeMode.dark : ThemeMode.light;
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          // di layar lebar, konten dibatasi supaya tidak melebar
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 500),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  _buildStatistik(),
                  _buildDarkMode(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}