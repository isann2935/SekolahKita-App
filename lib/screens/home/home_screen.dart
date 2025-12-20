import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final int stars;
  final String currentFace;
  final String? equippedHat;
  final String? equippedGlasses;
  final Function(String) onSubjectSelect;
  
  // Data Progress dari MainWrapper
  final Map<String, int> subjectProgress; 

  const HomeScreen({
    super.key,
    required this.userName,
    required this.stars,
    required this.currentFace,
    required this.equippedHat,
    required this.equippedGlasses,
    required this.onSubjectSelect,
    required this.subjectProgress,
  });

  // --- LOGIKA HITUNG PERSENTASE (PERBAIKAN) ---
  double _calculateProgress(String subject) {
    // 1. Ambil level yang sudah selesai di masing-masing mode
    int easyLevel = subjectProgress["${subject}_mudah"] ?? 0;
    int hardLevel = subjectProgress["${subject}_sulit"] ?? 0;
    
    // 2. Jumlahkan total level yang selesai
    // Misal: Selesai Level 1 Mudah (1) + Belum main Sulit (0) = 1
    // Misal: Selesai Level 5 Mudah (5) + Level 2 Sulit (2) = 7
    int totalCompleted = easyLevel + hardLevel;
    
    // 3. Total Target Level adalah 10
    // (Membaca/Berhitung: 5 Mudah + 5 Sulit = 10)
    // (Menulis: 10 Level di mode mudah = 10)
    int maxLevels = 10; 
    
    // 4. Hitung Persentase (Contoh: 1 / 10 = 0.1 atau 10%)
    return (totalCompleted / maxLevels).clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> _getSubjects() {
    return [
      {
        'title': 'Membaca',
        'subtitle': 'Ayo belajar membaca!',
        'color': AppColors.red,
        'icon': Icons.menu_book_rounded,
        'progress': _calculateProgress('Membaca'),
      },
      {
        'title': 'Menulis',
        'subtitle': 'Latihan menulis huruf!',
        'color': AppColors.blue,
        'icon': Icons.edit_rounded,
        'progress': _calculateProgress('Menulis'),
      },
      {
        'title': 'Berhitung',
        'subtitle': 'Belajar angka & hitungan!',
        'color': AppColors.yellow,
        'icon': Icons.calculate_rounded,
        'progress': _calculateProgress('Berhitung'),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _getSubjects();

    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blue, width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Text(currentFace, style: const TextStyle(fontSize: 28)),
                            if (equippedHat != null)
                              Positioned(top: -15, child: Text("🎩", style: TextStyle(fontSize: 20))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Halo,", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text("$stars", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // --- LIST KARTU ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _SubjectCard(
                    title: subject['title'] as String,
                    subtitle: subject['subtitle'] as String,
                    color: subject['color'] as Color,
                    icon: subject['icon'] as IconData,
                    progress: subject['progress'] as double,
                    onTap: () => onSubjectSelect(subject['title'] as String),
                  ).animate().fadeIn(delay: (index * 200).ms).slideX();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double progress; // 0.0 - 1.0
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris Atas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_rounded, color: color),
                ),
              ],
            ),
            
            // --- PROGRESS BAR ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    // Pastikan progress minimal 0 (kosong) jika belum ada level selesai
                    widthFactor: progress, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${(progress * 100).toInt()}% Selesai",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}