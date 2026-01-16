import 'dart:ui'; // Untuk ImageFilter (Blur Effect)
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart'; 

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // Daftar Halaman
  final List<Widget> _pages = [
    const HomeScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    final Color primaryColor = const Color(0xFF6C63FF);
    final Color darkNavy = const Color(0xFF1A1A2E);

    return Scaffold(
      // Background body dibuat extend agar efek kaca di bawah terlihat
      extendBody: true, 
      
      // Menggunakan IndexedStack agar halaman tidak reload saat pindah tab
      // (Scroll position di Home tetap tersimpan saat ke Profile)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Custom Floating Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        height: 80, // Tinggi area navbar
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Kaca (Blur)
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85), // Putih transparan
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: darkNavy.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: "Home",
                    color: primaryColor,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.notifications_rounded,
                    label: "Alerts",
                    color: Colors.orange,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_rounded,
                    label: "Profile",
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL NAVIGASI CUSTOM ---
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Durasi animasi
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Icon dengan animasi rotasi sedikit saat dipilih
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: 26,
              ),
            ),
            
            // Teks Label (Muncul hanya jika dipilih)
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
