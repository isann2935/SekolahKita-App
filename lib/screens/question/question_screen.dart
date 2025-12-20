import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../data/reading_questions.dart';
import '../../data/math_questions.dart';
import '../../services/user_progress_service.dart';

class QuestionScreen extends StatelessWidget {
  final String subject;
  final int level;
  final String mode;
  final VoidCallback onBack;
  final Function(bool) onComplete;

  // --- PARAMETER BARU UNTUK KUIS CAMPUR ---
  final List<ReadingQuestion>? customReadingData;
  final List<MathQuestion>? customMathData;

  const QuestionScreen({
    super.key,
    required this.subject,
    required this.level,
    required this.mode,
    required this.onBack,
    required this.onComplete,
    this.customReadingData, // Opsional
    this.customMathData,    // Opsional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    // Jika custom data ada, judulnya "Kuis Campur"
                    (customReadingData != null || customMathData != null)
                        ? "Kuis Campur - $subject"
                        : "Level $level - $subject",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- KONTEN SOAL ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Builder(
                  builder: (context) {
                    // LOGIKA MEMBACA
                    if (subject == "Membaca") {
                      // Gunakan customData jika ada, kalau tidak ambil dari Level
                      final stepQuestions = customReadingData ?? 
                          (mode == "mudah" 
                              ? easyReadingSteps[(level - 1).clamp(0, 4)] 
                              : hardReadingSteps[(level - 1).clamp(0, 4)]);

                      return _ReadingStepCard(
                        questions: stepQuestions,
                        isEasyMode: mode == "mudah",
                        onFinish: (bool canProceed) => onComplete(canProceed),
                      );
                    }

                    // LOGIKA BERHITUNG
                    if (subject == "Berhitung") {
                      // Gunakan customData jika ada, kalau tidak ambil dari Level
                      final mathQuestions = customMathData ?? 
                          (mode == "mudah" 
                              ? easyMathSteps[(level - 1).clamp(0, 4)] 
                              : hardMathSteps[(level - 1).clamp(0, 4)]);

                      return _MathStepCard(
                        questions: mathQuestions,
                        isEasyMode: mode == "mudah",
                        onFinish: (bool canProceed) => onComplete(canProceed),
                      );
                    }

                    return const Center(child: Text("Subject tidak dikenali"));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (Bagian _AnswerButton, _MathStepCard, _ReadingStepCard SAMA PERSIS seperti sebelumnya)
// Agar file tidak terlalu panjang di chat, pastikan kamu TETAP MENYIMPAN class _AnswerButton, 
// _MathStepCard, dan _ReadingStepCard di bawah sini ya.
// Isinya tidak perlu diubah, karena mereka hanya menerima List<Question> yang sudah kita siapkan di atas.

// =========================================================
// WIDGET JAWABAN (REUSABLE)
// =========================================================
class _AnswerButton extends StatelessWidget {
  final String label;
  final String visual;
  final bool isCorrect;
  final bool isSelected;
  final bool showCorrect;
  final bool isDisabled;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.visual,
    this.isCorrect = false,
    this.isSelected = false,
    this.showCorrect = false,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color labelBgColor = AppColors.softTeal;
    Color borderColor = Colors.transparent;

    if (isDisabled) {
      if (isSelected && isCorrect) {
        bgColor = AppColors.green.withOpacity(0.1);
        labelBgColor = AppColors.green;
        borderColor = AppColors.green;
      } else if (isSelected && !isCorrect) {
        bgColor = AppColors.red.withOpacity(0.1);
        labelBgColor = AppColors.red;
        borderColor = AppColors.red;
      } else if (showCorrect) {
        bgColor = AppColors.green.withOpacity(0.1);
        labelBgColor = AppColors.green;
        borderColor = AppColors.green;
      } else {
        bgColor = Colors.grey.shade100;
        labelBgColor = Colors.grey.shade400;
      }
    } else if (isSelected) {
      bgColor = AppColors.blue.withOpacity(0.1);
      labelBgColor = AppColors.blue;
      borderColor = AppColors.blue;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: borderColor != Colors.transparent
              ? Border.all(color: borderColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: labelBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDisabled && !isSelected && !showCorrect
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                visual,
                style: TextStyle(
                  fontSize: 20,
                  color: isDisabled && !isSelected && !showCorrect
                      ? Colors.grey.shade600
                      : Colors.black,
                ),
              ),
            ),
            if (isDisabled && (isSelected || showCorrect))
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  (isSelected && isCorrect) || showCorrect
                      ? Icons.check_circle
                      : isSelected && !isCorrect
                          ? Icons.close
                          : null,
                  color: (isSelected && isCorrect) || showCorrect
                      ? AppColors.green
                      : AppColors.red,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// KARTU SOAL BERHITUNG / MATH
// =========================================================
class _MathStepCard extends StatefulWidget {
  final List<MathQuestion> questions;
  final bool isEasyMode;
  final Function(bool canProceed) onFinish;

  const _MathStepCard({
    required this.questions,
    required this.isEasyMode,
    required this.onFinish,
  });

  @override
  State<_MathStepCard> createState() => _MathStepCardState();
}

class _MathStepCardState extends State<_MathStepCard> {
  final Map<int, int?> selectedAnswers = {};
  final Map<int, bool> showFeedback = {};

  void _handleAnswerTap(int questionIndex, int optionIndex, bool isCorrect) {
    if (selectedAnswers.containsKey(questionIndex)) return;

    setState(() {
      selectedAnswers[questionIndex] = optionIndex;
      showFeedback[questionIndex] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Text(isCorrect ? 'Jawaban Benar! 🎉' : 'Jawaban Salah 😔', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: isCorrect ? AppColors.green : AppColors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResultDialog() {
    int correctCount = 0;
    int wrongCount = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final selectedIndex = selectedAnswers[i];
      if (selectedIndex != null) {
        if (selectedIndex == widget.questions[i].correctIndex) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }

    final totalQuestions = widget.questions.length;
    final score = (correctCount / totalQuestions * 100).round();
    final needRetry = wrongCount >= 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(needRetry ? Icons.refresh : Icons.celebration, color: needRetry ? AppColors.orange : AppColors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(needRetry ? 'Perlu Mengulang' : 'Selamat!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.softTeal, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text('Nilai Kamu', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text('$score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.blue)),
                    const SizedBox(height: 4),
                    Text('Benar: $correctCount / Salah: $wrongCount', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                needRetry 
                  ? 'Kamu salah $wrongCount soal. Ayo coba lagi!' 
                  : 'Hebat! Kamu menguasai materi ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: needRetry ? AppColors.orange : AppColors.green,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (needRetry) {
                setState(() { selectedAnswers.clear(); showFeedback.clear(); });
              } else {
                await UserProgressService.incrementMaterialCount();
                widget.onFinish(true);
              }
            },
            child: Text(needRetry ? 'Ulangi Step' : 'Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: needRetry ? AppColors.orange : AppColors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = ["A", "B", "C", "D"];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.softTeal, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🔢", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(widget.isEasyMode ? "Latihan Berhitung (Mudah)" : "Latihan Berhitung (Sulit)", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Hitung dan pilih jawaban yang benar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              ...List.generate(widget.questions.length, (index) {
                final q = widget.questions[index];
                final selectedIndex = selectedAnswers[index];
                final isAnswered = selectedIndex != null;
                final isCorrectAnswer = isAnswered && selectedIndex == q.correctIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Soal ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blue)),
                      const SizedBox(height: 8),
                      if (q.visual != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFFF9E6), borderRadius: BorderRadius.circular(16)),
                          child: Text(q.visual!, style: const TextStyle(fontSize: 28), textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(q.questionText, style: const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 12),
                      
                      ...List.generate(q.options.length, (optIndex) {
                        final isSelected = selectedIndex == optIndex;
                        final isCorrect = optIndex == q.correctIndex;
                        final showCorrect = isAnswered && isCorrectAnswer && isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AnswerButton(
                            label: labels[optIndex],
                            visual: q.options[optIndex],
                            isCorrect: isCorrect,
                            isSelected: isSelected,
                            showCorrect: showCorrect,
                            isDisabled: isAnswered,
                            onTap: () => _handleAnswerTap(index, optIndex, isCorrect),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswers.length == widget.questions.length ? () => _showResultDialog() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswers.length == widget.questions.length ? AppColors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    selectedAnswers.length == widget.questions.length ? "Selesai Step Ini" : "Jawab Semua Soal (${selectedAnswers.length}/${widget.questions.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =========================================================
// KARTU SOAL MEMBACA
// =========================================================
class _ReadingStepCard extends StatefulWidget {
  final List<ReadingQuestion> questions;
  final bool isEasyMode;
  final Function(bool canProceed) onFinish;

  const _ReadingStepCard({
    required this.questions,
    required this.isEasyMode,
    required this.onFinish,
  });

  @override
  State<_ReadingStepCard> createState() => _ReadingStepCardState();
}

class _ReadingStepCardState extends State<_ReadingStepCard> {
  final Map<int, int?> selectedAnswers = {};
  final Map<int, bool> showFeedback = {};

  void _handleAnswerTap(int questionIndex, int optionIndex, bool isCorrect) {
    if (selectedAnswers.containsKey(questionIndex)) return;

    setState(() {
      selectedAnswers[questionIndex] = optionIndex;
      showFeedback[questionIndex] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Text(isCorrect ? 'Jawaban Benar! 🎉' : 'Jawaban Salah 😔', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: isCorrect ? AppColors.green : AppColors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResultDialog() {
    int correctCount = 0;
    int wrongCount = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final selectedIndex = selectedAnswers[i];
      if (selectedIndex != null) {
        if (selectedIndex == widget.questions[i].correctIndex) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }

    final totalQuestions = widget.questions.length;
    final score = (correctCount / totalQuestions * 100).round();
    final needRetry = wrongCount >= 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(needRetry ? Icons.refresh : Icons.celebration, color: needRetry ? AppColors.orange : AppColors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(needRetry ? 'Perlu Mengulang' : 'Selamat!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.softTeal, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text('Nilai Kamu', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text('$score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.blue)),
                    const SizedBox(height: 4),
                    Text('Benar: $correctCount / Salah: $wrongCount', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Pesan Singkat
              Text(
                needRetry 
                  ? 'Kamu salah $wrongCount soal. Ayo coba lagi!' 
                  : 'Hebat! Kamu menguasai materi ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: needRetry ? AppColors.orange : AppColors.green,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (needRetry) {
                setState(() { selectedAnswers.clear(); showFeedback.clear(); });
              } else {
                await UserProgressService.incrementMaterialCount();
                widget.onFinish(true);
              }
            },
            child: Text(needRetry ? 'Ulangi Step' : 'Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: needRetry ? AppColors.orange : AppColors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = ["A", "B", "C", "D"];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.softTeal, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("📖", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(widget.isEasyMode ? "Latihan Membaca (Mudah)" : "Latihan Membaca (Sulit)", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Baca teks dan pilih jawaban yang benar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              ...List.generate(widget.questions.length, (index) {
                final q = widget.questions[index];
                final selectedIndex = selectedAnswers[index];
                final isAnswered = selectedIndex != null;
                final isCorrectAnswer = isAnswered && selectedIndex == q.correctIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Soal ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blue)),
                      const SizedBox(height: 8),
                      Text(q.text, style: const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 12),
                      
                      ...List.generate(q.options.length, (optIndex) {
                        final isSelected = selectedIndex == optIndex;
                        final isCorrect = optIndex == q.correctIndex;
                        final showCorrect = isAnswered && isCorrectAnswer && isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AnswerButton(
                            label: labels[optIndex],
                            visual: q.options[optIndex],
                            isCorrect: isCorrect,
                            isSelected: isSelected,
                            showCorrect: showCorrect,
                            isDisabled: isAnswered,
                            onTap: () => _handleAnswerTap(index, optIndex, isCorrect),
                          ),
                        );
                      }),
                      
                      if (isAnswered && !isCorrectAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.red, width: 2),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.cancel, color: AppColors.red, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Jawaban salah. Coba lagi!',
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswers.length == widget.questions.length ? () => _showResultDialog() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswers.length == widget.questions.length ? AppColors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    selectedAnswers.length == widget.questions.length ? "Selesai Step Ini" : "Jawab Semua Soal (${selectedAnswers.length}/${widget.questions.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}