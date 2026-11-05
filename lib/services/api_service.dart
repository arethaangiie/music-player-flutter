// FILE INI: semua request ke internet (API).
// - cariLagu / cariAlbum / ambilLaguAlbum : data dari iTunes
// - ambilLirik : lirik dari LRCLIB
// - ubahCover  : memperbesar ukuran gambar cover
// Kalau request gagal, fungsi melempar Exception.
// Halaman yang memanggil menangkapnya lalu menampilkan pesan error.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/album.dart';

// fungsi dasar: ambil data iTunes dan cek status code
Future<List> _ambil(String path, Map<String, String> params) async {
  final url = Uri.https('itunes.apple.com', path, params);
  final response = await http.get(url).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('HTTP Error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return data['results'] ?? [];
}

// cari lagu berdasarkan kata kunci (judul / artis)
Future<List<Song>> cariLagu(String kata, {int limit = 25}) async {
  final hasil = await _ambil('search', {
    'term': kata,
    'entity': 'song',
    'limit': limit.toString(),
  });
  return hasil.map((e) => Song.fromJson(e)).toList();
}

// cari album berdasarkan kata kunci
Future<List<Album>> cariAlbum(String kata, {int limit = 12}) async {
  final hasil = await _ambil('search', {
    'term': kata,
    'entity': 'album',
    'limit': limit.toString(),
  });
  return hasil.map((e) => Album.fromJson(e)).toList();
}

// ambil semua lagu di dalam 1 album
Future<List<Song>> ambilLaguAlbum(int albumId) async {
  final hasil = await _ambil('lookup', {
    'id': albumId.toString(),
    'entity': 'song',
  });
  // item pertama adalah data albumnya, sisanya lagu
  return hasil
      .where((e) => e['wrapperType'] == 'track')
      .map((e) => Song.fromJson(e))
      .toList();
}

// ambil lirik dari LRCLIB, kalau tidak ada hasilnya string kosong
Future<String> ambilLirik(String artis, String judul) async {
  final url = Uri.https('lrclib.net', 'api/get', {
    'artist_name': artis,
    'track_name': judul,
  });
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['plainLyrics'] ?? '';
    }
  } catch (e) {
    return '';
  }
  return '';
}

// ubah ukuran cover supaya lebih tajam (contoh: 100x100 jadi 600x600)
String ubahCover(String url, String ukuran) {
  return url.replaceAll('100x100', ukuran);
}