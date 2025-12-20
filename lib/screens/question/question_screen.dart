import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../data/reading_questions.dart';

class QuestionScreen extends StatelessWidget {
  /// Nama pelajaran (contoh: "Membaca", "Berhitung").
  final String subject;

  /// Level yang dipilih di peta (1, 2, 3, ...).
  final int level;

  /// Mode: "mudah" (hijau) atau "sulit" (oranye).
  final String mode;

  final VoidCallback onBack;
  final Function(bool) onComplete;

  const QuestionScreen({
    super.key,
    required this.subject,
    required this.level,
    required this.mode,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    "Level $level - $subject",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Question Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Builder(
                  builder: (context) {
                    if (subject == "Membaca") {
                      final stepIndex = (level - 1).clamp(0, 4);
                      final isEasyMode = mode == "mudah";
                      final stepQuestions = isEasyMode
                          ? easyReadingSteps[stepIndex]
                          : hardReadingSteps[stepIndex];

                      return _ReadingStepCard(
                        questions: stepQuestions,
                        isEasyMode: isEasyMode,
                        onFinish: (bool canProceed) => onComplete(canProceed),
                      );
                    }

                    return _MathQuestionCard(onComplete: onComplete);
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
        // Jawaban yang dipilih dan benar
        bgColor = AppColors.green.withOpacity(0.1);
        labelBgColor = AppColors.green;
        borderColor = AppColors.green;
      } else if (isSelected && !isCorrect) {
        // Jawaban yang dipilih tapi salah
        bgColor = AppColors.red.withOpacity(0.1);
        labelBgColor = AppColors.red;
        borderColor = AppColors.red;
      } else if (showCorrect) {
        // Jawaban yang benar (tapi tidak dipilih)
        bgColor = AppColors.green.withOpacity(0.1);
        labelBgColor = AppColors.green;
        borderColor = AppColors.green;
      } else {
        // Jawaban lain yang tidak dipilih
        bgColor = Colors.grey.shade100;
        labelBgColor = Colors.grey.shade400;
      }
    } else if (isSelected) {
      // Sedang dipilih (belum disabled)
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

/// Kartu soal berhitung sederhana (fallback untuk pelajaran selain Membaca).
class _MathQuestionCard extends StatelessWidget {
  final Function(bool) onComplete;

  const _MathQuestionCard({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lightbulb, color: AppColors.orange),
                    SizedBox(width: 8),
                    Text("Mari Belajar Penjumlahan!"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.orange,
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 28,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).shake(delay: 2000.ms),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Jika kamu punya 3 Apel dan ditambah 2 Apel, berapa semuanya?",
                      style: TextStyle(fontSize: 18, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Visual Aid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // Light Yellow
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "🍎🍎🍎 + 🍎🍎 = ❓",
                  style: TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(height: 20),
              // Mascot Hint
              Row(
                children: [
                  const Text("🦉", style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("Hitung semua apel dari 1 sampai 5!"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "Pilih Jawaban:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _AnswerButton(
                label: "4",
                visual: "🍎🍎🍎🍎",
                onTap: () => onComplete(false),
              ),
              const SizedBox(height: 12),
              _AnswerButton(
                label: "5",
                visual: "🍎🍎🍎🍎🍎",
                isCorrect: true,
                onTap: () => onComplete(true),
              ),
              const SizedBox(height: 12),
              _AnswerButton(
                label: "6",
                visual: "🍎🍎🍎🍎🍎🍎",
                onTap: () => onComplete(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu untuk 1 step membaca: menampilkan 5 soal sekaligus.
class _ReadingStepCard extends StatefulWidget {
  final List<ReadingQuestion> questions;
  final bool isEasyMode;
  final Function(bool canProceed)
  onFinish; // canProceed: true jika benar >= 3, false jika perlu retry

  const _ReadingStepCard({
    required this.questions,
    required this.isEasyMode,
    required this.onFinish,
  });

  @override
  State<_ReadingStepCard> createState() => _ReadingStepCardState();
}

class _ReadingStepCardState extends State<_ReadingStepCard> {
  // Track jawaban yang dipilih untuk setiap soal: Map<questionIndex, selectedOptionIndex>
  final Map<int, int?> selectedAnswers = {};
  // Track apakah sudah menampilkan feedback untuk setiap soal
  final Map<int, bool> showFeedback = {};

  void _handleAnswerTap(int questionIndex, int optionIndex, bool isCorrect) {
    if (selectedAnswers.containsKey(questionIndex)) {
      // Sudah menjawab, jangan biarkan ubah jawaban
      return;
    }

    setState(() {
      selectedAnswers[questionIndex] = optionIndex;
      showFeedback[questionIndex] = true;
    });

    // Tampilkan feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? 'Jawaban Benar! 🎉' : 'Jawaban Salah 😔',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: isCorrect ? AppColors.green : AppColors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResultDialog() {
    // Hitung jumlah jawaban benar dan salah
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

    // Tampilkan jawaban benar untuk semua soal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              needRetry ? Icons.refresh : Icons.celebration,
              color: needRetry ? AppColors.orange : AppColors.green,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                needRetry ? 'Perlu Mengulang' : 'Selamat!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Nilai Kamu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Benar: $correctCount / Salah: $wrongCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pesan berdasarkan hasil
              if (needRetry)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.orange, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kamu salah $wrongCount dari $totalQuestions soal. Silakan ulangi step ini untuk memperbaiki pemahamanmu!',
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kamu sudah menguasai step ini! Lanjutkan ke step berikutnya.',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Daftar jawaban user
              const Text(
                'Jawaban Kamu:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(widget.questions.length, (index) {
                final q = widget.questions[index];
                final selectedIndex = selectedAnswers[index];
                final isCorrect =
                    selectedIndex != null && selectedIndex == q.correctIndex;

                // Tampilkan jawaban yang dipilih user, bukan jawaban benar
                final displayedAnswer = selectedIndex != null
                    ? q.options[selectedIndex]
                    : 'Belum dijawab';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.green.withOpacity(0.1)
                          : AppColors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? AppColors.green : AppColors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? AppColors.green : AppColors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Soal ${index + 1}: $displayedAnswer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isCorrect
                                  ? AppColors.green
                                  : AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (needRetry) {
                // Reset jawaban untuk mengulang
                setState(() {
                  selectedAnswers.clear();
                  showFeedback.clear();
                });
              } else {
                // Lanjut ke step berikutnya (benar >= 3)
                widget.onFinish(true);
              }
            },
            child: Text(
              needRetry ? 'Ulangi Step' : 'Lanjutkan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: needRetry ? AppColors.orange : AppColors.green,
              ),
            ),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("📖", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEasyMode
                          ? "Latihan Membaca (Mudah)"
                          : "Latihan Membaca (Sulit)",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Baca teks dan pilih jawaban yang benar:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...List.generate(widget.questions.length, (index) {
                final q = widget.questions[index];
                final selectedIndex = selectedAnswers[index];
                final isAnswered = selectedIndex != null;
                final isCorrectAnswer =
                    isAnswered && selectedIndex == q.correctIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Soal ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q.text,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(q.options.length, (optIndex) {
                        final isSelected = selectedIndex == optIndex;
                        final isCorrect = optIndex == q.correctIndex;
                        // Hanya tampilkan jawaban benar jika user menjawab benar
                        // Jika user menjawab salah, jangan tampilkan jawaban benar
                        final showCorrect =
                            isAnswered && isCorrectAnswer && isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AnswerButton(
                            label: labels[optIndex],
                            visual: q.options[optIndex],
                            isCorrect: isCorrect,
                            isSelected: isSelected,
                            showCorrect: showCorrect,
                            isDisabled: isAnswered,
                            onTap: () =>
                                _handleAnswerTap(index, optIndex, isCorrect),
                          ),
                        );
                      }),
                      // Tampilkan feedback text jika sudah menjawab (hanya untuk jawaban benar)
                      if (isAnswered && isCorrectAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.green,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Benar! Jawaban kamu tepat.',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Tampilkan feedback untuk jawaban salah (tanpa menunjukkan jawaban benar)
                      if (isAnswered && !isCorrectAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.red,
                                width: 2,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.cancel,
                                  color: AppColors.red,
                                  size: 20,
                                ),
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
                  onPressed: selectedAnswers.length == widget.questions.length
                      ? () => _showResultDialog()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedAnswers.length == widget.questions.length
                        ? AppColors.green
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    selectedAnswers.length == widget.questions.length
                        ? "Selesai Step Ini"
                        : "Jawab Semua Soal (${selectedAnswers.length}/${widget.questions.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
