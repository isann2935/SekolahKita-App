import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(String) onStart;
  const OnboardingScreen({super.key, required this.onStart});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      // SafeArea menjaga agar tidak tertutup poni HP
      body: SafeArea(
        // 1. Center: Agar konten tetap di tengah saat keyboard tertutup
        child: Center(
          // 2. SingleChildScrollView: Agar bisa discroll saat keyboard muncul
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO BESAR ---
                  Container(
                    height: 250, 
                    width: 250, 
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1), 
                    end: const Offset(1.05, 1.05),
                    duration: 2000.ms, 
                    curve: Curves.easeInOut,
                  ),

                  const SizedBox(height: 30),
                  
                  const Text(
                    "Selamat Datang!",
                    textAlign: TextAlign.center, // Jaga-jaga kalau teks kepanjangan
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Mari belajar bersama",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // --- INPUT NAMA ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12, 
                          blurRadius: 10, 
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Tulis namamu di sini...",
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // --- TOMBOL MULAI ---
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          widget.onStart(_controller.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Isi namamu dulu ya! 😊")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Mulai Petualangan!", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  // Tambahan jarak di bawah agar tidak terlalu mepet keyboard
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}