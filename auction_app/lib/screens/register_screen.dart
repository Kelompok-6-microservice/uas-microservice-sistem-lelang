import 'dart:io'; // 1. WAJIB: Untuk menangani file gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 2. WAJIB: Plugin kamera/galeri
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;
  bool _agreedToTerms = false;

  // --- 3. VARIABEL FOTO ---
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 4. FUNGSI AMBIL FOTO DARI GALERI ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Palet Warna
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color darkNavy = const Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // --- BACKGROUND DECORATION ---
          Positioned(
            top: -50, left: -50,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
          ),
          Positioned(
            top: 50, right: -20,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
          ),

          // --- MAIN CONTENT ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // HEADER & BACK BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Join the exclusive auction community",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // WHITE SHEET FORM
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // --- 5. UI UPLOAD FOTO ---
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                                  image: _imageFile != null
                                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: _imageFile == null
                                    ? Icon(Icons.person_rounded, size: 60, color: Colors.grey.shade300)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.add_a_photo, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Tap to upload photo", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),

                        const SizedBox(height: 30),

                        // FULL NAME
                        Align(alignment: Alignment.centerLeft, child: _buildLabel("Full Name")),
                        _buildInputField(
                          controller: _nameController,
                          icon: Icons.person_outline_rounded,
                          hint: "John Doe",
                        ),
                        const SizedBox(height: 20),

                        // EMAIL
                        Align(alignment: Alignment.centerLeft, child: _buildLabel("Email Address")),
                        _buildInputField(
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hint: "example@email.com",
                        ),
                        const SizedBox(height: 20),

                        // PASSWORD
                        Align(alignment: Alignment.centerLeft, child: _buildLabel("Password")),
                        _buildInputField(
                          controller: _passwordController,
                          icon: Icons.lock_outline_rounded,
                          hint: "••••••••",
                          isPassword: true,
                          isObscure: _isPasswordObscure,
                          onToggleVisibility: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
                        ),
                        const SizedBox(height: 20),

                        // CONFIRM PASSWORD
                        Align(alignment: Alignment.centerLeft, child: _buildLabel("Confirm Password")),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          icon: Icons.lock_reset_rounded,
                          hint: "••••••••",
                          isPassword: true,
                          isObscure: _isConfirmObscure,
                          onToggleVisibility: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                        ),

                        const SizedBox(height: 25),

                        // TERMS CHECKBOX
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                activeColor: primaryColor,
                                value: _agreedToTerms,
                                onChanged: (val) => setState(() => _agreedToTerms = val!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  children: [
                                    const TextSpan(text: "I agree to the "),
                                    TextSpan(text: "Terms of Service", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                    const TextSpan(text: " and "),
                                    TextSpan(text: "Privacy Policy", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _handleRegister,
                            child: const Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // LOGIN LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text("Login", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 6. UPDATE LOGIC REGISTER (SEKARANG MENGIRIM PASSWORD) ---
  void _handleRegister() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please agree to the terms first."), backgroundColor: Colors.red));
      return;
    }

    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields."), backgroundColor: Colors.red));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red));
      return;
    }

    // Default foto jika user tidak upload: gambar dummy internet
    String photoPath = _imageFile?.path ?? "https://i.pravatar.cc/300";

    // PENTING: Sekarang mengirim 4 parameter sesuai update di AppProvider
    Provider.of<AppProvider>(context, listen: false).register(
        _nameController.text,
        _emailController.text,
        _passwordController.text, // <--- Menambahkan password asli dari inputan
        photoPath
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created! Please Login."), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy, fontSize: 14)),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required IconData icon, required String hint, bool isPassword = false, bool isObscure = false, VoidCallback? onToggleVisibility}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: isPassword ? IconButton(icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey), onPressed: onToggleVisibility) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}