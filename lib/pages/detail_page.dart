// FILE INI: halaman detail lagu.
// Isinya: cover, tombol favorit (hati), PEMUTAR LAGU
// (play/pause, progress bar yang bisa digeser), info lagu, dan lirik.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final Song song;
  const DetailPage({super.key, required this.song});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // lirik
  String lyrics = '';
  bool isLoadingLyrics = true;

  // pemutar lagu
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool sudahMulai = false; // sudah pernah ditekan play atau belum
  Duration posisi = Duration.zero;
  Duration total = Duration.zero;

  @override
  void initState() {
    super.initState();
    muatLirik();
    siapkanPlayer();
  }

  @override
  void dispose() {
    player.dispose(); // supaya lagu berhenti saat keluar halaman
    super.dispose();
  }

  // ---------- PEMUTAR ----------
  void siapkanPlayer() {
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        posisi = p;
      });
    });

    player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        total = d;
      });
    });

    player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        sudahMulai = false;
        posisi = Duration.zero;
      });
    });
  }

  Future<void> putarAtauJeda() async {
    if (widget.song.previewUrl.isEmpty) return;

    if (isPlaying) {
      await player.pause();
    } else if (sudahMulai) {
      await player.resume(); // lanjut dari posisi terakhir
    } else {
      sudahMulai = true;
      await player.play(UrlSource(widget.song.previewUrl));
    }
  }

  // ---------- LIRIK ----------
  Future<void> muatLirik() async {
    final hasil = await ambilLirik(widget.song.artis, widget.song.judul);

    if (!mounted) return;
    setState(() {
      lyrics = hasil.isEmpty ? 'Lirik tidak ditemukan.' : hasil;
      isLoadingLyrics = false;
    });
  }

  // ---------- FORMAT ----------
  String _formatDurasi(int ms) {
    final menit = ms ~/ 60000;
    final detik = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$menit:$detik';
  }

  String _formatWaktu(Duration d) {
    final menit = d.inMinutes;
    final detik = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$menit:$detik';
  }

  // ---------- TAMPILAN ----------
  // tombol hati di AppBar, berubah merah kalau lagu sudah difavoritkan
  Widget _buildTombolFavorit() {
    return ValueListenableBuilder<List<Song>>(
      valueListenable: FavoriteService.daftar,
      builder: (context, daftar, child) {
        final isFavorit = FavoriteService.apakahFavorit(widget.song);
        return IconButton(
          icon: Icon(
            isFavorit ? Icons.favorite : Icons.favorite_border,
            color: isFavorit ? Colors.red : Colors.white,
          ),
          onPressed: () => FavoriteService.toggle(widget.song),
        );
      },
    );
  }

  Widget _buildCover() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          ubahCover(widget.song.cover, '600x600'),
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.music_note, size: 100, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final adaPreview = widget.song.previewUrl.isNotEmpty;
    final maxMs = total.inMilliseconds > 0 ? total.inMilliseconds : 1;
    final nilaiMs = posisi.inMilliseconds.clamp(0, maxMs);

    return Column(
      children: [
        const SizedBox(height: 16),
        Slider(
          min: 0,
          max: maxMs.toDouble(),
          value: nilaiMs.toDouble(),
          activeColor: Colors.blue,
          // slider baru bisa digeser setelah lagu mulai diputar
          onChanged: total.inMilliseconds > 0
              ? (nilai) => player.seek(Duration(milliseconds: nilai.toInt()))
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatWaktu(posisi)),
            Text(_formatWaktu(total)),
          ],
        ),
        IconButton(
          iconSize: 64,
          color: Colors.blue,
          onPressed: adaPreview ? putarAtauJeda : null,
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          ),
        ),
        Text(
          adaPreview ? 'Preview 30 detik' : 'Preview tidak tersedia',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final song = widget.song;
    final tanggalRilis =
    song.rilis.length >= 10 ? song.rilis.substring(0, 10) : song.rilis;

    return Column(
      children: [
        _buildInfoRow('Judul', song.judul),
        _buildInfoRow('Artis', song.artis),
        _buildInfoRow('Album', song.album),
        _buildInfoRow('Genre', song.genre),
        _buildInfoRow('Rilis', tanggalRilis),
        _buildInfoRow('Durasi', _formatDurasi(song.durasiMs)),
        _buildInfoRow('Negara', song.negara),
      ],
    );
  }

  Widget _buildLyrics() {
    if (isLoadingLyrics) {
      return const Center(child: CircularProgressIndicator());
    }
    return Text(lyrics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.judul),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [_buildTombolFavorit()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            _buildPlayer(),
            const Divider(height: 32),
            _buildInfo(),
            const Divider(height: 32),
            const Text(
              'Lirik',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLyrics(),
          ],
        ),
      ),
    );
  }
}