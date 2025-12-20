import 'package:flutter/material.dart';
import '../theme/colors.dart';

class DifficultyModal extends StatelessWidget {
  final Function(String) onSelect;
  const DifficultyModal({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan ScrollView agar aman di layar kecil
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SafeArea(
          // Tambahan SafeArea untuk HP berponi/notch
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar (Garis kecil di atas modal)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text("🎮", style: TextStyle(fontSize: 50)),
              const Text(
                "Pilih Mode",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Mau belajar cara apa hari ini?",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _ModeButton(
                title: "Mudah",
                subtitle: "Mode mudah dengan panduan",
                color: AppColors.green,
                icon: Icons.lightbulb_rounded,
                onTap: () => onSelect('mudah'),
              ),
              const SizedBox(height: 12),
              _ModeButton(
                title: "Sulit",
                subtitle: "+50% Bintang",
                color: AppColors.orange,
                icon: Icons.flash_on_rounded,
                onTap: () => onSelect('sulit'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // Menambahkan shadow tipis agar tombol lebih pop-up
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              // Expanded mencegah teks panjang menabrak kanan
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
