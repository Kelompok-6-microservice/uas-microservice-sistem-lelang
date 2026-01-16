import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'main_nav_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller - Kosongkan defaultnya agar user harus input
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false; // State untuk loading

  // --- FUNGSI LOGIN ---
  Future<void> _handleLogin() async {
    // .trim() sangat penting untuk menghapus spasi tak sengaja
    final email = userController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // Proses login ke backend
      await provider.login(email, password);

      // Jika kode sampai di sini, berarti login() di provider tidak melempar error
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavScreen())
        );
      }
    } catch (e) {
      // Jika password salah atau user tidak ditemukan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal: Akun tidak ditemukan atau password salah"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C63FF);
    const Color darkNavy = Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(
            top: -50, left: -50,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
          ),
          Positioned(
            top: 100, right: -30,
            child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.gavel_rounded, size: 30, color: primaryColor),
                    ),
                    const SizedBox(height: 20),
                    const Text("Welcome Back,", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Text("Ready to place your bid?", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 40),

                        const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy)),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: userController,
                          icon: Icons.email_outlined,
                          hint: "example@mail.com",
                          primaryColor: primaryColor,
                        ),

                        const SizedBox(height: 25),

                        const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: darkNavy)),
                        const SizedBox(height: 10),
                        _buildInputField(
                          controller: passwordController,
                          icon: Icons.lock_outline_rounded,
                          hint: "Enter your password",
                          primaryColor: primaryColor,
                          isPassword: true,
                          isObscure: _isObscure,
                          onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () {}, child: const Text("Forgot Password?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600))),
                        ),

                        const SizedBox(height: 20),

                        // BUTTON LOGIN DENGAN LOADING STATE
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),

                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text("Sign Up", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required Color primaryColor,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: isPassword
              ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggleVisibility)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}