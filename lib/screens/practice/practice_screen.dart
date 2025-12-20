import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': 'Kuis Harian',
        'emoji': '⏰',
        'color': const Color(0xFFFF6B9D),
        'unlocked': true,
        'subtitle': 'Berakhir dalam 23:45',
      },
      {
        'title': 'Kuis Campur',
        'emoji': '🎲',
        'color': const Color(0xFF4ECDC4),
        'unlocked': true,
        'subtitle': 'Soal acak semua pelajaran',
      },
      {
        'title': 'Simulasi Ujian',
        'emoji': '📝',
        'color': AppColors.yellow,
        'unlocked': false,
        'subtitle': 'Latihan ujian dengan timer',
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: const [
                Icon(Icons.fitness_center, color: AppColors.blue, size: 32),
                SizedBox(width: 12),
                Text(
                  "Zona Latihan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  "Aktivitas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Activities List
                ...activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return _ActivityCard(
                    title: activity['title'] as String,
                    subtitle: activity['subtitle'] as String,
                    emoji: activity['emoji'] as String,
                    color: activity['color'] as Color,
                    unlocked: activity['unlocked'] as bool,
                  ).animate().fadeIn(delay: (index * 100).ms).slideX();
                }),

                const SizedBox(height: 32),
                const Text(
                  "Pencapaian Target",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Achievement Progress
                _ProgressCard(
                  title: "Streak 7 Hari",
                  emoji: "🔥",
                  current: 5,
                  total: 7,
                  color: AppColors.orange,
                ),
                const SizedBox(height: 12),
                _ProgressCard(
                  title: "Master Membaca",
                  emoji: "📚",
                  current: 12,
                  total: 20,
                  color: const Color(0xFFFF6B9D),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final bool unlocked;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.arrow_forward_ios_rounded : Icons.lock,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String emoji;
  final int current;
  final int total;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.emoji,
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "$current / $total",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey.shade100,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
