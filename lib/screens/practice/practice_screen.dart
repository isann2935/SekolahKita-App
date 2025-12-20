import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../theme/colors.dart';
import '../question/question_screen.dart';
import '../writing/writing_screen.dart';
// IMPORT DATA SOAL (Penting!)
import '../../data/reading_questions.dart';
import '../../data/math_questions.dart';
import 'exam_simulation_screen.dart';
import '../../services/notification_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentStreak = 0;
  static const String _streakKey = 'streak_count';
  static const String _lastActiveKey = 'last_active_date';

  @override
  void initState() {
    super.initState();
    _loadAndUpdateStreak();
  }

  Future<void> _loadAndUpdateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    final lastActiveStr = prefs.getString(_lastActiveKey);
    int streak = prefs.getInt(_streakKey) ?? 0;
    
    if (lastActiveStr == null) {
      // Pertama kali membuka aplikasi
      streak = 1;
    } else {
      final lastActive = _parseDate(lastActiveStr);
      final difference = today.difference(lastActive).inDays;
      
      if (difference == 0) {
        // Sudah aktif hari ini, streak tidak berubah
      } else if (difference == 1) {
        // Aktif kemarin, tambah streak
        streak = (streak + 1).clamp(0, 7);
      } else {
        // Tidak aktif lebih dari 1 hari, reset streak
        streak = 1;
      }
    }
    
    // Simpan data terbaru
    await prefs.setString(_lastActiveKey, todayStr);
    await prefs.setInt(_streakKey, streak);
    
    if (mounted) {
      setState(() {
        _currentStreak = streak;
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  // --- LOGIKA KUIS CAMPUR (URUT: BACA -> TULIS -> HITUNG) ---
  void _startMixedQuiz(BuildContext context) {
    // 1. Ambil 3 Soal Membaca Acak
    final allReading = easyReadingSteps.expand((x) => x).toList()..shuffle();
    final selectedReading = allReading.take(3).toList();

    // 2. Ambil 4 Soal Berhitung Acak
    final allMath = easyMathSteps.expand((x) => x).toList()..shuffle();
    final selectedMath = allMath.take(4).toList();

    // 3. Ambil 3 Step Menulis Acak (Step 1-10)
    final writingSteps = List.generate(10, (i) => i + 1)..shuffle();
    final selectedWritingSteps = writingSteps.take(3).toList();

    // MULAI ESTAFET:
    // STEP 1: MEMBACA
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          subject: "Membaca",
          level: 1, // Dummy level
          mode: "mudah",
          customReadingData: selectedReading, // Kirim soal khusus
          onBack: () => Navigator.pop(context),
          onComplete: (success) {
            Navigator.pop(context); // Tutup Membaca
            if (success) {
              // STEP 2: MENULIS (Recursive Queue)
              _runWritingQueue(context, selectedWritingSteps, selectedMath);
            }
          },
        ),
      ),
    );
  }

  // Helper untuk menjalankan Writing Screen berurutan
  void _runWritingQueue(BuildContext context, List<int> steps, List<MathQuestion> nextMathQuestions) {
    if (steps.isEmpty) {
      // Jika menulis habis, lanjut ke BERHITUNG
      _startMathPhase(context, nextMathQuestions);
      return;
    }

    int currentStep = steps.first;
    List<int> remainingSteps = steps.sublist(1);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritingScreen(
          step: currentStep,
          onBack: () => Navigator.pop(context),
          onComplete: (success) {
            Navigator.pop(context); // Tutup Writing saat ini
            if (success) {
              // Lanjut ke step menulis berikutnya (Recursion)
              _runWritingQueue(context, remainingSteps, nextMathQuestions);
            }
          },
        ),
      ),
    );
  }

  // Helper untuk fase terakhir: BERHITUNG
  void _startMathPhase(BuildContext context, List<MathQuestion> mathQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          subject: "Berhitung",
          level: 1,
          mode: "mudah",
          customMathData: mathQuestions, // Kirim soal khusus
          onBack: () => Navigator.pop(context),
          onComplete: (success) {
            Navigator.pop(context);
            if (success) {
              // FINISH SEMUA - tandai aktivitas selesai
              NotificationService().markActivityCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🎉 SELAMAT! Kamu menaklukkan Kuis Campur!"),
                  backgroundColor: AppColors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // --- LOGIKA KUIS HARIAN (YANG TADI) ---
  void _handleDailyQuiz(BuildContext context) {
    final int day = DateTime.now().day;
    final int modeIndex = day % 3; 
    final int randomLevel = Random().nextInt(5) + 1; 

    if (modeIndex == 0) { // Berhitung
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen(subject: "Berhitung", level: randomLevel, mode: "mudah", onBack: () => Navigator.pop(context), onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Berhitung"); })));
    } else if (modeIndex == 1) { // Membaca
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen(subject: "Membaca", level: randomLevel, mode: "mudah", onBack: () => Navigator.pop(context), onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Membaca"); })));
    } else { // Menulis
      Navigator.push(context, MaterialPageRoute(builder: (context) => WritingScreen(step: randomLevel, onBack: () => Navigator.pop(context), onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Menulis"); })));
    }
  }

  void _showDailySuccess(BuildContext context, String subject) {
    // Tandai aktivitas selesai untuk cancel notifikasi hari ini
    NotificationService().markActivityCompleted();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hebat! Kuis Harian ($subject) Selesai! 🎉"), backgroundColor: AppColors.green));
  }

  String _getDailySubjectName() {
    final int day = DateTime.now().day;
    final int modeIndex = day % 3;
    if (modeIndex == 0) return "Berhitung";
    if (modeIndex == 1) return "Membaca";
    return "Menulis";
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Kuis Harian',
        'emoji': '⏰',
        'color': const Color(0xFFFF6B9D),
        'unlocked': true,
        'subtitle': 'Materi hari ini: ${_getDailySubjectName()}',
        'action': () => _handleDailyQuiz(context),
      },
      {
        'title': 'Kuis Campur',
        'emoji': '🎲',
        'color': const Color(0xFF4ECDC4),
        'unlocked': true,
        'subtitle': '3 Baca, 3 Tulis, 4 Hitung',
        'action': () => _startMixedQuiz(context), // 👈 PANGGIL KUIS CAMPUR DI SINI
      },
      {
        'title': 'Simulasi Ujian',
        'emoji': '📝',
        'color': AppColors.yellow,
        'unlocked': true, // 👈 Ubah jadi TRUE (Buka Kunci)
        'subtitle': '4 Menit • 10 Soal',
        'action': () {
          // Navigasi ke Layar Ujian Baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExamSimulationScreen(),
            ),
          );
        },
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: const [
                Icon(Icons.fitness_center, color: AppColors.blue, size: 32),
                SizedBox(width: 12),
                Text("Zona Latihan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text("Aktivitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return _ActivityCard(
                    title: activity['title'] as String,
                    subtitle: activity['subtitle'] as String,
                    emoji: activity['emoji'] as String,
                    color: activity['color'] as Color,
                    unlocked: activity['unlocked'] as bool,
                    onTap: activity['action'] as VoidCallback,
                  ).animate().fadeIn(delay: (index * 100).ms).slideX();
                }),
                const SizedBox(height: 32),
                const Text("Pencapaian Target", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _ProgressCard(title: "Streak 7 Hari", emoji: "🔥", current: _currentStreak, total: 7, color: AppColors.orange),
                const SizedBox(height: 24),
                // Tombol Test Notifikasi (bisa dihapus nanti)
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService().showTestNotification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🔔 Notifikasi test dikirim! Cek notification bar."), backgroundColor: AppColors.blue),
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text("Test Notifikasi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
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
  final VoidCallback onTap;

  const _ActivityCard({required this.title, required this.subtitle, required this.emoji, required this.color, required this.unlocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked ? onTap : () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur ini masih terkunci! 🔒"))); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24),
          boxShadow: unlocked ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))])),
            Icon(unlocked ? Icons.arrow_forward_ios_rounded : Icons.lock, color: Colors.white, size: 20),
          ],
        ),
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

  const _ProgressCard({required this.title, required this.emoji, required this.current, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(emoji, style: const TextStyle(fontSize: 20))), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))), Text("$current / $total", style: const TextStyle(color: Colors.grey))]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: current / total, backgroundColor: Colors.grey.shade100, color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}