/// Data untuk 10 step menulis (tracing huruf)
class WritingStep {
  final int step;
  final String letter; // Huruf yang akan ditrace
  final String displayName; // Nama huruf untuk ditampilkan

  const WritingStep({
    required this.step,
    required this.letter,
    required this.displayName,
  });
}

/// 10 step menulis dengan huruf A-Z
const List<WritingStep> writingSteps = [
  WritingStep(step: 1, letter: 'A', displayName: 'Huruf A'),
  WritingStep(step: 2, letter: 'B', displayName: 'Huruf B'),
  WritingStep(step: 3, letter: 'C', displayName: 'Huruf C'),
  WritingStep(step: 4, letter: 'D', displayName: 'Huruf D'),
  WritingStep(step: 5, letter: 'E', displayName: 'Huruf E'),
  WritingStep(step: 6, letter: 'F', displayName: 'Huruf F'),
  WritingStep(step: 7, letter: 'G', displayName: 'Huruf G'),
  WritingStep(step: 8, letter: 'H', displayName: 'Huruf H'),
  WritingStep(step: 9, letter: 'I', displayName: 'Huruf I'),
  WritingStep(step: 10, letter: 'J', displayName: 'Huruf J'),
];
