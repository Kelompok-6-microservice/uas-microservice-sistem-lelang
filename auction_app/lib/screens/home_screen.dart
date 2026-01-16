import 'dart:async'; // UNTUK TIMER
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/item_model.dart';
import 'detail_auction_screen.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _homeTimer; // Timer untuk update waktu di UI

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AppProvider>(context, listen: false).fetchItems());

    // Timer berjalan setiap 1 detik
    _homeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Menjalankan pengecekan pemenang di Provider
        Provider.of<AppProvider>(context, listen: false).checkLocalWinnerLogic();

        // Memicu build ulang UI agar angka hitung mundur berubah
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _homeTimer?.cancel(); // Hentikan timer saat pindah halaman
    _searchController.dispose();
    super.dispose();
  }

  // --- HELPER: HITUNG SISA WAKTU ---
  String _getRemainingTime(DateTime endTime) {
    final duration = endTime.difference(DateTime.now());
    if (duration.isNegative) return "ENDED";

    if (duration.inDays > 0) {
      return "${duration.inDays}d ${duration.inHours.remainder(24)}h";
    } else if (duration.inHours > 0) {
      return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
    } else if (duration.inMinutes > 0) {
      // TAMPILKAN MENIT & DETIK jika di bawah 1 jam
      return "${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s left";
    } else {
      // TAMPILKAN DETIK SAJA jika di bawah 1 menit
      return "${duration.inSeconds}s left";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Filter pencarian
    final List<Item> filteredItems = _searchQuery.isEmpty
        ? provider.items
        : provider.items.where((item) {
      return item.namaBarang
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    const Color bgBase = Color(0xFFF8F9FD);
    const Color primaryDark = Color(0xFF1A1A2E);
    const Color accentPurple = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: bgBase,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddItemScreen()));
          },
          backgroundColor: accentPurple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Jual Barang",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: accentPurple))
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- APP BAR ---
          SliverAppBar(
            expandedHeight: 140.0,
            pinned: true,
            backgroundColor: bgBase,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: accentPurple),
                const SizedBox(width: 10),
                const Text("Auction Pro",
                    style: TextStyle(
                        color: primaryDark, fontWeight: FontWeight.bold)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10)
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: Icon(Icons.search, color: accentPurple),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- GRID ITEMS ---
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: filteredItems.isEmpty
                ? const SliverToBoxAdapter(
                child: Center(child: Text("Belum ada barang lelang")))
                : SliverGrid(
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAuctionCard(
                    context, filteredItems[index], provider),
                childCount: filteredItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAuctionCard(
      BuildContext context, Item item, AppProvider provider) {
    final currency =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final bool isEnded = item.endTime.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailAuctionScreen(item: item))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                    child: item.isLocalImage
                        ? Image.file(File(item.imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover)
                        : Image.network(item.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: Colors.grey[200])),
                  ),
                  // TIMER BADGE (SESUAI END TIME ASLI)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEnded
                            ? Colors.red.withOpacity(0.8)
                            : Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_filled,
                              color: isEnded ? Colors.white : Colors.amber,
                              size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _getRemainingTime(item.endTime),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // DELETE BUTTON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showDeleteDialog(context, item, provider),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // INFO SECTION
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.namaBarang,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Current Bid",
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currency.format(item.hargaAwal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C63FF))),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A2E),
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Text("Bid",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Item item, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}