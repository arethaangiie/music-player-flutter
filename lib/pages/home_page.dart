// FILE INI: halaman utama (tab Home).
// Isinya: search bar, Lagu Populer (horizontal), dan Album (grid).
// Ada loading, error + tombol "Coba Lagi", dan tarik layar ke bawah untuk refresh.
// Klik lagu -> DetailPage, klik album -> AlbumPage.

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/album.dart';
import '../services/api_service.dart';
import '../widgets/song_tile.dart';
import 'album_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  List<Song> laguPopuler = [];
  List<Album> albumList = [];
  List<Song> hasilCari = [];
  bool isLoading = true;
  bool isError = false;
  bool isSearching = false; // true = tampilkan hasil pencarian

  @override
  void initState() {
    super.initState();
    muatHome();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ---------- DATA ----------
  // tampilLoading = false dipakai saat pull-to-refresh
  Future<void> muatHome({bool tampilLoading = true}) async {
    if (tampilLoading) {
      setState(() {
        isLoading = true;
        isError = false;
      });
    }

    try {
      final lagu = await cariLagu('hits', limit: 15);
      final album = await cariAlbum('pop', limit: 12);

      if (!mounted) return;
      setState(() {
        laguPopuler = lagu;
        albumList = album;
        isLoading = false;
        isError = false;
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

  Future<void> cariLaguUser() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      isError = false;
      isSearching = true;
    });

    try {
      final hasil = await cariLagu(controller.text);

      if (!mounted) return;
      setState(() {
        hasilCari = hasil;
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

  void kembaliKeHome() {
    controller.clear();
    setState(() {
      isSearching = false;
      isError = false;
      hasilCari = [];
    });
  }

  // ---------- NAVIGASI ----------
  void bukaDetailLagu(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(song: song)),
    );
  }

  void bukaDetailAlbum(Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlbumPage(album: album)),
    );
  }

  // ---------- TAMPILAN ----------
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => cariLaguUser(),
            decoration: InputDecoration(
              hintText: 'Cari judul lagu atau artis',
              border: const OutlineInputBorder(),
              suffixIcon: isSearching
                  ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: kembaliKeHome,
              )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: cariLaguUser,
          child: const Text('Cari'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // kartu lagu (dipakai di baris horizontal)
  Widget _buildSongCard(Song song) {
    return GestureDetector(
      onTap: () => bukaDetailLagu(song),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ubahCover(song.cover, '300x300'),
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 140,
                  height: 140,
                  color: Colors.blue,
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              song.artis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongRow() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: laguPopuler.length,
        itemBuilder: (context, index) {
          return _buildSongCard(laguPopuler[index]);
        },
      ),
    );
  }

  // kartu album (dipakai di grid)
  Widget _buildAlbumCard(Album album) {
    return GestureDetector(
      onTap: () => bukaDetailAlbum(album),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ubahCover(album.cover, '400x400'),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.blue,
                  child: const Icon(Icons.album, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            album.nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            album.artis,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: albumList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return _buildAlbumCard(albumList[index]);
      },
    );
  }

  // tampilan home (sebelum mencari), bisa ditarik untuk refresh
  Widget _buildHomeContent(bool isMobile) {
    return RefreshIndicator(
      onRefresh: () => muatHome(tampilLoading: false),
      child: ListView(
        children: [
          _buildSectionTitle('Lagu Populer'),
          _buildSongRow(),
          _buildSectionTitle('Album'),
          _buildAlbumGrid(isMobile),
        ],
      ),
    );
  }

  // tampilan hasil pencarian
  Widget _buildSearchResult() {
    if (hasilCari.isEmpty) {
      return const Center(child: Text('Lagu tidak ditemukan'));
    }
    return ListView.builder(
      itemCount: hasilCari.length,
      itemBuilder: (context, index) {
        return SongTile(song: hasilCari[index]);
      },
    );
  }

  // tampilan saat gagal memuat data
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('Gagal memuat data. Cek koneksi internet.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isSearching ? cariLaguUser : muatHome,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError) {
      return _buildError();
    }
    if (isSearching) {
      return _buildSearchResult();
    }
    return _buildHomeContent(isMobile);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Music Player'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildBody(isMobile)),
              ],
            ),
          ),
        );
      },
    );
  }
}