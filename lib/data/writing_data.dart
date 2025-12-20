/// Data untuk 10 step menulis
/// Step 1-5: Huruf A-Z (setiap step berisi beberapa huruf)
/// Step 6-10: Kata sederhana

class WritingStep {
  final int step;
  final String type; // 'letter' atau 'word'
  final List<String>? letters; // Untuk step 1-5 (huruf yang akan ditrace)
  final String? word; // Untuk step 6-10 (kata yang akan ditrace)
  final String displayName; // Nama untuk ditampilkan

  const WritingStep({
    required this.step,
    required this.type,
    this.letters,
    this.word,
    required this.displayName,
  });

  /// Cek apakah ini step huruf
  bool get isLetterStep => type == 'letter';

  /// Cek apakah ini step kata
  bool get isWordStep => type == 'word';
}

/// 10 step menulis
/// Step 1-5: Huruf A-Z dibagi per kelompok
/// Step 6-10: Kata sederhana
const List<WritingStep> writingSteps = [
  // Step 1-5: Huruf (setiap step memiliki beberapa huruf untuk ditrace)
  WritingStep(
    step: 1,
    type: 'letter',
    letters: ['A', 'B', 'C', 'D', 'E'],
    displayName: 'Huruf A - E',
  ),
  WritingStep(
    step: 2,
    type: 'letter',
    letters: ['F', 'G', 'H', 'I', 'J'],
    displayName: 'Huruf F - J',
  ),
  WritingStep(
    step: 3,
    type: 'letter',
    letters: ['K', 'L', 'M', 'N', 'O'],
    displayName: 'Huruf K - O',
  ),
  WritingStep(
    step: 4,
    type: 'letter',
    letters: ['P', 'Q', 'R', 'S', 'T'],
    displayName: 'Huruf P - T',
  ),
  WritingStep(
    step: 5,
    type: 'letter',
    letters: ['U', 'V', 'W', 'X', 'Y', 'Z'],
    displayName: 'Huruf U - Z',
  ),

  // Step 6-10: Kata sederhana
  WritingStep(
    step: 6,
    type: 'word',
    word: 'IBU',
    displayName: 'Kata: IBU',
  ),
  WritingStep(
    step: 7,
    type: 'word',
    word: 'BUKU',
    displayName: 'Kata: BUKU',
  ),
  WritingStep(
    step: 8,
    type: 'word',
    word: 'MAKAN',
    displayName: 'Kata: MAKAN',
  ),
  WritingStep(
    step: 9,
    type: 'word',
    word: 'TIDUR',
    displayName: 'Kata: TIDUR',
  ),
  WritingStep(
    step: 10,
    type: 'word',
    word: 'SEKOLAH',
    displayName: 'Kata: SEKOLAH',
  ),
];
