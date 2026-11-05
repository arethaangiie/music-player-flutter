// FILE INI: halaman isi album.
// Menampilkan cover + info album, lalu daftar lagu di dalamnya.
// Ada loading dan error + tombol "Coba Lagi". Klik lagu -> DetailPage.

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class AlbumPage extends StatefulWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<Song> tracks = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    muatTracks();
  }

  Future<void> muatTracks() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final hasil = await ambilLaguAlbum(widget.album.id);

      if (!mounted) return;
      setState(() {
        tracks = hasil;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Widget _buildHeader() {
    final album = widget.album;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            ubahCover(album.cover, '600x600'),
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.album, size: 100, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          album.nama,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(album.artis, style: const TextStyle(color: Colors.grey)),
        Text(
          '${album.genre} • ${album.jumlahLagu} lagu',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTrackItem(Song song) {
    return ListTile(
      leading: Text(
        '${song.trackNumber}',
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      title: Text(song.judul),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(song: song)),
        );
      },
    );
  }

  Widget _buildTrackList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError) {
      return Column(
        children: [
          const Text('Gagal memuat lagu. Cek koneksi internet.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: muatTracks,
            child: const Text('Coba Lagi'),
          ),
        ],
      );
    }
    return Column(
      children: tracks.map((song) => _buildTrackItem(song)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.nama),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 32),
            _buildTrackList(),
          ],
        ),
      ),
    );
  }
}