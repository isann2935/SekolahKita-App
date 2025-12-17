import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';

class FeedbackPopup extends StatelessWidget {
  final VoidCallback onClose;
  const FeedbackPopup({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎉", style: TextStyle(fontSize: 80))
                .animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 16),
            const Text("Kerja Bagus!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Kamu berhasil menjawab!", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 48, color: AppColors.orange).animate().slideY(begin: 1, end: 0),
                const Icon(Icons.star, size: 64, color: AppColors.orange).animate(delay: 100.ms).slideY(begin: 1, end: 0),
                const Icon(Icons.star, size: 48, color: AppColors.orange).animate(delay: 200.ms).slideY(begin: 1, end: 0),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Lanjut Belajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}