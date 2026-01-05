import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../constants/shop_data.dart'; // ✅ Pastikan import data toko biar sinkron

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

  // --- LOGIKA HELPER AKSESORIS (VERSI MINI) ---
  // Kita perlu menyesuaikan posisi (offset) karena avatar di Home lebih kecil (50px)
  // dibanding di Profile (100px). Jadi offsetnya kira-kira dibagi 2.
  Map<String, dynamic> _getMiniAccessoryData(String? id) {
    if (id == null) return {'emoji': '', 'offset_y': 0.0};

    // Mapping manual untuk posisi versi KECIL (Home)
    const customMiniPosition = {
      'hat1': {'emoji': '🎩', 'offset_y': -17.0}, 
      'hat2': {'emoji': '👑', 'offset_y': -17.0},
      'hat3': {'emoji': '🎓', 'offset_y': -14.0},
      'glasses1': {'emoji': '👓', 'offset_y': 0.0},
      'glasses2': {'emoji': '🕶️', 'offset_y': 0.0},
      'glasses3': {'emoji': '🥽', 'offset_y': 0.0},
    };

    if (customMiniPosition.containsKey(id)) {
      return customMiniPosition[id]!;
    }

    // Fallback ambil dari shop data
    final item = SHOP_ITEMS.firstWhere((e) => e['id'] == id, orElse: () => {});
    return item.isEmpty ? {'emoji': '', 'offset_y': 0.0} : item;
  }

  // --- LOGIKA HITUNG PERSENTASE (1 Level = 10%) ---
  double _calculateProgress(String subject) {
    int easyLevel = subjectProgress["${subject}_mudah"] ?? 0;
    int hardLevel = subjectProgress["${subject}_sulit"] ?? 0;
    
    // Total level selesai (Mudah + Sulit)
    int totalCompleted = easyLevel + hardLevel;
    
    // Target: 10 Level
    int maxLevels = 10; 
    
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
                  // Kiri: Avatar & Nama
                  Row(
                    children: [
                      // 🔥 AVATAR MINI YANG SUDAH DIPERBAIKI 🔥
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
                          clipBehavior: Clip.none, // Biar topi bisa nongol dikit
                          children: [
                            // 1. Wajah
                            Text(currentFace, style: const TextStyle(fontSize: 28, height: 1)),
                            
                            // 2. Kacamata (Jika ada)
                            if (equippedGlasses != null)
                              Transform.translate(
                                offset: Offset(0, _getMiniAccessoryData(equippedGlasses)['offset_y'] as double),
                                child: Text(
                                  _getMiniAccessoryData(equippedGlasses)['emoji'] as String,
                                  style: const TextStyle(fontSize: 18, height: 1),
                                ),
                              ),

                            // 3. Topi (Jika ada)
                            if (equippedHat != null)
                              Transform.translate(
                                offset: Offset(0, _getMiniAccessoryData(equippedHat)['offset_y'] as double),
                                child: Text(
                                  _getMiniAccessoryData(equippedHat)['emoji'] as String,
                                  style: const TextStyle(fontSize: 22, height: 1),
                                ),
                              ),
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
                  // Kanan: Bintang
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

// Widget Kartu (Tetap sama seperti sebelumnya)
class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double progress;
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
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.arrow_forward_rounded, color: color),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress > 0 ? progress : 0.0, 
                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(height: 6),
                Text("${(progress * 100).toInt()}% Selesai", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
              ],
            ),
          ],
        ),
      ),
    );
  }
}