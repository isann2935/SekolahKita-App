import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../data/reading_questions.dart';
import '../../services/custom_question_service.dart'; // Import service soal buatan sendiri

// DATA SOAL
class BattleQuestion {
  final String text;
  final String correctAnswer;
  final List<String> options;
  final bool isMath;

  BattleQuestion({
    required this.text,
    required this.correctAnswer,
    required this.options,
    required this.isMath,
  });
}

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  // --- STATE GAME ---
  int scoreP1 = 0;
  int scoreP2 = 0;
  String? winner;

  // --- TIMER UTAMA ---
  Timer? _gameTimer;
  int remainingSeconds = 120; // 2 Menit

  // --- DATA SOAL ---
  late BattleQuestion qP1;
  late BattleQuestion qP2;
  List<ReadingQuestion> allReadingQuestions = [];
  bool isDataLoaded = false; // Penanda apakah data sudah siap

  // --- FEEDBACK ERROR PER PEMAIN ---
  String? feedbackP1;
  String? feedbackP2;
  Timer? _feedbackTimerP1;
  Timer? _feedbackTimerP2;

  @override
  void initState() {
    super.initState();
    _initGameData();
  }

  // 🔥 PERBAIKAN: Fungsi inisialisasi Data (Async)
  void _initGameData() async {
    await _loadAllReadingQuestions(); // Tunggu load soal bawaan + custom selesai
    
    // Generate soal awal setelah data siap
    qP1 = _generateNewQuestion();
    qP2 = _generateNewQuestion();
    
    setState(() {
      isDataLoaded = true;
    });

    _startGameTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _feedbackTimerP1?.cancel();
    _feedbackTimerP2?.cancel();
    super.dispose();
  }

  // --- LOGIKA TIMER ---
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    _gameTimer?.cancel();
    setState(() {
      if (scoreP1 > scoreP2) {
        winner = 'Player 1 (Merah)';
      } else if (scoreP2 > scoreP1) {
        winner = 'Player 2 (Biru)';
      } else {
        winner = 'Seri!';
      }
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // 🔥 PERBAIKAN: Load Soal Bawaan + Soal Custom Orang Tua
  Future<void> _loadAllReadingQuestions() async {
    try {
      // 1. Ambil Soal Bawaan
      List<ReadingQuestion> defaultQuestions = [
        ...easyReadingSteps.expand((step) => step),
        ...hardReadingSteps.expand((step) => step),
      ];

      // 2. Ambil Soal Custom (Buatan Sendiri)
      List<CustomQuestionModel> customQuestions = await CustomQuestionService.getQuestions();
      
      List<ReadingQuestion> convertedCustoms = customQuestions.map((c) {
        List<String> opts = [...c.wrongAnswers, c.correctAnswer];
        return ReadingQuestion(
           text: c.text,
           options: opts, 
           correctIndex: 3, // Sementara ditaruh di akhir, nanti diacak di generator
        );
      }).toList();

      // 3. Gabung Semua
      allReadingQuestions = [...defaultQuestions, ...convertedCustoms];
      allReadingQuestions.shuffle();
      
    } catch (e) {
      debugPrint("Gagal load soal: $e");
    }
  }

  // GENERATOR SOAL
  BattleQuestion _generateNewQuestion() {
    Random rand = Random();
    // Cek apakah list kosong untuk menghindari crash
    bool useMath = allReadingQuestions.isEmpty || rand.nextBool();

    if (useMath) {
      return _generateMathQuestion(rand);
    } else {
      return _generateReadingQuestion(rand);
    }
  }

  BattleQuestion _generateMathQuestion(Random rand) {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;
    bool isPlus = rand.nextBool();
    String text;
    int result;

    if (isPlus) {
      text = "$a + $b = ?";
      result = a + b;
    } else {
      if (a < b) { int t = a; a = b; b = t; }
      text = "$a - $b = ?";
      result = a - b;
    }

    String correct = result.toString();
    Set<String> optSet = {correct};
    while (optSet.length < 4) {
      int wrong = result + (rand.nextInt(10) - 5);
      if (wrong >= 0 && wrong != result) optSet.add(wrong.toString());
    }
    return BattleQuestion(
      text: text, 
      correctAnswer: correct, 
      options: optSet.toList()..shuffle(), 
      isMath: true
    );
  }

  BattleQuestion _generateReadingQuestion(Random rand) {
    if (allReadingQuestions.isEmpty) return _generateMathQuestion(rand); // Fallback

    final q = allReadingQuestions[rand.nextInt(allReadingQuestions.length)];
    return BattleQuestion(
      text: q.text, 
      correctAnswer: q.options[q.correctIndex], 
      options: List<String>.from(q.options)..shuffle(), 
      isMath: false
    );
  }

  // --- LOGIKA JAWAB ---
  void _handleAnswer(String player, String answer) {
    if (winner != null) return;

    setState(() {
      if (player == 'P1') {
        if (answer == qP1.correctAnswer) {
          scoreP1++;
          qP1 = _generateNewQuestion();
          feedbackP1 = null;
        } else {
          _showFeedbackP1("Salah! ❌");
        }
      } else {
        if (answer == qP2.correctAnswer) {
          scoreP2++;
          qP2 = _generateNewQuestion();
          feedbackP2 = null;
        } else {
          _showFeedbackP2("Salah! ❌");
        }
      }
    });
  }

  void _showFeedbackP1(String msg) {
    setState(() => feedbackP1 = msg);
    _feedbackTimerP1?.cancel();
    _feedbackTimerP1 = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => feedbackP1 = null);
    });
  }

  void _showFeedbackP2(String msg) {
    setState(() => feedbackP2 = msg);
    _feedbackTimerP2?.cancel();
    _feedbackTimerP2 = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => feedbackP2 = null);
    });
  }

  void _resetGame() {
    setState(() {
      scoreP1 = 0;
      scoreP2 = 0;
      remainingSeconds = 120;
      winner = null;
      qP1 = _generateNewQuestion();
      qP2 = _generateNewQuestion();
      feedbackP1 = null;
      feedbackP2 = null;
      _startGameTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan Loading jika data belum siap
    if (!isDataLoaded) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isUrgent = remainingSeconds <= 10;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // === PLAYER 1 (ATAS) ===
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: _buildPlayerCard(
                        playerLabel: "Player 1",
                        color: AppColors.red,
                        score: scoreP1,
                        questionData: qP1,
                        feedbackText: feedbackP1,
                        onTapAnswer: (val) => _handleAnswer('P1', val),
                      ),
                    ),
                  ),
                ),

                // === PLAYER 2 (BAWAH) ===
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: _buildPlayerCard(
                      playerLabel: "Player 2",
                      color: AppColors.blue,
                      score: scoreP2,
                      questionData: qP2,
                      feedbackText: feedbackP2,
                      onTapAnswer: (val) => _handleAnswer('P2', val),
                    ),
                  ),
                ),
              ],
            ),

            // === TIMER ===
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isUrgent ? AppColors.red : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isUrgent ? Colors.white : AppColors.yellow, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isUrgent)
                        const Text("SISA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        _formatTime(remainingSeconds),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isUrgent ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(target: isUrgent ? 1 : 0).shake(hz: 4),
            ),

            // Tombol Back
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.small(
                  heroTag: "btn_back_battle",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Popup Menang
            if (winner != null)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("⏱️ WAKTU HABIS! ⏱️", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text("🏆 PEMENANG 🏆", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          winner!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: winner!.contains('Merah')
                                ? AppColors.red
                                : (winner!.contains('Biru') ? AppColors.blue : Colors.orange),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Skor Akhir: $scoreP1 - $scoreP2",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Keluar")),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
                              child: const Text("Main Lagi"),
                            ),
                          ],
                        )
                      ],
                    ).animate().scale(curve: Curves.elasticOut, duration: 800.ms).then().shimmer(duration: 1200.ms),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 WIDGET KARTU PEMAIN (Fixed & Scrollable)
  Widget _buildPlayerCard({
    required String playerLabel,
    required Color color,
    required int score,
    required BattleQuestion questionData,
    required String? feedbackText,
    required Function(String) onTapAnswer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Skor Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: color.withOpacity(0.1),
              child: Text(
                "$playerLabel: $score Poin",
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            // AREA SOAL (Expanded)
            Expanded(
              child: Stack(
                children: [
                  // Teks Soal (Scrollable)
                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        questionData.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: questionData.isMath ? 56 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Feedback Error Overlay
                  if (feedbackText != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: Text(
                          feedbackText,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ).animate().scale(curve: Curves.elasticOut, duration: 300.ms),
                    ),
                ],
              ),
            ),

            // Tombol Jawaban (Scrollable)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade50,
              child: SizedBox(
                height: 150,
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.0, // 🔥 PERBAIKAN: Ubah jadi 2.0 biar tombol lebih tinggi/luas
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: questionData.options.map((opt) {
                    return ElevatedButton(
                      onPressed: () => onTapAnswer(opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        shadowColor: color.withOpacity(0.3),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: color.withOpacity(0.2)),
                        ),
                      ),
                      // 🔥 SCROLLABLE JAWABAN
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            opt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // Logic Font Pintar
                              fontSize: opt.length > 25 ? 14 : (opt.length > 10 ? 16 : 24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}