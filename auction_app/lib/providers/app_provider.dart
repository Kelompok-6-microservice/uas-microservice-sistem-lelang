import 'dart:convert';
import 'package:auction_app/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/notification_model.dart';

class UserProfile {
  final String name;
  final String email;
  final String bio;
  final String photoUrl;
  final bool isLocalPhoto;

  UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    required this.photoUrl,
    this.isLocalPhoto = false,
  });
}

class AppProvider with ChangeNotifier {
  List<Item> _items = [];
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  // Tracking barang yang sudah diproses notifikasinya
  final Set<int> _notifiedItems = {};

  UserProfile _user = UserProfile(
    name: "Guest User",
    email: "guest@auction.com",
    bio: "Auction Enthusiast",
    photoUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix",
    isLocalPhoto: false,
  );

  List<Item> get items => _items;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  UserProfile get user => _user;

  final String userServiceUrl = "http://10.0.2.2:8001";
  final String itemServiceUrl = "http://10.0.2.2:8002";
  final String biddingServiceUrl = "http://10.0.2.2:8003";
  final String notifServiceUrl = "http://10.0.2.2:8004";

  // ==========================================
  // HELPER: NOTIFIKASI LOKAL & PENGHAPUSAN
  // ==========================================
  void _addLocalNotification(String message, String type) {
    _notifications.insert(0, AppNotification(message: message, type: type));
    notifyListeners();
  }

  void deleteNotification(int index) {
    _notifications.removeAt(index);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // ==========================================
  // LOGIKA: CEK PEMENANG OTOMATIS
  // ==========================================
  Future<void> checkLocalWinnerLogic() async {
    final now = DateTime.now();

    for (var item in _items) {
      if (item.endTime.isBefore(now) && !_notifiedItems.contains(item.id)) {
        _notifiedItems.add(item.id);

        try {
          List<Bid> bids = await getBidsForItem(item.id);

          if (bids.isNotEmpty) {
            bids.sort((a, b) => b.tawaranHarga.compareTo(a.tawaranHarga));
            final winner = bids.first;

            _addLocalNotification(
                "Lelang ${item.namaBarang} SELESAI! Pemenang: User ${winner.userId} senilai Rp ${winner.tawaranHarga}",
                "win"
            );
          } else {
            _addLocalNotification(
                "Lelang ${item.namaBarang} SELESAI tanpa ada penawar.",
                "system"
            );
          }
        } catch (e) {
          print("Error logic winner: $e");
        }
      }
    }
  }

  // ==========================================
  // 1. AUTH SERVICE
  // ==========================================
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Reset state saat login baru agar tidak duplikat dengan akun lama
      _notifications = [];
      _notifiedItems.clear();

      final response = await http.post(
        Uri.parse('$userServiceUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['user'];

        _user = UserProfile(
          name: userData['name'] ?? "User",
          email: userData['email'] ?? email,
          bio: "Auction Member",
          photoUrl: userData['foto'] ?? "https://i.pravatar.cc/300",
          isLocalPhoto: (userData['foto'] != null && userData['foto'].startsWith('/')),
        );

        // GANTI KE 'wallet' BIAR WARNA BIRU & LOGO CERAH
        _addLocalNotification("Selamat datang kembali, ${_user.name}! Selamat berburu barang impian.", "wallet");

        notifyListeners();
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, String photoPath) async {
    _isLoading = true;
    notifyListeners();
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$userServiceUrl/register'));
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['foto'] = photoPath;

      var response = await request.send();
      if (response.statusCode == 201) {
        _addLocalNotification("Registrasi berhasil! Silakan login untuk memulai.", "wallet");
      }
    } catch (e) {
      print("Register Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(String newName, String newBio, {String? newPhotoPath}) {
    _user = UserProfile(
      name: newName,
      email: _user.email,
      bio: newBio,
      photoUrl: newPhotoPath ?? _user.photoUrl,
      isLocalPhoto: newPhotoPath != null ? true : _user.isLocalPhoto,
    );
    // GANTI KE 'wallet' AGAR LEBIH CERAH (BIRU)
    _addLocalNotification("Profil Anda berhasil diperbarui!", "wallet");
    notifyListeners();
  }

  // ==========================================
  // 2. ITEM SERVICE
  // ==========================================
  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$itemServiceUrl/items'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final now = DateTime.now();

        _items = data.map((json) {
          final item = Item.fromJson(json);
          // Jika barang sudah expired sebelum fetch, masukkan ke blacklist notif
          if (item.endTime.isBefore(now)) {
            _notifiedItems.add(item.id);
          }
          return item;
        }).toList();
      }
    } catch (e) {
      print("Fetch Items Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(String name, String desc, double price, DateTime endTime, String image) async {
    final response = await http.post(
      Uri.parse('$itemServiceUrl/items'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nama_barang": name,
        "deskripsi": desc,
        "harga_awal": price,
        "owner_id": 1,
        "image_url": image,
        "end_time": endTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      _addLocalNotification("Barang '$name' siap dilelang!", "wallet");
      fetchItems();
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await http.delete(Uri.parse('$itemServiceUrl/items/$id'));
      _items.removeWhere((item) => item.id == id);
      _addLocalNotification("Barang telah dihapus.", "system");
      notifyListeners();
    } catch (e) {
      print("Delete Error: $e");
    }
  }

  // ==========================================
  // 3. NOTIFICATION SERVICE
  // ==========================================
  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('$notifServiceUrl/notifications'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        List<dynamic> rawData = decodedData['data'] ?? [];

        final remoteNotifs = rawData.map((msg) => AppNotification.fromRedis(msg)).toList();
        _notifications.addAll(remoteNotifs);

        notifyListeners();
      }
    } catch (e) {
      print("Gagal ambil notif: $e");
    }
  }

  // ==========================================
  // 4. BIDDING SERVICE
  // ==========================================
  Future<List<Bid>> getBidsForItem(int itemId) async {
    try {
      final response = await http.get(Uri.parse('$biddingServiceUrl/bid/item/$itemId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((b) => Bid.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addBid(int itemId, int userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$biddingServiceUrl/bid'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "item_id": itemId,
          "user_id": userId,
          "tawaran_harga": amount,
        }),
      );

      if (response.statusCode == 201) {
        _addLocalNotification("Berhasil! Penawaran Rp $amount diajukan.", "outbid");
        fetchItems();
      } else {
        throw Exception("Gagal mengirim penawaran");
      }
    } catch (e) {
      _addLocalNotification("Gagal mengirim Bid. Periksa koneksi.", "system");
      rethrow;
    }
  }
}