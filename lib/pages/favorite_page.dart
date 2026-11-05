// FILE INI: halaman daftar lagu favorit (tab Favorit).
// Data dari FavoriteService.daftar, otomatis update kalau ada lagu
// yang ditambah atau dihapus dari favorit.

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/favorite_service.dart';
import '../widgets/song_tile.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  Widget _buildKosong() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 60, color: Colors.grey),
          SizedBox(height: 8),
          Text('Belum ada lagu favorit'),
          Text(
            'Tekan ikon hati di halaman detail lagu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Song> daftar) {
    return ListView.builder(
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        return SongTile(song: daftar[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lagu Favorit'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<Song>>(
        valueListenable: FavoriteService.daftar,
        builder: (context, daftar, child) {
          if (daftar.isEmpty) {
            return _buildKosong();
          }
          return _buildList(daftar);
        },
      ),
    );
  }
}