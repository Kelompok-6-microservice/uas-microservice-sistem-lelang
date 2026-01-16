import 'package:auction_app/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AppProvider>(context, listen: false).fetchNotifications());
  }

  Map<String, dynamic> _getNotificationStyle(AppNotification notif) {
    switch (notif.type) {
      case 'win':
        return {
          'title': "WINNER!",
          'color': Colors.green.shade700,
          'icon': Icons.emoji_events_rounded,
          'bg': Colors.green.shade50
        };
      case 'outbid':
        return {
          'title': "DISALIP!",
          'color': Colors.orange.shade800,
          'icon': Icons.trending_down_rounded,
          'bg': Colors.orange.shade50
        };
      case 'wallet':
        return {
          'title': "INFO AKUN",
          'color': Colors.blue.shade700,
          'icon': Icons.account_balance_wallet_rounded,
          'bg': Colors.blue.shade50
        };
      case 'system':
        return {
          'title': "SISTEM",
          'color': Colors.red.shade700,
          'icon': Icons.warning_amber_rounded,
          'bg': Colors.red.shade50
        };
      default:
        return {
          'title': "INFO LELANG",
          'color': const Color(0xFF6C63FF),
          'icon': Icons.notifications_active_rounded,
          'bg': const Color(0xFFEDE7F6)
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // TOMBOL HAPUS SEMUA
          Consumer<AppProvider>(
            builder: (context, provider, _) => provider.notifications.isNotEmpty
                ? IconButton(
              onPressed: () => _showDeleteAllDialog(context, provider),
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
            )
                : const SizedBox(),
          ),
          IconButton(
            onPressed: () => Provider.of<AppProvider>(context, listen: false)
                .fetchNotifications(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: const Color(0xFF6C63FF),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final AppNotification notif = provider.notifications[index];
                final style = _getNotificationStyle(notif);

                // --- GESTURE DETECTOR UNTUK LONG PRESS ---
                return GestureDetector(
                  onLongPress: () => _showDeleteSingleDialog(context, provider, index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: style['bg'],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(style['icon'], color: style['color'], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      style['title'] ?? "INFO LELANG",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: style['color'],
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text("Tadi",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade400)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif.message,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A2E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // DIALOG HAPUS SATU
  void _showDeleteSingleDialog(BuildContext context, AppProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Notifikasi?"),
        content: const Text("Ingin menghapus pesan ini dari riwayat?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              provider.deleteNotification(index);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // DIALOG HAPUS SEMUA
  void _showDeleteAllDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Bersihkan Semua?"),
        content: const Text("Semua riwayat notifikasi akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              provider.clearAllNotifications();
              Navigator.pop(ctx);
            },
            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Icon(Icons.notifications_off_outlined,
                  size: 70, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 25),
            const Text(
              "Belum Ada Notifikasi",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 10),
            Text(
              "Tarik layar ke bawah untuk cek pesan\natau lakukan aksi lelang.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}