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

  const HomeScreen({
    super.key, // Public widget tetap butuh key
    required this.userName,
    required this.stars,
    required this.currentFace,
    required this.equippedHat,
    required this.equippedGlasses,
    required this.onSubjectSelect,
  });

  // Helper Mapping Emoji & Offset
  Map<String, dynamic> _getAccessoryData(String? id) {
    if (id == null) return {'emoji': '', 'offset_y': 0.0};
    const map = {
      'hat1': {'emoji': '🎩', 'offset_y': -14.0},
      'hat2': {'emoji': '👑', 'offset_y': -16.0},
      'hat3': {'emoji': '🎓', 'offset_y': -14.0},
      'glasses1': {'emoji': '👓', 'offset_y': -1.0},
      'glasses2': {'emoji': '🕶️', 'offset_y': -1.0},
      'glasses3': {'emoji': '🥽', 'offset_y': -1.0},
    };
    return map[id] ?? {'emoji': '', 'offset_y': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // AVATAR USER (STACK MINI)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Text(
                              currentFace,
                              style: const TextStyle(fontSize: 28, height: 1),
                            ),

                            // Kacamata Mini
                            if (equippedGlasses != null)
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  _getAccessoryData(equippedGlasses)['offset_y']
                                      as double,
                                ),
                                child: Text(
                                  _getAccessoryData(equippedGlasses)['emoji']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1,
                                  ),
                                ),
                              ),

                            // Topi Mini
                            if (equippedHat != null)
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  _getAccessoryData(equippedHat)['offset_y']
                                      as double,
                                ),
                                child: Text(
                                  _getAccessoryData(equippedHat)['emoji']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Halo,",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "$stars",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CONTENT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  "Pilih Pelajaran",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _SubjectCard(
                  title: "Membaca",
                  emoji: "📖",
                  color: AppColors.red,
                  progress: 0.5,
                  onTap: () => onSubjectSelect("Membaca"),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _SubjectCard(
                  title: "Menulis",
                  emoji: "✏️",
                  color: AppColors.blue,
                  progress: 0.3,
                  onTap: () => onSubjectSelect("Menulis"),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                _SubjectCard(
                  title: "Berhitung",
                  emoji: "🔢",
                  color: AppColors.yellow,
                  progress: 0.2,
                  onTap: () => onSubjectSelect("Berhitung"),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  // PERBAIKAN: Hapus 'super.key' di sini agar tidak error
  const _SubjectCard({
    required this.title,
    required this.emoji,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Ayo belajar!",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_circle_right_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
