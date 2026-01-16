class Item {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final double hargaAwal;
  final DateTime endTime;
  final String imagePath;
  final bool isLocalImage;

  Item({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.hargaAwal,
    required this.endTime,
    required this.imagePath,
    this.isLocalImage = false,
  });

  // --- UPDATE: FUNGSI BACA JSON DARI API ---
  factory Item.fromJson(Map<String, dynamic> json) {
    String path = json['image_url'] ?? "";

    // LOGIKA: Jika path diawali '/' berarti itu file lokal dari HP
    bool localCheck = path.startsWith('/') || path.startsWith('content://');

    return Item(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? "Tanpa Nama",
      deskripsi: json['deskripsi'] ?? "-",
      hargaAwal: (json['harga_awal'] as num).toDouble(),

      // MENGAMBIL WAKTU ASLI DARI DATABASE
      // Jika dari backend null, default ke 24 jam dari sekarang agar tidak error
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time']).toLocal()
          : DateTime.now().add(const Duration(hours: 24)),

      // MENGAMBIL PATH GAMBAR ASLI DARI DATABASE
      imagePath: path,
      isLocalImage: localCheck,
    );
  }
}