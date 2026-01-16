import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // --- UBAH DEFAULT KE MENIT UNTUK TESTING ---
  final _durationController = TextEditingController(text: "5");

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _submitData() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi data & foto"), backgroundColor: Colors.red));
      return;
    }

    // --- LOGIKA BARU: MENGGUNAKAN MENIT ---
    // Kita ambil inputan user sebagai menit agar demo lebih cepat
    int durationMinutes = int.tryParse(_durationController.text) ?? 5;

    // Hitung End Time: Waktu sekarang + durasi menit
    DateTime calculatedEndTime = DateTime.now().add(Duration(minutes: durationMinutes));

    // Panggil Provider
    Provider.of<AppProvider>(context, listen: false).addItem(
      _nameController.text,
      _descController.text,
      double.tryParse(_priceController.text) ?? 0,
      calculatedEndTime,
      _imageFile!.path,
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang Berhasil Ditambahkan!"), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Jual Barang", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. UPLOAD FOTO ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Upload Foto Barang"),
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. FORM INPUT ---
            _buildLabel("Nama Barang"),
            _buildInput(_nameController, "Contoh: Macbook Pro 2022"),

            const SizedBox(height: 15),
            _buildLabel("Deskripsi"),
            _buildInput(_descController, "Jelaskan kondisi barang...", maxLines: 3),

            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Harga Awal (Rp)"),
                      _buildInput(_priceController, "0", isNumber: true),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- LABEL DIUBAH KE MENIT ---
                      _buildLabel("Durasi Lelang (Menit)"),
                      _buildInput(_durationController, "5", isNumber: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- 3. TOMBOL SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("MULAI LELANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildInput(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }
}