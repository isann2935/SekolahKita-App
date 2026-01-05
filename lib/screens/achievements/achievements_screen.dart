import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../services/user_progress_service.dart';
import '../../constants/shop_data.dart'; // Import Data Lencana (ALL_BADGES)

class AchievementsScreen extends StatefulWidget {
  final int completedLevels;
  final List<String> badges;
  final int stars;

  const AchievementsScreen({
    super.key,
    required this.completedLevels,
    required this.badges,
    required this.stars,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _completedMaterials = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final count = await UserProgressService.getCompletedMaterials();
    if (mounted) setState(() => _completedMaterials = count);
  }

  @override
  Widget build(BuildContext context) {
    final allBadges = ALL_BADGES;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.yellow, Colors.orangeAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text("Prestasi Saya", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          // KONTEN UTAMA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [

                // 1. STATISTIK BELAJAR
                const Text("Statistik Belajar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Materi Selesai", style: TextStyle(color: Colors.grey)),
                        Text("$_completedMaterials Pelajaran", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      const SizedBox(height: 12),
                      const Align(alignment: Alignment.centerLeft, child: Text("Kemajuan Level", style: TextStyle(color: Colors.grey, fontSize: 12))),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (widget.completedLevels / 10).clamp(0.0, 1.0),
                          child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF4ECDC4)]), borderRadius: BorderRadius.circular(6))),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).slideX(),

                const SizedBox(height: 24),

                // 2. LENCANA PRESTASI (Grid Badge)
                const Text("Lencana Prestasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.8, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: allBadges.length,
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final isEarned = widget.badges.contains(badge['id']);
                    return Column(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: isEarned ? Colors.white : Colors.grey.shade200, borderRadius: BorderRadius.circular(16), boxShadow: isEarned ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : []),
                          child: Center(child: Text(badge['emoji'] as String, style: TextStyle(fontSize: 24, color: isEarned ? null : Colors.grey.withValues(alpha: 0.5)))),
                        ),
                        const SizedBox(height: 4),
                        Text(badge['name'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: isEarned ? Colors.black : Colors.grey)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyItem extends StatelessWidget {
  final String emoji, label; final Color color; final bool isUnlocked;
  const _TrophyItem({required this.emoji, required this.label, required this.color, required this.isUnlocked});
  @override Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      child: Column(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32)))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}