import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // WAJIB ADA
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  bool isEditing = false;

  // --- 1. VARIABEL UNTUK FOTO BARU ---
  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _emailController = TextEditingController(text: user.email);
  }

  // --- 2. FUNGSI AMBIL FOTO ---
  Future<void> _pickImage() async {
    if (!isEditing) return; // Hanya bisa ganti foto kalau lagi mode EDIT
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  final Color primaryColor = const Color(0xFF6C63FF);
  final Color darkNavy = const Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (isEditing) {
              // --- 3. SIMPAN PERUBAHAN (TERMASUK FOTO JIKA ADA) ---
              provider.updateProfile(
                _nameController.text,
                _bioController.text,
                newPhotoPath: _newImageFile?.path, // Kirim path foto baru jika ada
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
              );
              _newImageFile = null; // Reset temp image setelah simpan
            }
            setState(() => isEditing = !isEditing);
          },
          backgroundColor: isEditing ? Colors.green : primaryColor,
          icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
          label: Text(isEditing ? "SAVE" : "EDIT", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                // --- 4. AREA FOTO PROFIL (BISA DI-TAP) ---
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Color(0xFFF8F9FD), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            // Logika Gambar: Prioritas foto baru yang baru dipilih, lalu foto dari provider
                            backgroundImage: _newImageFile != null
                                ? FileImage(_newImageFile!) as ImageProvider
                                : (user.photoUrl.startsWith('/') || user.photoUrl.startsWith('content')
                                ? FileImage(File(user.photoUrl)) as ImageProvider
                                : NetworkImage(user.photoUrl)),
                          ),
                        ),
                        // Badge Kamera (hanya muncul saat mode edit)
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkNavy)),
            // ... (sisa widget statistik dan form di bawah tetap sama)
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
              child: const Text("Gold Member", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard("Wallet", "Rp 12.5jt", Icons.account_balance_wallet, Colors.blue),
                  const SizedBox(width: 10),
                  _buildStatCard("Bids", "3 Items", Icons.gavel, Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard("Won", "12", Icons.emoji_events, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildInputField("Full Name", Icons.person, _nameController, isEditing),
                    const Divider(height: 30),
                    _buildInputField("Email", Icons.email, _emailController, false),
                    const Divider(height: 30),
                    _buildInputField("Bio", Icons.info, _bioController, isEditing),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text("LOG OUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // (Tetap gunakan widget _buildStatCard dan _buildInputField kamu yang lama)
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, bool enabled) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              enabled
                  ? TextField(
                controller: controller,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              )
                  : Text(controller.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}