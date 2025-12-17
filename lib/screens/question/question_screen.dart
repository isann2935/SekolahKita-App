import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class QuestionScreen extends StatelessWidget {
  final String mode;
  final VoidCallback onBack;
  final Function(bool) onComplete;

  const QuestionScreen({
    super.key,
    required this.mode,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text("Level 3 - Belajar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Question Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softTeal,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.lightbulb, color: AppColors.orange),
                                SizedBox(width: 8),
                                Text("Mari Belajar Penjumlahan!"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.orange,
                                child: const Icon(Icons.volume_up, color: Colors.white, size: 28),
                              ).animate(onPlay: (c) => c.repeat()).shake(delay: 2000.ms),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  "Jika kamu punya 3 Apel dan ditambah 2 Apel, berapa semuanya?",
                                  style: TextStyle(fontSize: 18, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Visual Aid
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6), // Light Yellow
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("🍎🍎🍎 + 🍎🍎 = ❓", style: TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(height: 20),
                          // Mascot Hint
                          Row(
                            children: [
                              const Text("🦉", style: TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.softTeal,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text("Hitung semua apel dari 1 sampai 5!"),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Answer Options
                    const Text("Pilih Jawaban:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _AnswerButton(label: "4", visual: "🍎🍎🍎🍎", onTap: () => onComplete(false)),
                    const SizedBox(height: 12),
                    _AnswerButton(label: "5", visual: "🍎🍎🍎🍎🍎", isCorrect: true, onTap: () => onComplete(true)),
                    const SizedBox(height: 12),
                    _AnswerButton(label: "6", visual: "🍎🍎🍎🍎🍎🍎", onTap: () => onComplete(false)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final String visual;
  final bool isCorrect;
  final VoidCallback onTap;

  const _AnswerButton({required this.label, required this.visual, this.isCorrect = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.softTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 16),
            Text(visual, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}