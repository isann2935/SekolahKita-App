import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/user_progress_service.dart'; // ✅ PENTING: Untuk simpan statistik
import '../../data/reading_questions.dart';
import '../../data/math_questions.dart';
import '../../data/writing_data.dart';
import '../question/question_screen.dart'; // Menggunakan widget jawaban yang sudah ada
import '../writing/writing_screen.dart'; // Menggunakan layar menulis yang sudah ada

class ExamSimulationScreen extends StatefulWidget {
  const ExamSimulationScreen({super.key});

  @override
  State<ExamSimulationScreen> createState() => _ExamSimulationScreenState();
}

class _ExamSimulationScreenState extends State<ExamSimulationScreen> {
  // --- TIMER (4 Menit = 240 Detik) ---
  static const int totalSeconds = 240; 
  int remainingSeconds = totalSeconds;
  Timer? _timer;

  // --- DATA SOAL ---
  List<ReadingQuestion> readingQuestions = [];
  List<MathQuestion> mathQuestions = [];
  List<int> writingSteps = [];

  // --- STATE ---
  int currentPhase = 0; // 0: Membaca, 1: Menulis, 2: Berhitung
  
  // Tracking Jawaban
  Map<int, int> readingAnswers = {}; // Index Soal -> Index Jawaban User
  Map<int, int> mathAnswers = {};
  int completedWritingSteps = 0;

  bool isExamFinished = false;

  @override
  void initState() {
    super.initState();
    _generateExamData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- 1. GENERATE SOAL ACAK ---
  void _generateExamData() {
    // A. Ambil 3 Soal Membaca Acak
    final allReading = easyReadingSteps.expand((x) => x).toList()..shuffle();
    readingQuestions = allReading.take(3).toList();

    // B. Ambil 3 Step Menulis Acak (Step 1-10)
    final allWriting = List.generate(10, (i) => i + 1)..shuffle();
    writingSteps = allWriting.take(3).toList();

    // C. Ambil 4 Soal Berhitung Acak
    final allMath = easyMathSteps.expand((x) => x).toList()..shuffle();
    mathQuestions = allMath.take(4).toList();
  }

  // --- 2. TIMER LOGIC ---
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        // Waktu Habis -> Paksa Selesai
        _finishExam(timeUp: true);
      }
    });
  }

  // --- 3. SELESAI UJIAN & HITUNG SKOR ---
  void _finishExam({bool timeUp = false}) async {
    _timer?.cancel();
    setState(() {
      isExamFinished = true;
    });

    // Hitung Skor Membaca
    int readingScore = 0;
    for (int i = 0; i < readingQuestions.length; i++) {
      if (readingAnswers[i] == readingQuestions[i].correctIndex) readingScore++;
    }

    // Hitung Skor Berhitung
    int mathScore = 0;
    for (int i = 0; i < mathQuestions.length; i++) {
      if (mathAnswers[i] == mathQuestions[i].correctIndex) mathScore++;
    }

    // Skor Menulis (dianggap benar jika sudah melewati stepnya)
    int writingScore = completedWritingSteps;

    int totalScore = readingScore + mathScore + writingScore;
    // Maksimal Skor = 3 (Baca) + 3 (Tulis) + 4 (Hitung) = 10

    // ✅ SIMPAN PROGRESS JIKA LULUS (Minimal Benar 6)
    bool isPassed = totalScore >= 6;
    if (isPassed) {
      await UserProgressService.incrementMaterialCount();
    }

    if (!mounted) return;

    // Tampilkan Dialog Hasil
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isPassed ? Icons.emoji_events : Icons.timelapse,
              color: isPassed ? AppColors.yellow : AppColors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                timeUp ? "Waktu Habis!" : "Ujian Selesai!",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Nilai Akhir: ${totalScore * 10}",
              style: const TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
                color: AppColors.blue
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildResultRow("📖 Membaca", "$readingScore / 3"),
            _buildResultRow("✏️ Menulis", "$writingScore / 3"),
            _buildResultRow("🔢 Berhitung", "$mathScore / 4"),
            const SizedBox(height: 20),
            Text(
              isPassed ? "Lulus! Kerja bagus! 🎉" : "Belum lulus, coba lagi ya! 💪",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isPassed ? AppColors.green : AppColors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(context); // Kembali ke menu
            },
            child: const Text("Tutup", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(score, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            _timer?.cancel(); // Stop timer sementara
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Keluar Ujian?"),
                content: const Text("Progres kamu tidak akan disimpan."),
                actions: [
                  TextButton(
                    onPressed: () {
                      _startTimer(); // Lanjut timer
                      Navigator.pop(ctx);
                    },
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text("Simulasi Ujian", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: remainingSeconds < 30 ? AppColors.red : AppColors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _formatTime(remainingSeconds),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indikator Fase (Membaca -> Menulis -> Berhitung)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildPhaseIndicator("Membaca", 0),
                  const SizedBox(width: 8),
                  _buildPhaseIndicator("Menulis", 1),
                  const SizedBox(width: 8),
                  _buildPhaseIndicator("Berhitung", 2),
                ],
              ),
            ),
            
            // Konten Utama (Ganti-ganti sesuai fase)
            Expanded(
              child: _buildCurrentPhase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(String label, int index) {
    bool isActive = index == currentPhase;
    bool isDone = index < currentPhase;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blue : (isDone ? AppColors.green : Colors.grey[300]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive || isDone ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIKA PERGANTIAN TAMPILAN ---
  Widget _buildCurrentPhase() {
    if (currentPhase == 0) {
      // TAMPILAN MEMBACA
      return _ExamReadingView(
        questions: readingQuestions,
        answers: readingAnswers,
        onAnswer: (qIndex, ansIndex) {
          setState(() {
            readingAnswers[qIndex] = ansIndex;
          });
        },
        onNext: () {
          if (readingAnswers.length == 3) {
            setState(() => currentPhase = 1); // Pindah ke Menulis
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jawab semua soal dulu ya!")));
          }
        },
      );
    } else if (currentPhase == 1) {
      // TAMPILAN MENULIS
      return _ExamWritingView(
        steps: writingSteps,
        onCompleted: (count) {
          setState(() {
            completedWritingSteps = count;
            currentPhase = 2; // Pindah ke Berhitung
          });
        },
      );
    } else {
      // TAMPILAN BERHITUNG
      return _ExamMathView(
        questions: mathQuestions,
        answers: mathAnswers,
        onAnswer: (qIndex, ansIndex) {
          setState(() {
            mathAnswers[qIndex] = ansIndex;
          });
        },
        onFinish: () {
          if (mathAnswers.length == 4) {
            _finishExam(); // SELESAI
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jawab semua soal dulu ya!")));
          }
        },
      );
    }
  }
}

// =========================================================
// SUB-WIDGET: MEMBACA (3 Soal)
// =========================================================
class _ExamReadingView extends StatelessWidget {
  final List<ReadingQuestion> questions;
  final Map<int, int> answers;
  final Function(int, int) onAnswer;
  final VoidCallback onNext;

  const _ExamReadingView({required this.questions, required this.answers, required this.onAnswer, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Bagian 1: Membaca", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...List.generate(questions.length, (index) {
          final q = questions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Soal ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue)),
                const SizedBox(height: 8),
                Text(q.text, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                ...List.generate(q.options.length, (optIndex) {
                  final isSelected = answers[index] == optIndex;
                  return GestureDetector(
                    onTap: () => onAnswer(index, optIndex),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blue.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? AppColors.blue : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.blue : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(child: Text(q.options[optIndex])),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text("Lanjut ke Menulis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// =========================================================
// SUB-WIDGET: BERHITUNG (4 Soal)
// =========================================================
class _ExamMathView extends StatelessWidget {
  final List<MathQuestion> questions;
  final Map<int, int> answers;
  final Function(int, int) onAnswer;
  final VoidCallback onFinish;

  const _ExamMathView({required this.questions, required this.answers, required this.onAnswer, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Bagian 3: Berhitung", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...List.generate(questions.length, (index) {
          final q = questions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Soal ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue)),
                const SizedBox(height: 8),
                if(q.visual != null) ...[
                   Center(child: Text(q.visual!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                   const SizedBox(height: 8),
                ],
                Text(q.questionText, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(q.options.length, (optIndex) {
                    final isSelected = answers[index] == optIndex;
                    return GestureDetector(
                      onTap: () => onAnswer(index, optIndex),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.blue.withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? AppColors.blue : Colors.grey[300]!),
                        ),
                        alignment: Alignment.center,
                        child: Text(q.options[optIndex], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
        ElevatedButton(
          onPressed: onFinish,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text("Selesai Ujian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// =========================================================
// SUB-WIDGET: MENULIS (Menggunakan WritingScreen yang ada)
// =========================================================
class _ExamWritingView extends StatefulWidget {
  final List<int> steps;
  final Function(int) onCompleted;

  const _ExamWritingView({required this.steps, required this.onCompleted});

  @override
  State<_ExamWritingView> createState() => _ExamWritingViewState();
}

class _ExamWritingViewState extends State<_ExamWritingView> {
  int currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    if (currentIndex >= widget.steps.length) {
      // Jika semua step menulis selesai
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: AppColors.green),
            const SizedBox(height: 16),
            const Text("Sesi Menulis Selesai!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.onCompleted(widget.steps.length),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text("Lanjut ke Berhitung", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      );
    }

    // Tampilkan Layar Menulis dalam ClipRect agar rapi di dalam body
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Bagian 2: Menulis (${currentIndex + 1}/3)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ClipRect(
            child: WritingScreen(
              step: widget.steps[currentIndex],
              onBack: () {}, // Tombol back dinonaktifkan saat ujian
              onComplete: (success) {
                if (success) {
                  setState(() {
                    currentIndex++;
                  });
                  if (currentIndex >= widget.steps.length) {
                    widget.onCompleted(widget.steps.length);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}