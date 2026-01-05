import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../theme/colors.dart';
import '../question/question_screen.dart';
import '../writing/writing_screen.dart';
// IMPORT DATA SOAL
import '../../data/reading_questions.dart';
import '../../data/math_questions.dart';
import 'exam_simulation_screen.dart';
import '../../services/notification_service.dart';
import '../battle/battle_screen.dart'; 
import '../parent/add_question_screen.dart'; 
import '../../services/custom_question_service.dart'; 

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
      streak = 1;
    } else {
      final lastActive = _parseDate(lastActiveStr);
      final difference = today.difference(lastActive).inDays;
      
      if (difference == 0) {
        // Sama
      } else if (difference == 1) {
        streak = (streak + 1).clamp(0, 7);
      } else {
        streak = 1;
      }
    }
    
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

  // --- LOGIKA HELPER: KONVERSI SOAL CUSTOM ---
  List<ReadingQuestion> _mixCustomReading(List<ReadingQuestion> defaultList, List<CustomQuestionModel> customs) {
    List<ReadingQuestion> mixed = List.from(defaultList);
    for (var c in customs.where((e) => !e.isMath)) {
      List<String> opts = [...c.wrongAnswers, c.correctAnswer]..shuffle();
      mixed.add(ReadingQuestion(
        text: c.text,
        options: opts,
        correctIndex: opts.indexOf(c.correctAnswer),
      ));
    }
    return mixed..shuffle();
  }

  List<MathQuestion> _mixCustomMath(List<MathQuestion> defaultList, List<CustomQuestionModel> customs) {
    List<MathQuestion> mixed = List.from(defaultList);
    for (var c in customs.where((e) => e.isMath)) {
      List<String> opts = [...c.wrongAnswers, c.correctAnswer]..shuffle();
      mixed.add(MathQuestion(
        visual: c.text,
        questionText: "Pilih jawaban yang benar:",
        options: opts,
        correctIndex: opts.indexOf(c.correctAnswer),
        hint: '', // Pastikan hint ada
      ));
    }
    return mixed..shuffle();
  }

  // --- LOGIKA KUIS CAMPUR (UPDATED: Ambil Custom Dulu) ---
  void _startMixedQuiz(BuildContext context) async {
    // 1. Ambil Soal Custom
    List<CustomQuestionModel> customQuestions = await CustomQuestionService.getQuestions();

    // 2. Campur Soal Membaca
    final allReadingDefault = easyReadingSteps.expand((x) => x).toList();
    final allReadingMixed = _mixCustomReading(allReadingDefault, customQuestions);
    final selectedReading = allReadingMixed.take(3).toList();

    // 3. Campur Soal Berhitung
    final allMathDefault = easyMathSteps.expand((x) => x).toList();
    final allMathMixed = _mixCustomMath(allMathDefault, customQuestions);
    final selectedMath = allMathMixed.take(4).toList();

    // 4. Writing tetap random
    final writingSteps = List.generate(10, (i) => i + 1)..shuffle();
    final selectedWritingSteps = writingSteps.take(3).toList();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          subject: "Membaca",
          level: 1, 
          mode: "mudah",
          customReadingData: selectedReading, // Kirim Data Campuran
          onBack: () => Navigator.pop(context),
          onComplete: (success) {
            Navigator.pop(context);
            if (success) {
              _runWritingQueue(context, selectedWritingSteps, selectedMath);
            }
          },
        ),
      ),
    );
  }

  void _runWritingQueue(BuildContext context, List<int> steps, List<MathQuestion> nextMathQuestions) {
    if (steps.isEmpty) {
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
            Navigator.pop(context);
            if (success) {
              _runWritingQueue(context, remainingSteps, nextMathQuestions);
            }
          },
        ),
      ),
    );
  }

  void _startMathPhase(BuildContext context, List<MathQuestion> mathQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          subject: "Berhitung",
          level: 1,
          mode: "mudah",
          customMathData: mathQuestions,
          onBack: () => Navigator.pop(context),
          onComplete: (success) {
            Navigator.pop(context);
            if (success) {
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

  // --- LOGIKA KUIS HARIAN (UPDATED: Campur Custom) ---
  void _handleDailyQuiz(BuildContext context) async {
    final int day = DateTime.now().day;
    final int modeIndex = day % 3; 
    final int randomLevel = Random().nextInt(5) + 1; 

    // Ambil Soal Custom Dulu
    List<CustomQuestionModel> customQuestions = await CustomQuestionService.getQuestions();

    if (!mounted) return;

    if (modeIndex == 0) { // Berhitung
      // Campur soal Level terpilih dengan Custom Math
      List<MathQuestion> defaultQuestions = easyMathSteps[(randomLevel - 1).clamp(0, 4)];
      List<MathQuestion> mixedQuestions = _mixCustomMath(defaultQuestions, customQuestions);
      // Ambil 5 soal saja dari campuran
      mixedQuestions = mixedQuestions.take(5).toList();

      Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen(
        subject: "Berhitung", 
        level: randomLevel, 
        mode: "mudah", 
        customMathData: mixedQuestions, // Kirim Data Campuran
        onBack: () => Navigator.pop(context), 
        onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Berhitung"); }
      )));

    } else if (modeIndex == 1) { // Membaca
      // Campur soal Level terpilih dengan Custom Reading
      List<ReadingQuestion> defaultQuestions = easyReadingSteps[(randomLevel - 1).clamp(0, 4)];
      List<ReadingQuestion> mixedQuestions = _mixCustomReading(defaultQuestions, customQuestions);
      mixedQuestions = mixedQuestions.take(5).toList();

      Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen(
        subject: "Membaca", 
        level: randomLevel, 
        mode: "mudah", 
        customReadingData: mixedQuestions, // Kirim Data Campuran
        onBack: () => Navigator.pop(context), 
        onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Membaca"); }
      )));

    } else { // Menulis
      Navigator.push(context, MaterialPageRoute(builder: (context) => WritingScreen(step: randomLevel, onBack: () => Navigator.pop(context), onComplete: (success) { Navigator.pop(context); if(success) _showDailySuccess(context, "Menulis"); })));
    }
  }

  void _showDailySuccess(BuildContext context, String subject) {
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
        'action': () => _startMixedQuiz(context), 
      },
      // 🔥 MENU DUEL
      {
        'title': 'Duel 1 vs 1',
        'emoji': '⚔️',
        'color': AppColors.red,
        'unlocked': true,
        'subtitle': 'Adu Cepat: Matematika & Membaca',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BattleScreen()),
          );
        },
      },
      // 🔥 MENU SIMULASI
      {
        'title': 'Simulasi Ujian',
        'emoji': '📝',
        'color': AppColors.yellow,
        'unlocked': true, 
        'subtitle': '4 Menit • 10 Soal',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExamSimulationScreen()),
          );
        },
      },
      // 🔥 MENU BUAT SOAL SENDIRI
      {
        'title': 'Buat Soal Sendiri',
        'emoji': '✍️',
        'color': Colors.purple,
        'unlocked': true,
        'subtitle': 'Tulis soal khusus untuk anak',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddQuestionScreen()),
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
                
                // Looping untuk menampilkan kartu aktivitas
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
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kartu Aktivitas (Updated: withValues)
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
          // ✅ FIX: Ganti withOpacity jadi withValues
          boxShadow: unlocked ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
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
          // ✅ FIX: Ganti withOpacity jadi withValues
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(emoji, style: const TextStyle(fontSize: 20))), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))), Text("$current / $total", style: const TextStyle(color: Colors.grey))]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: current / total, backgroundColor: Colors.grey.shade100, color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}