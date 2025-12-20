import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class AdventureMapScreen extends StatelessWidget {
  final String subject;
  final String difficulty;
  final int highestCompletedLevel; // Level tertinggi yang sudah diselesaikan
  final VoidCallback onBack;

  /// Dipanggil saat salah satu lingkaran level di-tap, dengan nomor level.
  final void Function(int level) onLevelClick;

  const AdventureMapScreen({
    super.key,
    required this.subject,
    required this.difficulty,
    required this.highestCompletedLevel,
    required this.onBack,
    required this.onLevelClick,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subject == "Menulis" ? subject : "$subject - $difficulty",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.blue,
                    radius: 24,
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Map List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                // Membaca hanya punya 5 step, lainnya 10
                itemCount: subject == "Membaca" ? 5 : 10,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  // Logika "Zig-Zag"
                  final isLeft = index % 2 == 0;

                  // Tentukan status level berdasarkan progress
                  // - completed: level sudah diselesaikan (level <= highestCompletedLevel)
                  // - current: level berikutnya yang bisa dimainkan (level == highestCompletedLevel + 1)
                  // - locked: level masih terkunci (level > highestCompletedLevel + 1)
                  String status;
                  if (level <= highestCompletedLevel) {
                    status = 'completed';
                  } else if (level == highestCompletedLevel + 1) {
                    status = 'current';
                  } else {
                    status = 'locked';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: isLeft
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        SizedBox(width: isLeft ? 40 : 0),
                        _LevelNode(
                          level: level,
                          status: status,
                          onTap: status != 'locked'
                              ? () => onLevelClick(level)
                              : null,
                        ),
                        SizedBox(width: isLeft ? 0 : 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final int level;
  final String status; // 'completed', 'current', 'locked'
  final VoidCallback? onTap;

  const _LevelNode({required this.level, required this.status, this.onTap});

  String _getEmojiForStep(int step) {
    // Emoticon berbeda untuk setiap step 1-10
    const emojis = ['😊', '😄', '😃', '😁', '😆', '😉', '😋', '😎', '🤩', '🥳'];
    return emojis[(step - 1) % emojis.length];
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.grey.shade300;
    Widget content = const Icon(Icons.lock, color: Colors.grey);
    double size = 80;

    if (status == 'completed') {
      bgColor = AppColors.yellow;
      content = Text(
        "$level",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (status == 'current') {
      bgColor = AppColors.red;
      size = 96;
      // Emoticon sesuai dengan step (1-10)
      final emoji = _getEmojiForStep(level);
      content = Text(emoji, style: const TextStyle(fontSize: 40));
    }

    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (status != 'locked')
                      BoxShadow(
                        color: bgColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                  ],
                  border: status == 'current'
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
                ),
                child: Center(child: content),
              )
              .animate(target: status == 'current' ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
    );
  }
}
