// FILE INI: model data untuk 1 album.
// fromJson mengubah JSON dari iTunes menjadi object Album.

class Album {
  final int id;
  final String nama;
  final String artis;
  final String genre;
  final int jumlahLagu;
  final String cover;

  Album({
    required this.id,
    required this.nama,
    required this.artis,
    required this.genre,
    required this.jumlahLagu,
    required this.cover,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['collectionId'] ?? 0,
      nama: json['collectionName'] ?? '-',
      artis: json['artistName'] ?? '-',
      genre: json['primaryGenreName'] ?? '-',
      jumlahLagu: json['trackCount'] ?? 0,
      cover: json['artworkUrl100'] ?? '',
    );
  }
}