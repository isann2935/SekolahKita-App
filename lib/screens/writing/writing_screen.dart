import 'package:flutter/material.dart';
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
  final List<Offset> _points = [];
  bool _isDrawing = false;
  bool _isCompleted = false;

  WritingStep get currentStep => writingSteps[widget.step - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
            ),

            // Instructions
            Padding(
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
                      currentStep.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ikuti garis titik-titik untuk menulis huruf",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Drawing Canvas
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
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
                    child: CustomPaint(
                      painter: _DottedLetterPainter(
                        letter: currentStep.letter,
                        userPoints: _points,
                        isCompleted: _isCompleted,
                      ),
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _isDrawing = true;
                            _points.add(details.localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          if (_isDrawing) {
                            setState(() {
                              _points.add(details.localPosition);
                            });
                          }
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _isDrawing = false;
                            // Check if completed (user has drawn enough points)
                            if (_points.length > 20) {
                              _isCompleted = true;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _points.clear();
                          _isCompleted = false;
                        });
                      },
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCompleted
                          ? () {
                              widget.onComplete(true);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Selesai",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar huruf dengan titik-titik putus-putus
class _DottedLetterPainter extends CustomPainter {
  final String letter;
  final List<Offset> userPoints;
  final bool isCompleted;

  _DottedLetterPainter({
    required this.letter,
    required this.userPoints,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final letterSize = size.width * 0.6;

    // Draw dotted letter guide
    _drawDottedLetter(canvas, center, letterSize);

    // Draw user's drawing
    if (userPoints.isNotEmpty) {
      final paint = Paint()
        ..color = AppColors.blue
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < userPoints.length - 1; i++) {
        canvas.drawLine(userPoints[i], userPoints[i + 1], paint);
      }
    }
  }

  void _drawDottedLetter(Canvas canvas, Offset center, double letterSize) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Generate dotted path for each letter
    final path = _getLetterPath(letter, center, letterSize);

    // Draw path as dots
    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0;
      const dotSpacing = 15.0;

      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4, paint);
        }
        distance += dotSpacing;
      }
    }
  }

  Path _getLetterPath(String letter, Offset center, double size) {
    final path = Path();
    final halfSize = size / 2;

    switch (letter.toUpperCase()) {
      case 'A':
        path.moveTo(center.dx, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.4, center.dy);
        path.lineTo(center.dx + halfSize * 0.4, center.dy);
        break;
      case 'B':
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.3, center.dy - halfSize);
        path.quadraticBezierTo(
          center.dx + halfSize * 0.6,
          center.dy - halfSize,
          center.dx + halfSize * 0.6,
          center.dy,
        );
        path.quadraticBezierTo(
          center.dx + halfSize * 0.6,
          center.dy + halfSize,
          center.dx + halfSize * 0.3,
          center.dy + halfSize,
        );
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy);
        path.lineTo(center.dx + halfSize * 0.3, center.dy);
        break;
      case 'C':
        path.addArc(
          Rect.fromCenter(
            center: center,
            width: size * 0.8,
            height: size * 0.8,
          ),
          -1.57, // -90 degrees
          3.14, // 180 degrees
        );
        break;
      case 'D':
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.3, center.dy - halfSize);
        path.quadraticBezierTo(
          center.dx + halfSize * 0.6,
          center.dy - halfSize,
          center.dx + halfSize * 0.6,
          center.dy,
        );
        path.quadraticBezierTo(
          center.dx + halfSize * 0.6,
          center.dy + halfSize,
          center.dx + halfSize * 0.3,
          center.dy + halfSize,
        );
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        break;
      case 'E':
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.6, center.dy - halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy);
        path.lineTo(center.dx + halfSize * 0.4, center.dy);
        path.moveTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.lineTo(center.dx + halfSize * 0.6, center.dy + halfSize);
        break;
      case 'F':
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.6, center.dy - halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy);
        path.lineTo(center.dx + halfSize * 0.4, center.dy);
        break;
      case 'G':
        path.addArc(
          Rect.fromCenter(
            center: center,
            width: size * 0.8,
            height: size * 0.8,
          ),
          -1.57,
          3.14,
        );
        path.moveTo(center.dx + halfSize * 0.4, center.dy);
        path.lineTo(center.dx + halfSize * 0.6, center.dy);
        path.lineTo(center.dx + halfSize * 0.6, center.dy + halfSize * 0.3);
        break;
      case 'H':
        path.moveTo(center.dx - halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx - halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx + halfSize * 0.6, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.6, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.6, center.dy);
        path.lineTo(center.dx + halfSize * 0.6, center.dy);
        break;
      case 'I':
        path.moveTo(center.dx, center.dy - halfSize);
        path.lineTo(center.dx, center.dy + halfSize);
        path.moveTo(center.dx - halfSize * 0.3, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.3, center.dy - halfSize);
        path.moveTo(center.dx - halfSize * 0.3, center.dy + halfSize);
        path.lineTo(center.dx + halfSize * 0.3, center.dy + halfSize);
        break;
      case 'J':
        path.moveTo(center.dx + halfSize * 0.3, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.3, center.dy + halfSize * 0.3);
        path.quadraticBezierTo(
          center.dx + halfSize * 0.3,
          center.dy + halfSize,
          center.dx,
          center.dy + halfSize,
        );
        path.quadraticBezierTo(
          center.dx - halfSize * 0.3,
          center.dy + halfSize,
          center.dx - halfSize * 0.3,
          center.dy + halfSize * 0.6,
        );
        path.moveTo(center.dx - halfSize * 0.2, center.dy - halfSize);
        path.lineTo(center.dx + halfSize * 0.2, center.dy - halfSize);
        break;
      default:
        // Default: simple line
        path.moveTo(center.dx - halfSize, center.dy);
        path.lineTo(center.dx + halfSize, center.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
