// FILE INI: tampilan 1 baris lagu (cover, judul, artis).
// Dipakai di hasil pencarian dan daftar favorit supaya tidak menulis kode yang sama dua kali.
// Klik baris -> DetailPage.

import 'package:flutter/material.dart';
import '../models/song.dart';
import '../pages/detail_page.dart';

class SongTile extends StatelessWidget {
  final Song song;
  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          song.cover,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.music_note, color: Colors.blue),
        ),
      ),
      title: Text(song.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artis, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(song: song)),
        );
      },
    );
  }
}