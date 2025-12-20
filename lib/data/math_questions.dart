/// Model untuk soal berhitung/matematika
class MathQuestion {
  final String questionText; // Teks soal
  final String visual; // Visual emoji (contoh: 🍎🍎 + 🍎🍎🍎 = …)
  final List<String> options; // Pilihan jawaban
  final int correctIndex; // Index jawaban benar (0-based)
  final String hint; // Petunjuk untuk anak-anak

  const MathQuestion({
    required this.questionText,
    required this.visual,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });
}

/// ========================================
/// SOAL BERHITUNG MODE MUDAH (5 step, masing-masing 5 soal)
/// ========================================

const List<List<MathQuestion>> easyMathSteps = [
  // Step 1 - Penjumlahan dan Pengurangan Dasar (1-6)
  [
    MathQuestion(
      questionText: "Hitung berapa jumlah apel semuanya?",
      visual: "🍎🍎 + 🍎🍎🍎 = …",
      options: ["4", "5", "6", "3"],
      correctIndex: 1, // 5
      hint: "Hitung semua apel satu per satu!",
    ),
    MathQuestion(
      questionText: "Berapa sisa bintang setelah dikurangi?",
      visual: "⭐⭐⭐⭐ − ⭐⭐ = …",
      options: ["1", "2", "3", "4"],
      correctIndex: 1, // 2
      hint: "Ambil 2 bintang, berapa yang tersisa?",
    ),
    MathQuestion(
      questionText: "Hitung berapa jumlah anjing semuanya?",
      visual: "🐶🐶🐶 + 🐶 = …",
      options: ["3", "5", "4", "6"],
      correctIndex: 2, // 4
      hint: "3 anjing ditambah 1 anjing lagi!",
    ),
    MathQuestion(
      questionText: "Berapa sisa balon setelah dikurangi?",
      visual: "🎈🎈🎈🎈🎈 − 🎈🎈 = …",
      options: ["2", "3", "4", "5"],
      correctIndex: 1, // 3
      hint: "5 balon dikurangi 2 balon!",
    ),
    MathQuestion(
      questionText: "Hitung berapa jumlah pisang semuanya?",
      visual: "🍌🍌 + 🍌🍌🍌🍌 = …",
      options: ["5", "6", "7", "4"],
      correctIndex: 1, // 6
      hint: "2 pisang ditambah 4 pisang!",
    ),
  ],

  // Step 2 - Penjumlahan dan Pengurangan (1-7)
  [
    MathQuestion(
      questionText: "Hitung berapa jumlah jeruk semuanya?",
      visual: "🍊🍊🍊 + 🍊🍊🍊🍊 = …",
      options: ["6", "7", "8", "5"],
      correctIndex: 1, // 7
      hint: "3 jeruk ditambah 4 jeruk!",
    ),
    MathQuestion(
      questionText: "Berapa sisa kucing setelah dikurangi?",
      visual: "🐱🐱🐱🐱🐱🐱 − 🐱🐱🐱 = …",
      options: ["2", "3", "4", "5"],
      correctIndex: 1, // 3
      hint: "6 kucing dikurangi 3 kucing!",
    ),
    MathQuestion(
      questionText: "Hitung berapa jumlah bunga semuanya?",
      visual: "🌸🌸🌸🌸 + 🌸🌸 = …",
      options: ["5", "6", "7", "4"],
      correctIndex: 1, // 6
      hint: "4 bunga ditambah 2 bunga!",
    ),
    MathQuestion(
      questionText: "Berapa sisa kue setelah dikurangi?",
      visual: "🍰🍰🍰🍰🍰🍰🍰 − 🍰🍰🍰🍰 = …",
      options: ["2", "3", "4", "5"],
      correctIndex: 1, // 3
      hint: "7 kue dikurangi 4 kue!",
    ),
    MathQuestion(
      questionText: "Hitung berapa jumlah bola semuanya?",
      visual: "⚽⚽ + ⚽⚽⚽ = …",
      options: ["4", "5", "6", "3"],
      correctIndex: 1, // 5
      hint: "2 bola ditambah 3 bola!",
    ),
  ],

  // Step 3 - Soal Cerita dan Perbandingan
  [
    MathQuestion(
      questionText: "Ada 8 ayam, 3 masuk kandang. Berapa sisa ayam?",
      visual: "🐔🐔🐔🐔🐔🐔🐔🐔 − 🐔🐔🐔 = …",
      options: ["4", "5", "6", "7"],
      correctIndex: 1, // 5
      hint: "8 ayam dikurangi 3 ayam yang masuk kandang!",
    ),
    MathQuestion(
      questionText: "Mana lebih banyak: 6 mangga atau 4 mangga?",
      visual: "🥭🥭🥭🥭🥭🥭  atau  🥭🥭🥭🥭",
      options: ["4", "Sama", "5", "6"],
      correctIndex: 3, // 6
      hint: "Hitung dan bandingkan mana yang lebih banyak!",
    ),
    MathQuestion(
      questionText: "Ada 10 permen, dimakan 1. Berapa sisa permen?",
      visual: "🍬🍬🍬🍬🍬🍬🍬🍬🍬🍬 − 🍬 = …",
      options: ["8", "7", "9", "6"],
      correctIndex: 2, // 9
      hint: "10 permen dikurangi 1 permen!",
    ),
    MathQuestion(
      questionText: "Hitung loncat: 2, 4, 6, …",
      visual: "2 → 4 → 6 → ?",
      options: ["6", "7", "8", "10"],
      correctIndex: 2, // 8
      hint: "Setiap angka bertambah 2!",
    ),
    MathQuestion(
      questionText: "Berapa hasil penjumlahan berikut?",
      visual: "5 + 5 = …",
      options: ["8", "9", "10", "11"],
      correctIndex: 2, // 10
      hint: "5 ditambah 5 sama dengan?",
    ),
  ],

  // Step 4 - Soal Cerita Penjumlahan dan Pengurangan
  [
    MathQuestion(
      questionText: "Ali punya 10 apel, diberi 4 lagi. Berapa apel Ali sekarang?",
      visual: "10 + 4 = ?",
      options: ["12", "14", "13", "15"],
      correctIndex: 1, // 14
      hint: "10 apel ditambah 4 apel!",
    ),
    MathQuestion(
      questionText: "Dina punya 18 permen, dimakan 6. Berapa sisa permen Dina?",
      visual: "18 − 6 = …",
      options: ["10", "11", "12", "13"],
      correctIndex: 2, // 12
      hint: "18 permen dikurangi 6 permen!",
    ),
    MathQuestion(
      questionText: "Ada 7 burung, datang 8 burung lagi. Berapa jumlah burung sekarang?",
      visual: "7 + 8 = ?",
      options: ["14", "16", "15", "13"],
      correctIndex: 2, // 15
      hint: "7 burung ditambah 8 burung!",
    ),
    MathQuestion(
      questionText: "Budi punya 15 kelereng, kehilangan 5. Berapa sisanya?",
      visual: "15 − 5 = …",
      options: ["8", "9", "10", "11"],
      correctIndex: 2, // 10
      hint: "15 kelereng dikurangi 5 kelereng!",
    ),
    MathQuestion(
      questionText: "Ibu membeli 12 roti, dimakan 3. Berapa sisa roti?",
      visual: "12 - 3 = ?",
      options: ["8", "10", "7", "9"],
      correctIndex: 3, // 9
      hint: "12 roti dikurangi 3 roti!",
    ),
  ],

  // Step 5 - Perkalian dan Pembagian Dasar
  [
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "4 + (2 × 2) = ?",
      options: ["6", "7", "8", "9"],
      correctIndex: 2, // 8
      hint: "Hitung perkalian dulu: 2 × 2 = 4, lalu tambah 4!",
    ),
    MathQuestion(
      questionText: "Berapa hasil perkalian berikut?",
      visual: "5 × 2 = ?",
      options: ["8", "10", "12", "15"],
      correctIndex: 1, // 10
      hint: "5 dikali 2 sama dengan?",
    ),
    MathQuestion(
      questionText: "Berapa hasil pembagian berikut?",
      visual: "6 ÷ 3 = ?",
      options: ["1", "2", "3", "4"],
      correctIndex: 1, // 2
      hint: "6 dibagi 3 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "(2 + 2) + 2 = ?",
      options: ["3", "4", "5", "6"],
      correctIndex: 3, // 6
      hint: "Hitung dalam kurung dulu: 2 + 2 = 4, lalu tambah 2!",
    ),
    MathQuestion(
      questionText: "Berapa hasil perkalian berikut?",
      visual: "3 × 3 = ?",
      options: ["6", "7", "8", "9"],
      correctIndex: 3, // 9
      hint: "3 dikali 3 sama dengan?",
    ),
  ],
];

/// ========================================
/// SOAL BERHITUNG MODE SULIT (5 step, masing-masing 5 soal)
/// ========================================

const List<List<MathQuestion>> hardMathSteps = [
  // Step 1 - Operasi dengan Angka Besar
  [
    MathQuestion(
      questionText: "Hitung hasil pengurangan berikut!",
      visual: "100 − 47 = ?",
      options: ["63", "57", "53", "47"],
      correctIndex: 2, // 53
      hint: "100 dikurangi 47 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung hasil perkalian berikut!",
      visual: "8 × 4 = ?",
      options: ["24", "28", "32", "36"],
      correctIndex: 2, // 32
      hint: "8 dikali 4 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung hasil pembagian berikut!",
      visual: "72 ÷ 8 = ?",
      options: ["7", "8", "9", "10"],
      correctIndex: 2, // 9
      hint: "72 dibagi 8 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung hasil penjumlahan berikut!",
      visual: "45 + 25 = ?",
      options: ["60", "65", "70", "75"],
      correctIndex: 2, // 70
      hint: "45 ditambah 25 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung hasil pengurangan berikut!",
      visual: "90 − 35 = ?",
      options: ["55", "65", "45", "60"],
      correctIndex: 0, // 55
      hint: "90 dikurangi 35 sama dengan?",
    ),
  ],

  // Step 2 - Operasi Campuran dan Soal Cerita
  [
    MathQuestion(
      questionText: "Hitung hasil pengurangan berikut!",
      visual: "135 − 53 = ?",
      options: ["78", "82", "69", "66"],
      correctIndex: 1, // 82
      hint: "135 dikurangi 53 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung hasil penjumlahan berikut!",
      visual: "120 + 48 = ?",
      options: ["156", "170", "168", "172"],
      correctIndex: 2, // 168
      hint: "120 ditambah 48 sama dengan?",
    ),
    MathQuestion(
      questionText: "Siti membaca 4 halaman selama 5 hari. Berapa total halaman?",
      visual: "4 × 5 = ?",
      options: ["15", "20", "25", "30"],
      correctIndex: 1, // 20
      hint: "4 halaman dikali 5 hari!",
    ),
    MathQuestion(
      questionText: "25 jeruk dibagi 5 anak. Berapa jeruk untuk setiap anak?",
      visual: "25 ÷ 5 = ?",
      options: ["10", "8", "6", "5"],
      correctIndex: 3, // 5
      hint: "25 dibagi 5 sama dengan?",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "15 + 8 − 6 = ?",
      options: ["17", "18", "19", "16"],
      correctIndex: 0, // 17
      hint: "Hitung dari kiri: 15 + 8 = 23, lalu 23 - 6!",
    ),
  ],

  // Step 3 - Urutan Operasi (BODMAS)
  [
    MathQuestion(
      questionText: "Hitung soal berikut! (Kerjakan perkalian dulu)",
      visual: "5 + 3 × 2 = ?",
      options: ["16", "11", "10", "13"],
      correctIndex: 1, // 11
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut! (Kerjakan dalam kurung dulu)",
      visual: "(10 − 4) × 2 = ?",
      options: ["8", "12", "10", "14"],
      correctIndex: 1, // 12
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut! (Kerjakan pembagian dulu)",
      visual: "20 ÷ 5 + 6 = ?",
      options: ["8", "9", "10", "11"],
      correctIndex: 2, // 10
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut! (Kerjakan perkalian dulu)",
      visual: "8 × 3 − 4 = ?",
      options: ["18", "20", "22", "24"],
      correctIndex: 1, // 20
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut! (Kerjakan pembagian dulu)",
      visual: "30 − 6 ÷ 2 = ?",
      options: ["12", "24", "27", "15"],
      correctIndex: 2, // 27
      hint: "",
    ),
  ],

  // Step 4 - Soal Cerita Perkalian dan Pembagian
  [
    MathQuestion(
      questionText: "Andi punya 4 kantong, tiap kantong berisi 6 kelereng. Berapa total kelereng Andi?",
      visual: "4 × 6 = ?",
      options: ["20", "22", "24", "26"],
      correctIndex: 2, // 24
      hint: "",
    ),
    MathQuestion(
      questionText: "Ibu membeli 24 jeruk, dibagi rata ke 6 anak. Tiap anak dapat berapa?",
      visual: "24 ÷ 6 = ?",
      options: ["3", "4", "5", "6"],
      correctIndex: 1, // 4
      hint: "",
    ),
    MathQuestion(
      questionText: "Sebuah buku harganya 5 ribu. Jika beli 7 buku, berapa total harga?",
      visual: "5 × 7 = ?",
      options: ["30", "32", "35", "40"],
      correctIndex: 2, // 35
      hint: "",
    ),
    MathQuestion(
      questionText: "Ada 36 kue dibagi ke 9 piring sama banyak. Berapa kue tiap piring?",
      visual: "36 ÷ 9 = ?",
      options: ["3", "4", "5", "6"],
      correctIndex: 1, // 4
      hint: "",
    ),
    MathQuestion(
      questionText: "Budi punya 50 permen, diberikan ke 5 teman sama banyak. Berapa permen tiap teman?",
      visual: "50 ÷ 5 = ?",
      options: ["8", "10", "12", "15"],
      correctIndex: 1, // 10
      hint: "",
    ),
  ],

  // Step 5 - Urutan Operasi Lanjutan
  [
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "(8 + 4) × 3 = ?",
      options: ["32", "36", "40", "24"],
      correctIndex: 1, // 36
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "40 ÷ (5 + 5) = ?",
      options: ["2", "4", "8", "10"],
      correctIndex: 1, // 4
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "6 × 7 − 10 = ?",
      options: ["30", "32", "34", "38"],
      correctIndex: 1, // 32
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "100 − (8 × 5) = ?",
      options: ["50", "60", "70", "80"],
      correctIndex: 1, // 60
      hint: "",
    ),
    MathQuestion(
      questionText: "Hitung soal berikut!",
      visual: "(60 ÷ 6) + 15 = ?",
      options: ["20", "25", "30", "35"],
      correctIndex: 1, // 25
      hint: "",
    ),
  ],
];
