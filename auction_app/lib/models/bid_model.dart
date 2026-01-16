class Bid {
  final int userId;
  final double tawaranHarga;
  final DateTime waktu;

  Bid({required this.userId, required this.tawaranHarga, required this.waktu});

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      userId: json['user_id'],
      tawaranHarga: (json['tawaran_harga'] as num).toDouble(),
      waktu: DateTime.parse(json['waktu']),
    );
  }
}
