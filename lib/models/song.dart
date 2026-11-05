// FILE INI: model data untuk 1 lagu.
// fromJson : mengubah JSON dari iTunes menjadi object Song
// toJson   : mengubah Song kembali ke JSON (dipakai untuk menyimpan favorit)

class Song {
  final int id;
  final String judul;
  final String artis;
  final String album;
  final int albumId;
  final String genre;
  final String rilis;
  final int durasiMs;
  final String negara;
  final String cover;
  final String previewUrl;
  final int trackNumber;

  Song({
    required this.id,
    required this.judul,
    required this.artis,
    required this.album,
    required this.albumId,
    required this.genre,
    required this.rilis,
    required this.durasiMs,
    required this.negara,
    required this.cover,
    required this.previewUrl,
    required this.trackNumber,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['trackId'] ?? 0,
      judul: json['trackName'] ?? '-',
      artis: json['artistName'] ?? '-',
      album: json['collectionName'] ?? '-',
      albumId: json['collectionId'] ?? 0,
      genre: json['primaryGenreName'] ?? '-',
      rilis: json['releaseDate'] ?? '-',
      durasiMs: json['trackTimeMillis'] ?? 0,
      negara: json['country'] ?? '-',
      cover: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      trackNumber: json['trackNumber'] ?? 0,
    );
  }

  // memakai nama key yang sama dengan iTunes, jadi bisa dibaca lagi lewat fromJson
  Map<String, dynamic> toJson() {
    return {
      'trackId': id,
      'trackName': judul,
      'artistName': artis,
      'collectionName': album,
      'collectionId': albumId,
      'primaryGenreName': genre,
      'releaseDate': rilis,
      'trackTimeMillis': durasiMs,
      'country': negara,
      'artworkUrl100': cover,
      'previewUrl': previewUrl,
      'trackNumber': trackNumber,
    };
  }
}