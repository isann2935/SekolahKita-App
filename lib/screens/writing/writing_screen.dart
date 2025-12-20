import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../theme/colors.dart';
import '../../data/writing_data.dart';

class WritingScreen extends StatefulWidget {
  final int step;
  final VoidCallback onBack;
  final Function(bool canProceed) onComplete;

  const WritingScreen({
    super.key,
    required this.step,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isDrawing = false;
  bool _isCompleted = false;
  int _currentLetterIndex = 0;
  
  // Untuk validasi tracing
  double _accuracy = 0.0;
  String _feedbackMessage = '';
  bool _showFeedback = false;
  
  // Canvas size untuk kalkulasi
  Size _canvasSize = Size.zero;

  WritingStep get currentStep => writingSteps[widget.step - 1];

  String get currentLetter {
    if (currentStep.isLetterStep && currentStep.letters != null) {
      return currentStep.letters![_currentLetterIndex];
    }
    return '';
  }

  String get currentWord {
    if (currentStep.isWordStep && currentStep.word != null) {
      return currentStep.word!;
    }
    return '';
  }

  int get totalLetters {
    if (currentStep.isLetterStep && currentStep.letters != null) {
      return currentStep.letters!.length;
    }
    return 1;
  }

  bool get isLastLetter => _currentLetterIndex >= totalLetters - 1;

  void _clearDrawing() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _isCompleted = false;
      _accuracy = 0.0;
      _feedbackMessage = '';
      _showFeedback = false;
    });
  }

  void _nextLetter() {
    if (!isLastLetter) {
      setState(() {
        _currentLetterIndex++;
        _strokes.clear();
        _currentStroke = [];
        _isCompleted = false;
        _accuracy = 0.0;
        _feedbackMessage = '';
        _showFeedback = false;
      });
    } else {
      widget.onComplete(true);
    }
  }

  void _previousLetter() {
    if (_currentLetterIndex > 0) {
      setState(() {
        _currentLetterIndex--;
        _strokes.clear();
        _currentStroke = [];
        _isCompleted = false;
        _accuracy = 0.0;
        _feedbackMessage = '';
        _showFeedback = false;
      });
    }
  }

  // Validasi apakah user sudah mengikuti garis dengan benar
  void _validateTracing() {
    if (_strokes.isEmpty) {
      setState(() {
        _isCompleted = false;
        _showFeedback = true;
        _feedbackMessage = 'Silakan gambar huruf terlebih dahulu!';
        _accuracy = 0.0;
      });
      return;
    }

    // Dapatkan semua titik dari strokes user
    List<Offset> allUserPoints = [];
    for (var stroke in _strokes) {
      allUserPoints.addAll(stroke);
    }

    if (allUserPoints.length < 20) {
      setState(() {
        _isCompleted = false;
        _showFeedback = true;
        _feedbackMessage = 'Gambar terlalu pendek, coba lagi!';
        _accuracy = 0.0;
      });
      return;
    }

    // Dapatkan path reference
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final letterSize = currentStep.isWordStep 
        ? _canvasSize.width * 0.1 
        : _canvasSize.width * 0.7;
    
    List<Offset> guidePoints;
    if (currentStep.isWordStep) {
      guidePoints = _getWordGuidePoints(_canvasSize);
    } else {
      guidePoints = _getLetterGuidePoints(currentLetter, center, letterSize);
    }

    // Tolerance ULTRA KETAT! 
    final tolerance = currentStep.isWordStep ? 12.0 : 15.0;

    // === EXCESS DRAWING CHECK ===
    // Jika user gambar terlalu banyak (lebih dari 150% panjang guide), kemungkinan besar huruf salah
    final maxAllowedPoints = (guidePoints.length * 2.0).toInt();
    final isExcessiveDrawing = allUserPoints.length > maxAllowedPoints;

    // === ACCURACY CHECK ===
    // Berapa persen titik USER yang dekat dengan guide (harus on-track)
    int userPointsNearGuide = 0;
    for (var userPoint in allUserPoints) {
      bool isNearGuide = guidePoints.any((guidePoint) {
        final distance = (userPoint - guidePoint).distance;
        return distance <= tolerance;
      });
      if (isNearGuide) {
        userPointsNearGuide++;
      }
    }
    final accuracy = (userPointsNearGuide / allUserPoints.length) * 100;

    // === COVERAGE CHECK ===
    // Berapa persen titik GUIDE yang sudah ditutupi oleh user
    int guideCovered = 0;
    for (var guidePoint in guidePoints) {
      bool isCovered = allUserPoints.any((userPoint) {
        final distance = (userPoint - guidePoint).distance;
        return distance <= tolerance;
      });
      if (isCovered) {
        guideCovered++;
      }
    }
    final coverage = (guideCovered / guidePoints.length) * 100;

    // === OFF-TRACK PENALTY (SANGAT KETAT) ===
    // Hitung berapa banyak titik user yang JAUH dari guide (penalty)
    int offTrackPoints = 0;
    final offTrackTolerance = currentStep.isWordStep ? 18.0 : 22.0;
    for (var userPoint in allUserPoints) {
      bool isFarFromGuide = !guidePoints.any((guidePoint) {
        final distance = (userPoint - guidePoint).distance;
        return distance <= offTrackTolerance;
      });
      if (isFarFromGuide) {
        offTrackPoints++;
      }
    }
    final offTrackRatio = offTrackPoints / allUserPoints.length;

    // === DRAWING EFFICIENCY CHECK ===
    // Rasio titik yang berguna vs total titik - jika rendah, user gambar banyak yang tidak perlu
    final drawingEfficiency = userPointsNearGuide / allUserPoints.length;

    // Score calculation
    final rawScore = (accuracy * 0.5 + coverage * 0.5);
    // Penalty berat jika off-track atau drawing tidak efisien
    final efficiencyPenalty = drawingEfficiency < 0.7 ? 0.7 : 1.0;
    final excessPenalty = isExcessiveDrawing ? 0.6 : 1.0;
    final offTrackPenalty = (1 - offTrackRatio).clamp(0.3, 1.0);
    final finalScore = rawScore * efficiencyPenalty * excessPenalty * offTrackPenalty;
    
    setState(() {
      _accuracy = finalScore;
      _showFeedback = true;
      
      // Kriteria ULTRA KETAT:
      // - Accuracy >= 90% (hampir semua titik user harus on-track)
      // - Coverage >= 85% (harus menutupi sebagian besar guide)
      // - Off-track ratio <= 15% (sangat sedikit yang boleh di luar)
      // - Drawing efficiency >= 70% (tidak boleh banyak goresan berlebihan)
      // - Tidak boleh excessive drawing
      final bool passAccuracy = accuracy >= 90;
      final bool passCoverage = coverage >= 85;
      final bool passOffTrack = offTrackRatio <= 0.15;
      final bool passEfficiency = drawingEfficiency >= 0.70;
      final bool passExcess = !isExcessiveDrawing;
      
      if (passAccuracy && passCoverage && passOffTrack && passEfficiency && passExcess) {
        _isCompleted = true;
        if (finalScore >= 90) {
          _feedbackMessage = 'Sempurna! 🌟';
        } else if (finalScore >= 75) {
          _feedbackMessage = 'Bagus sekali! ⭐';
        } else {
          _feedbackMessage = 'Cukup baik! Lanjutkan! 👍';
        }
      } else {
        _isCompleted = false;
        if (isExcessiveDrawing || !passEfficiency) {
          // User gambar terlalu banyak / huruf yang berbeda
          _feedbackMessage = 'Gambar HANYA huruf yang diminta! ❌';
        } else if (!passOffTrack || !passAccuracy) {
          // User gambar terlalu banyak di luar garis
          _feedbackMessage = 'Tetap di garis titik-titik! ✏️';
        } else if (!passCoverage) {
          // User belum menutupi cukup banyak garis guide
          _feedbackMessage = 'Ikuti SEMUA garis titik-titik! 📝';
        } else {
          _feedbackMessage = 'Coba lagi, ikuti garis dengan teliti! 📝';
        }
      }
    });
  }


  /// Mendapatkan titik-titik guide untuk huruf
  List<Offset> _getLetterGuidePoints(String letter, Offset center, double size) {
    final path = LetterPathHelper.getLetterPath(letter, center, size);
    return _samplePointsFromPath(path, 8.0);
  }

  /// Mendapatkan titik-titik guide untuk kata
  List<Offset> _getWordGuidePoints(Size canvasSize) {
    List<Offset> allPoints = [];
    final word = currentWord;
    final letterCount = word.length;
    final availableWidth = canvasSize.width - 40;
    final letterWidth = availableWidth / letterCount;
    final baseY = canvasSize.height * 0.5;

    for (int i = 0; i < letterCount; i++) {
      final letterX = 20 + letterWidth * i + letterWidth / 2;
      final center = Offset(letterX, baseY);
      final letterSize = (letterWidth * 0.75).clamp(35.0, 55.0);
      
      final path = LetterPathHelper.getLetterPath(word[i], center, letterSize);
      allPoints.addAll(_samplePointsFromPath(path, 6.0));
    }
    
    return allPoints;
  }

  /// Sample titik-titik dari path dengan interval tertentu
  List<Offset> _samplePointsFromPath(Path path, double spacing) {
    List<Offset> points = [];
    final metrics = path.computeMetrics();
    
    for (var metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          points.add(tangent.position);
        }
        distance += spacing;
      }
    }
    
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWordStep = currentStep.isWordStep;

    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildInstructions(isWordStep),
            const SizedBox(height: 12),
            if (currentStep.isLetterStep) _buildLetterProgress(),
            const SizedBox(height: 12),
            
            // Feedback message
            if (_showFeedback) _buildFeedback(),
            
            Expanded(
              child: Center(
                child: isWordStep
                    ? _buildWordCanvas(screenWidth, screenHeight)
                    : _buildLetterCanvas(screenWidth),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionButtons(isWordStep),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final isSuccess = _accuracy >= 60;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info_outline,
            color: isSuccess ? Colors.green : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _feedbackMessage,
            style: TextStyle(
              color: isSuccess ? Colors.green.shade700 : Colors.orange.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (_accuracy > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_accuracy.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Menulis - Step ${widget.step}",
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
    );
  }

  Widget _buildInstructions(bool isWordStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              isWordStep ? currentWord : "Huruf $currentLetter",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWordStep
                  ? "Ikuti garis titik-titik untuk menulis kata"
                  : "Ikuti garis titik-titik untuk menulis huruf",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalLetters, (index) {
          final isActive = index == _currentLetterIndex;
          final isCompleted = index < _currentLetterIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.blue
                  : isCompleted
                      ? AppColors.green
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                currentStep.letters![index],
                style: TextStyle(
                  color: isActive || isCompleted ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLetterCanvas(double screenWidth) {
    final canvasSize = screenWidth * 0.85;
    _canvasSize = Size(canvasSize, canvasSize);
    
    return Container(
      width: canvasSize,
      height: canvasSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: CustomPaint(
            painter: _DottedLetterPainter(
              letter: currentLetter,
              strokes: _strokes,
              currentStroke: _currentStroke,
            ),
            size: Size(canvasSize, canvasSize),
          ),
        ),
      ),
    );
  }

  Widget _buildWordCanvas(double screenWidth, double screenHeight) {
    final canvasWidth = screenWidth * 0.9;
    final canvasHeight = screenHeight * 0.32;
    _canvasSize = Size(canvasWidth, canvasHeight);
    
    return Container(
      width: canvasWidth,
      height: canvasHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: CustomPaint(
            painter: _DottedWordPainter(
              word: currentWord,
              strokes: _strokes,
              currentStroke: _currentStroke,
            ),
            size: Size(canvasWidth, canvasHeight),
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = [details.localPosition];
      _showFeedback = false; // Hide feedback saat mulai gambar baru
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isDrawing) {
      setState(() {
        _currentStroke.add(details.localPosition);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
      if (_currentStroke.isNotEmpty) {
        _strokes.add(List.from(_currentStroke));
        _currentStroke = [];
      }
    });
  }

  Widget _buildActionButtons(bool isWordStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          if (currentStep.isLetterStep && _currentLetterIndex > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _previousLetter,
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: _clearDrawing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_isCompleted) {
                  // Sudah tervalidasi, lanjut
                  if (currentStep.isLetterStep && !isLastLetter) {
                    _nextLetter();
                  } else {
                    widget.onComplete(true);
                  }
                } else {
                  // Belum tervalidasi, cek dulu
                  _validateTracing();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted ? AppColors.green : AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isCompleted
                    ? (currentStep.isLetterStep && !isLastLetter ? "Lanjut ➜" : "Selesai ✓")
                    : "Periksa",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class untuk mendapatkan path huruf
class LetterPathHelper {
  static Path getLetterPath(String letter, Offset center, double size) {
    final path = Path();
    final h = size / 2;

    switch (letter.toUpperCase()) {
      case 'A':
        path.moveTo(center.dx, center.dy - h);
        path.lineTo(center.dx - h * 0.6, center.dy + h);
        path.moveTo(center.dx, center.dy - h);
        path.lineTo(center.dx + h * 0.6, center.dy + h);
        path.moveTo(center.dx - h * 0.35, center.dy + h * 0.2);
        path.lineTo(center.dx + h * 0.35, center.dy + h * 0.2);
        break;

      case 'B':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.1, center.dy - h);
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy - h,
          center.dx + h * 0.5, center.dy - h * 0.5,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy,
          center.dx - h * 0.4, center.dy,
        );
        path.moveTo(center.dx - h * 0.4, center.dy);
        path.lineTo(center.dx + h * 0.15, center.dy);
        path.quadraticBezierTo(
          center.dx + h * 0.55, center.dy,
          center.dx + h * 0.55, center.dy + h * 0.5,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.55, center.dy + h,
          center.dx - h * 0.4, center.dy + h,
        );
        break;

      case 'C':
        path.moveTo(center.dx + h * 0.4, center.dy - h * 0.8);
        path.quadraticBezierTo(
          center.dx - h * 0.1, center.dy - h * 1.1,
          center.dx - h * 0.5, center.dy - h * 0.3,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.7, center.dy + h * 0.3,
          center.dx - h * 0.5, center.dy + h * 0.7,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.1, center.dy + h * 1.1,
          center.dx + h * 0.4, center.dy + h * 0.8,
        );
        break;

      case 'D':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx, center.dy - h);
        path.quadraticBezierTo(
          center.dx + h * 0.6, center.dy - h,
          center.dx + h * 0.6, center.dy,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.6, center.dy + h,
          center.dx, center.dy + h,
        );
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        break;

      case 'E':
        path.moveTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        path.moveTo(center.dx - h * 0.4, center.dy);
        path.lineTo(center.dx + h * 0.2, center.dy);
        break;

      case 'F':
        path.moveTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.moveTo(center.dx - h * 0.4, center.dy);
        path.lineTo(center.dx + h * 0.2, center.dy);
        break;

      case 'G':
        path.moveTo(center.dx + h * 0.4, center.dy - h * 0.7);
        path.quadraticBezierTo(
          center.dx, center.dy - h * 1.1,
          center.dx - h * 0.5, center.dy - h * 0.3,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.7, center.dy + h * 0.3,
          center.dx - h * 0.5, center.dy + h * 0.7,
        );
        path.quadraticBezierTo(
          center.dx, center.dy + h * 1.1,
          center.dx + h * 0.5, center.dy + h * 0.5,
        );
        path.lineTo(center.dx + h * 0.5, center.dy);
        path.lineTo(center.dx, center.dy);
        break;

      case 'H':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.moveTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        path.moveTo(center.dx - h * 0.4, center.dy);
        path.lineTo(center.dx + h * 0.4, center.dy);
        break;

      case 'I':
        path.moveTo(center.dx - h * 0.25, center.dy - h);
        path.lineTo(center.dx + h * 0.25, center.dy - h);
        path.moveTo(center.dx, center.dy - h);
        path.lineTo(center.dx, center.dy + h);
        path.moveTo(center.dx - h * 0.25, center.dy + h);
        path.lineTo(center.dx + h * 0.25, center.dy + h);
        break;

      case 'J':
        path.moveTo(center.dx - h * 0.2, center.dy - h);
        path.lineTo(center.dx + h * 0.4, center.dy - h);
        path.moveTo(center.dx + h * 0.2, center.dy - h);
        path.lineTo(center.dx + h * 0.2, center.dy + h * 0.5);
        path.quadraticBezierTo(
          center.dx + h * 0.2, center.dy + h,
          center.dx - h * 0.2, center.dy + h,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.5, center.dy + h,
          center.dx - h * 0.5, center.dy + h * 0.6,
        );
        break;

      case 'K':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.moveTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        break;

      case 'L':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        break;

      case 'M':
        path.moveTo(center.dx - h * 0.5, center.dy + h);
        path.lineTo(center.dx - h * 0.5, center.dy - h);
        path.lineTo(center.dx, center.dy + h * 0.2);
        path.lineTo(center.dx + h * 0.5, center.dy - h);
        path.lineTo(center.dx + h * 0.5, center.dy + h);
        break;

      case 'N':
        path.moveTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        path.lineTo(center.dx + h * 0.4, center.dy - h);
        break;

      case 'O':
        path.addOval(
          Rect.fromCenter(
            center: center,
            width: size * 0.7,
            height: size * 0.9,
          ),
        );
        break;

      case 'P':
        path.moveTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.1, center.dy - h);
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy - h,
          center.dx + h * 0.5, center.dy - h * 0.3,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy + h * 0.2,
          center.dx - h * 0.4, center.dy + h * 0.2,
        );
        break;

      case 'Q':
        path.addOval(
          Rect.fromCenter(
            center: center,
            width: size * 0.65,
            height: size * 0.8,
          ),
        );
        path.moveTo(center.dx + h * 0.1, center.dy + h * 0.3);
        path.lineTo(center.dx + h * 0.5, center.dy + h);
        break;

      case 'R':
        path.moveTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.1, center.dy - h);
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy - h,
          center.dx + h * 0.5, center.dy - h * 0.3,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.5, center.dy + h * 0.15,
          center.dx - h * 0.4, center.dy + h * 0.15,
        );
        path.moveTo(center.dx, center.dy + h * 0.15);
        path.lineTo(center.dx + h * 0.45, center.dy + h);
        break;

      case 'S':
        path.moveTo(center.dx + h * 0.35, center.dy - h * 0.7);
        path.quadraticBezierTo(
          center.dx + h * 0.35, center.dy - h,
          center.dx, center.dy - h,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.45, center.dy - h,
          center.dx - h * 0.45, center.dy - h * 0.55,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.45, center.dy - h * 0.1,
          center.dx, center.dy,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.45, center.dy + h * 0.1,
          center.dx + h * 0.45, center.dy + h * 0.55,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.45, center.dy + h,
          center.dx, center.dy + h,
        );
        path.quadraticBezierTo(
          center.dx - h * 0.35, center.dy + h,
          center.dx - h * 0.35, center.dy + h * 0.7,
        );
        break;

      case 'T':
        path.moveTo(center.dx - h * 0.5, center.dy - h);
        path.lineTo(center.dx + h * 0.5, center.dy - h);
        path.moveTo(center.dx, center.dy - h);
        path.lineTo(center.dx, center.dy + h);
        break;

      case 'U':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h * 0.5);
        path.quadraticBezierTo(
          center.dx - h * 0.4, center.dy + h,
          center.dx, center.dy + h,
        );
        path.quadraticBezierTo(
          center.dx + h * 0.4, center.dy + h,
          center.dx + h * 0.4, center.dy + h * 0.5,
        );
        path.lineTo(center.dx + h * 0.4, center.dy - h);
        break;

      case 'V':
        path.moveTo(center.dx - h * 0.5, center.dy - h);
        path.lineTo(center.dx, center.dy + h);
        path.lineTo(center.dx + h * 0.5, center.dy - h);
        break;

      case 'W':
        path.moveTo(center.dx - h * 0.6, center.dy - h);
        path.lineTo(center.dx - h * 0.3, center.dy + h);
        path.lineTo(center.dx, center.dy - h * 0.2);
        path.lineTo(center.dx + h * 0.3, center.dy + h);
        path.lineTo(center.dx + h * 0.6, center.dy - h);
        break;

      case 'X':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        path.moveTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        break;

      case 'Y':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx, center.dy);
        path.lineTo(center.dx + h * 0.4, center.dy - h);
        path.moveTo(center.dx, center.dy);
        path.lineTo(center.dx, center.dy + h);
        break;

      case 'Z':
        path.moveTo(center.dx - h * 0.4, center.dy - h);
        path.lineTo(center.dx + h * 0.4, center.dy - h);
        path.lineTo(center.dx - h * 0.4, center.dy + h);
        path.lineTo(center.dx + h * 0.4, center.dy + h);
        break;

      default:
        path.moveTo(center.dx - h, center.dy);
        path.lineTo(center.dx + h, center.dy);
    }

    return path;
  }
}

/// Custom Painter untuk menggambar huruf dengan titik-titik putus-putus
class _DottedLetterPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _DottedLetterPainter({
    required this.letter,
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final letterSize = size.width * 0.7;

    _drawDottedLetter(canvas, center, letterSize);
    _drawUserStrokes(canvas);
  }

  void _drawUserStrokes(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDottedLetter(Canvas canvas, Offset center, double letterSize) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = LetterPathHelper.getLetterPath(letter, center, letterSize);

    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0;
      const dotSpacing = 12.0;

      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 6, paint);
        }
        distance += dotSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom Painter untuk menggambar kata dengan titik-titik putus-putus
class _DottedWordPainter extends CustomPainter {
  final String word;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _DottedWordPainter({
    required this.word,
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBaseline(canvas, size);
    _drawDottedWord(canvas, size);
    _drawUserStrokes(canvas);
  }

  void _drawUserStrokes(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke[0].dx, currentStroke[0].dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawBaseline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final baseY = size.height * 0.75;
    canvas.drawLine(
      Offset(20, baseY),
      Offset(size.width - 20, baseY),
      paint,
    );

    final topY = size.height * 0.25;
    paint.color = Colors.grey.shade200;
    canvas.drawLine(
      Offset(20, topY),
      Offset(size.width - 20, topY),
      paint,
    );
  }

  void _drawDottedWord(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final letterCount = word.length;
    final availableWidth = size.width - 40;
    final letterWidth = availableWidth / letterCount;
    final baseY = size.height * 0.5;

    for (int i = 0; i < letterCount; i++) {
      final letterX = 20 + letterWidth * i + letterWidth / 2;
      final center = Offset(letterX, baseY);
      final letterSize = (letterWidth * 0.75).clamp(35.0, 55.0);

      final path = LetterPathHelper.getLetterPath(word[i], center, letterSize);

      final metrics = path.computeMetrics();
      for (var metric in metrics) {
        double distance = 0;
        const dotSpacing = 8.0;

        while (distance < metric.length) {
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4, paint);
          }
          distance += dotSpacing;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
