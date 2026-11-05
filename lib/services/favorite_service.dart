// FILE INI: mengelola lagu favorit.
// - Disimpan di HP memakai shared_preferences, jadi tetap ada setelah app ditutup
// - daftar adalah ValueNotifier: setiap berubah, halaman yang
//   memakainya (Favorit, Profil, tombol hati) otomatis ikut update

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class FavoriteService {
  static final ValueNotifier<List<Song>> daftar = ValueNotifier([]);
  static const String _kunci = 'lagu_favorit';

  // dipanggil sekali saat app dibuka (lihat main.dart)
  static Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_kunci) ?? [];
    daftar.value = data.map((e) => Song.fromJson(jsonDecode(e))).toList();
  }

  static bool apakahFavorit(Song song) {
    return daftar.value.any((e) => e.id == song.id);
  }

  // tambah ke favorit kalau belum ada, hapus kalau sudah ada
  static Future<void> toggle(Song song) async {
    final list = List<Song>.from(daftar.value);

    if (apakahFavorit(song)) {
      list.removeWhere((e) => e.id == song.id);
    } else {
      list.add(song);
    }

    daftar.value = list;
    await _simpan();
  }

  static Future<void> _simpan() async {
    final prefs = await SharedPreferences.getInstance();
    final data = daftar.value.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_kunci, data);
  }
}