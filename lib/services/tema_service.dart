// FILE INI: menyimpan status tema (terang / gelap).
// Diubah dari ProfilePage, dibaca oleh MyApp di main.dart.

import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.light);