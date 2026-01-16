import 'dart:async'; // WAJIB ADA: Untuk Timer
import 'dart:io';
import 'package:auction_app/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/bid_model.dart';

class DetailAuctionScreen extends StatefulWidget {
  final Item item;
  const DetailAuctionScreen({super.key, required this.item});

  @override
  State<DetailAuctionScreen> createState() => _DetailAuctionScreenState();
}

class _DetailAuctionScreenState extends State<DetailAuctionScreen> {
  List<Bid> bids = [];
  final _bidController = TextEditingController();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // --- 1. VARIABEL TIMER ---
  Timer? _timer;
  Duration remainingTime = Duration.zero;
  bool isEnded = false;

  // Palet Warna Premium
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color darkNavy = const Color(0xFF1A1A2E);
  final Color accentGold = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    fetchBidsFromServer();
    startTimer(); 
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _bidController.dispose();
    super.dispose();
  }

  // --- 2. LOGIKA TIMER ---
  void startTimer() {
    remainingTime = widget.item.endTime.difference(DateTime.now());

    if (remainingTime.isNegative) {
      isEnded = true;
      remainingTime = Duration.zero;
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          final seconds = remainingTime.inSeconds - 1;
          if (seconds <= 0) {
            _timer?.cancel();
            remainingTime = Duration.zero;
            isEnded = true;
            _showWinnerDialog();
          } else {
            remainingTime = Duration(seconds: seconds);
          }
        });
      });
    }
  }

  String get timerString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(remainingTime.inHours);
    final minutes = twoDigits(remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(remainingTime.inSeconds.remainder(60));
    return "$hours : $minutes : $seconds";
  }

  void _showWinnerDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("🏆 AUCTION ENDED", style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: accentGold.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(Icons.emoji_events, size: 60, color: accentGold),
            ),
            const SizedBox(height: 20),
            const Text("Winner:", style: TextStyle(color: Colors.grey)),
            Text(
              "User ID ${bids.isNotEmpty ? bids.first.userId : '-'}", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              "Final Price: ${currency.format(bids.isNotEmpty ? bids.first.tawaranHarga : widget.item.hargaAwal)}", 
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  // --- LOGIKA DUMMY BIDDING ---
  Future<void> fetchBidsFromServer() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // 1. Ambil data asli dari MongoDB (Node.js)
      final latestBids = await provider.getBidsForItem(widget.item.id);

      // 2. Buat data dummy untuk marketing/pemancing
      // Kita buat harganya bertahap di bawah harga awal atau sedikit di atasnya
      List<Bid> marketingBids = [
        Bid(
            userId: 105,
            tawaranHarga: widget.item.hargaAwal + 50000,
            waktu: DateTime.now().subtract(const Duration(minutes: 30))
        ),
        Bid(
            userId: 102,
            tawaranHarga: widget.item.hargaAwal + 20000,
            waktu: DateTime.now().subtract(const Duration(minutes: 45))
        ),
        Bid(
            userId: 103,
            tawaranHarga: widget.item.hargaAwal + 10000,
            waktu: DateTime.now().subtract(const Duration(hours: 1))
        ),
      ];

      setState(() {
        // 3. Gabungkan: Data asli dari DB di depan, lalu data dummy di belakang
        // Kita pakai spread operator (...) untuk menggabungkan list
        bids = [...latestBids, ...marketingBids];

        // 4. Opsional: Urutkan berdasarkan harga tertinggi agar tetap rapi
        bids.sort((a, b) => b.tawaranHarga.compareTo(a.tawaranHarga));
      });
    } catch (e) {
      print("Gagal mengambil data bid: $e");
    }
  }

  void placeBid() async { // Tambahkan async
    if (isEnded) return;

    double amount = double.tryParse(_bidController.text) ?? 0;
    if (amount <= 0) return;

    double currentHighest = bids.isNotEmpty ? bids.first.tawaranHarga : widget.item.hargaAwal;
    if (amount <= currentHighest) {
      // ... SnackBar error tetap sama ...
      return;
    }

    // --- LOGIKA REAL (Kirim ke Backend) ---
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // Asumsi di AppProvider kamu sudah buat fungsi addBid
      await provider.addBid(
          widget.item.id,
          101, // Ganti dengan ID User yang sedang login
          amount
      );

      // Refresh list bid dari server agar datanya sinkron
      fetchBidsFromServer();

      _bidController.clear();
      FocusManager.instance.primaryFocus?.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid Placed Successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place bid: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String getImageUrl(int id) => "https://picsum.photos/seed/$id/800/800";

  @override
  Widget build(BuildContext context) {
    double currentPrice = bids.isNotEmpty ? bids.first.tawaranHarga : widget.item.hargaAwal;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. HEADER IMAGE & NAVBAR ---
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: primaryColor,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glass effect
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // PAKAI LOGIKA INI:
                      widget.item.isLocalImage
                          ? Image.file(
                        File(widget.item.imagePath),
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        widget.item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
                      ),
                      // Gradient Overlay Bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),
                      ),
                      // Live Badge
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 10)],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 6),
                              Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. MAIN CONTENT ---
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -30, 0), // Overlap effect
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40, height: 4,
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title & Stats
                        Text(widget.item.namaBarang, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkNavy, height: 1.2)),
                        const SizedBox(height: 10),
                        
                        // Stats Row
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text("1.2k views", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(width: 15),
                            Icon(Icons.gavel, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text("${bids.length} Bids", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // TIMER & PRICE CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isEnded ? Colors.grey.shade100 : const Color(0xFFFFF0F0), // Red tint background
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isEnded ? Colors.transparent : Colors.red.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Current Highest Bid", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    currency.format(currentPrice), 
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor)
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isEnded ? Colors.grey : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(isEnded ? "ENDED" : "ENDS IN", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text(
                                      isEnded ? "--:--" : timerString, 
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // DESCRIPTION
                        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 10),
                        Text(
                          widget.item.deskripsi, 
                          style: TextStyle(color: Colors.grey.shade600, height: 1.6, fontSize: 15),
                        ),

                        const Divider(height: 50),

                        // BID HISTORY TITLE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Live Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Text("● Real-time", style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 3. BID LIST ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bid = bids[index];
                      final isTopBid = index == 0;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isTopBid ? Colors.amber.shade50 : Colors.white, // Highlight Winner
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTopBid ? Colors.amber : Colors.grey.shade100,
                            width: isTopBid ? 1.5 : 1
                          ),
                          boxShadow: [
                            if (isTopBid) BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                            if (!isTopBid) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 45, height: 45,
                              decoration: BoxDecoration(
                                color: isTopBid ? Colors.amber : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTopBid ? Icons.emoji_events_rounded : Icons.person_rounded,
                                color: isTopBid ? Colors.white : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTopBid ? "Highest Bidder (You?)" : "User ${bid.userId}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy),
                                  ),
                                  Text(DateFormat("HH:mm:ss").format(bid.waktu), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            
                            // Price
                            Text(
                              currency.format(bid.tawaranHarga),
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16,
                                color: isTopBid ? const Color(0xFFD32F2F) : primaryColor
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: bids.length,
                  ),
                ),
              ),
            ],
          ),

          // --- 4. FLOATING BOTTOM BAR (Input) ---
          if (!isEnded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: "Enter bid amount...",
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.attach_money, size: 20),
                            ),
                            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: placeBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                        ),
                        child: const Text("Place Bid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // --- BANNER ENDED ---
          if (isEnded)
             Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkNavy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_rounded, color: Colors.white70),
                    SizedBox(width: 10),
                    Text("Auction Closed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
