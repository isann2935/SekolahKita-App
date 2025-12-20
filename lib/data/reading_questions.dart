class ReadingQuestion {
  /// Teks bacaan + pertanyaan dalam satu string.
  final String text;

  /// Pilihan jawaban [A, B, C, D].
  final List<String> options;

  /// Index jawaban benar: 0 = A, 1 = B, 2 = C, 3 = D.
  final int correctIndex;

  const ReadingQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// 25 soal level mudah (mode hijau) dibagi menjadi 5 step, masing-masing 5 soal.
const List<List<ReadingQuestion>> easyReadingSteps = [
  // STEP 1 – Soal 1–5 (Berdasarkan gambar: Alfabet dan Menulis Kata)
  [
    ReadingQuestion(
      text:
          '1. BA – NYAK U – ANG\n\n'
          'Jika dirangkai, suku kata di atas menjadi kata ...',
      options: ['BANYAK UANG', 'UANG BANYAK', 'NYAK BA U ANG', 'BA NYAK U ANG'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          '2. ME- JA BE-LA - JAR\n\n'
          'Jika dirangkai, suku kata di atas menjadi kata ...',
      options: ['MEJA BELAJAR', 'BELAJAR MEJA', 'JAR BELA ME', 'ME BELA JAR'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          '3. MA-KA-N MA-LA-M\n\n'
          'Jika dirangkai, suku kata di atas menjadi kata ...',
      options: ['MAKAN MALAM', 'MALAM MAKAN', 'KAN MA MA LAM', 'MA KAN MA LAM'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          '4. DA-NA BA-NY-AK\n\n'
          'Jika dirangkai, suku kata di atas menjadi kata ...',
      options: ['DANA BANYAK', 'BANYAK DANA', 'NA DA BA NYAK', 'DA NA BA NYAK'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          '5. MA - IN BO – LA\n\n'
          'Jika dirangkai, suku kata di atas menjadi kata ...',
      options: ['MAIN BOLA', 'BOLA MAIN', 'IN MA BO LA', 'MA IN BO LA'],
      correctIndex: 0,
    ),
  ],

  // STEP 2 – Soal 6–10 (dipindah dari STEP 3)
  [
    ReadingQuestion(
      text: 'Suku kata dari kata "buku" adalah …',
      options: ['bu-ku', 'buk-u', 'b-u-k-u', 'buu-ku'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text: 'Kata yang memiliki dua suku kata adalah …',
      options: ['Mata', 'Sekolah', 'Keluarga', 'Perpustakaan'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text: 'Huruf pertama dari kata "rumah" adalah …',
      options: ['u', 'r', 'm', 'h'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text: 'Kalimat yang benar adalah …',
      options: [
        'pergi sekolah saya',
        'saya pergi sekolah',
        'sekolah pergi saya',
        'pergi saya sekolah',
      ],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text: 'Kalimat yang menggunakan huruf kapital dengan benar adalah …',
      options: [
        'saya tinggal di semarang',
        'Saya tinggal di semarang',
        'saya tinggal di Semarang',
        'Saya tinggal di Semarang',
      ],
      correctIndex: 3,
    ),
  ],

  // STEP 3 – Soal 11–15 (dipindah dari STEP 2)
  [
    ReadingQuestion(
      text:
          'Saat hujan turun, Doni membawa payung agar tidak basah.\n'
          'Mengapa Doni membawa payung?',
      options: [
        'agar tidak panas',
        'agar tidak basah',
        'agar terlihat rapi',
        'agar cepat sampai',
      ],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Siti membeli 3 roti dan 2 susu di toko.\n'
          'Apa yang dibeli Siti di toko?',
      options: [
        'roti dan air',
        'susu dan kue',
        'roti dan susu',
        'kue dan susu',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Setelah pulang sekolah, Andi mengerjakan pekerjaan rumah.\n'
          'Apa yang dilakukan Andi setelah pulang sekolah?',
      options: ['tidur', 'bermain', 'makan', 'mengerjakan PR'],
      correctIndex: 3,
    ),
    ReadingQuestion(
      text:
          'Burung terbang tinggi di langit biru.\n'
          'Di mana burung terbang?',
      options: ['di pohon', 'di tanah', 'di langit', 'di rumah'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Pada malam hari, Rani belajar agar besok bisa mengerjakan ulangan dengan baik.\n'
          'Mengapa Rani belajar malam hari?',
      options: [
        'agar cepat tidur',
        'agar bisa bermain',
        'agar tidak dimarahi',
        'agar bisa mengerjakan ulangan dengan baik',
      ],
      correctIndex: 3,
    ),
  ],

  // STEP 4 – Soal 16–20
  [
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Setiap pagi, Dika bangun pukul enam. Setelah mandi, ia sarapan lalu berangkat ke sekolah.\n\n'
          'Apa yang dilakukan Dika setelah mandi?',
      options: ['tidur', 'bermain', 'sarapan', 'belajar'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Rina suka membaca buku cerita. Ia sering membaca di perpustakaan sekolah.\n\n'
          'Di mana Rina sering membaca?',
      options: ['rumah', 'kelas', 'taman', 'perpustakaan'],
      correctIndex: 3,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Setiap hari Minggu, keluarga Beni membersihkan rumah bersama-sama.\n\n'
          'Kapan keluarga Beni membersihkan rumah?',
      options: ['Sabtu', 'Minggu', 'Senin', 'Jumat'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Ayah pergi ke kantor menggunakan sepeda motor setiap pagi.\n\n'
          'Kendaraan apa yang digunakan ayah?',
      options: ['mobil', 'bus', 'sepeda motor', 'sepeda'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Di kebun, Ani menanam bunga mawar dan melati.\n\n'
          'Bunga apa yang ditanam Ani?',
      options: [
        'mawar dan anggrek',
        'melati dan anggrek',
        'mawar dan melati',
        'melati dan tulip',
      ],
      correctIndex: 2,
    ),
  ],

  // STEP 3 – Soal 11–15 (dipindah dari STEP 2)
  [
    ReadingQuestion(
      text: 'Suku kata dari kata “buku” adalah …',
      options: ['bu-ku', 'buk-u', 'b-u-k-u', 'buu-ku'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text: 'Kata yang memiliki dua suku kata adalah …',
      options: ['Mata', 'Sekolah', 'Keluarga', 'Perpustakaan'],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text: 'Huruf pertama dari kata “rumah” adalah …',
      options: ['u', 'r', 'm', 'h'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text: 'Kalimat yang benar adalah …',
      options: [
        'pergi sekolah saya',
        'saya pergi sekolah',
        'sekolah pergi saya',
        'pergi saya sekolah',
      ],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Pada malam hari, Rani belajar agar besok bisa mengerjakan ulangan dengan baik.\n'
          'Mengapa Rani belajar malam hari?',
      options: [
        'agar cepat tidur',
        'agar bisa bermain',
        'agar tidak dimarahi',
        'agar bisa mengerjakan ulangan dengan baik',
      ],
      correctIndex: 3,
    ),
  ],

  // STEP 4 – Soal 16–20
  [
    ReadingQuestion(
      text: 'Ide pokok adalah …',
      options: [
        'kalimat penutup',
        'kalimat tambahan',
        'inti pembahasan',
        'contoh pendukung',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text: 'Tujuan membaca adalah …',
      options: [
        'menghafal huruf',
        'memahami isi bacaan',
        'menulis ulang',
        'menghitung kata',
      ],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text: 'Kalimat tanya diakhiri dengan tanda …',
      options: ['titik', 'koma', 'seru', 'tanya'],
      correctIndex: 3,
    ),
    ReadingQuestion(
      text: 'Latar tempat menunjukkan …',
      options: [
        'siapa pelakunya',
        'kapan kejadian',
        'di mana kejadian',
        'bagaimana kejadian',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text: 'Pesan moral dalam cerita disebut …',
      options: ['tema', 'amanat', 'tokoh', 'alur'],
      correctIndex: 1,
    ),
  ],

  // STEP 5 – Soal 21–25
  [
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Andi rajin belajar setiap hari. Karena itu, ia sering mendapat nilai yang baik di sekolah.\n\n'
          'Apa hubungan belajar rajin dengan nilai Andi?',
      options: [
        'Tidak ada hubungan',
        'Belajar rajin membuat nilai buruk',
        'Belajar rajin membuat nilai baik',
        'Nilai tidak dipengaruhi belajar',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Di kebun, terdapat pohon mangga, jambu, dan pisang. Buah mangga sudah matang dan siap dipetik.\n\n'
          'Buah apa yang sudah siap dipetik?',
      options: ['pisang', 'jambu', 'mangga', 'semua buah'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Sebelum tidur, Rani menyiapkan buku pelajaran untuk keesokan hari.\n\n'
          'Mengapa Rani menyiapkan buku sebelum tidur?',
      options: [
        'Agar tidak lupa',
        'Agar cepat tidur',
        'Agar buku rapi',
        'Agar terlihat rajin',
      ],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Pada hari Sabtu, sekolah mengadakan kerja bakti. Semua siswa diminta membawa alat kebersihan.\n\n'
          'Apa yang harus dibawa siswa saat kerja bakti?',
      options: ['buku pelajaran', 'alat tulis', 'alat kebersihan', 'makanan'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Setiap sore, Seno membantu ibu menyiram tanaman. Jika hujan turun, Seno tidak perlu menyiram tanaman.\n\n'
          'Kapan Seno tidak menyiram tanaman?',
      options: [
        'saat pagi hari',
        'saat sore hari',
        'saat hujan turun',
        'saat malam hari',
      ],
      correctIndex: 2,
    ),
  ],
];

/// 25 soal level susah (mode oranye) dibagi menjadi 5 step, masing-masing 5 soal.
const List<List<ReadingQuestion>> hardReadingSteps = [
  // STEP 1 – Soal 26–30
  [
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Setiap pagi, Lala membantu ibu menimba air dari sumur sebelum berangkat ke sekolah. Setelah itu, ia menyiapkan buku pelajaran agar tidak terlambat.\n\n'
          'Mengapa Lala menyiapkan buku pelajaran?',
      options: [
        'Agar bisa bermain',
        'Agar tidak terlambat',
        'Agar membantu ibu',
        'Agar cepat pulang',
      ],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Karena hujan deras semalaman, jalan menuju sekolah menjadi becek dan licin. Akibatnya, Dani berangkat lebih awal agar tidak terlambat.\n\n'
          'Mengapa Dani berangkat lebih awal?',
      options: ['Jalan jauh', 'Hujan berhenti', 'Jalan licin', 'Ingin bermain'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Di desa, listrik sering padam pada malam hari. Oleh karena itu, Riko belajar pada sore hari sebelum hari menjadi gelap.\n\n'
          'Kapan Riko belajar?',
      options: ['pagi hari', 'siang hari', 'sore hari', 'malam hari'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Sinta tetap berangkat sekolah meskipun harus berjalan kaki jauh. Ia tidak ingin ketinggalan pelajaran.\n\n'
          'Sifat Sinta yang terlihat pada cerita adalah …',
      options: ['pemalas', 'rajin', 'penakut', 'pemarah'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text: 'Kata yang memiliki bunyi akhir “-ng” adalah …',
      options: [
        'Guru marah',
        'Agar tidak mengantuk',
        'Agar bisa memahami pelajaran',
        'Agar cepat pulang',
      ],
      correctIndex: 3,
    ),
  ],

  // STEP 2 – Soal 31–35
  [
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Setelah panen jagung, ayah menjual sebagian hasil panen ke pasar. Uangnya digunakan untuk membeli perlengkapan sekolah.\n\n'
          'Untuk apa uang hasil panen digunakan?',
      options: [
        'Membeli makanan',
        'Membeli mainan',
        'Membeli perlengkapan sekolah',
        'Menyimpan jagung',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Bacalah teks berikut!\n'
          'Nina membawa bekal dari rumah karena kantin sekolah jarang buka.\n\n'
          'Simpulan yang tepat dari teks tersebut adalah …',
      options: [
        'Nina tidak suka jajan',
        'Kantin selalu tutup',
        'Nina menabung uang',
        'Nina membawa bekal karena kantin jarang buka',
      ],
      correctIndex: 3,
    ),
    ReadingQuestion(
      text: 'Kalimat “Ani menulis surat.” termasuk kalimat …',
      options: ['tanya', 'perintah', 'berita', 'seru'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text: 'Kalimat ajakan biasanya menggunakan kata …',
      options: ['jangan', 'ayo', 'tidak', 'sudah'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Kata yang tepat untuk melengkapi kalimat:\n'
          '“Ibu ___ di dapur.”',
      options: ['meja', 'masak', 'buku', 'kursi'],
      correctIndex: 1,
    ),
  ],

  // STEP 3 – Soal 36–40
  [
    ReadingQuestion(
      text:
          'Setiap pagi, Raka berangkat ke sekolah dengan berjalan kaki. Jika hujan turun, '
          'Raka membawa payung agar tidak basah.\n'
          'Mengapa Raka membawa payung?',
      options: [
        'Agar cepat sampai sekolah',
        'Agar tidak kepanasan',
        'Agar tidak basah',
        'Agar terlihat rapi',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Dina suka membaca buku cerita. Saat waktu luang, ia lebih memilih membaca daripada '
          'menonton televisi.\n'
          'Apa yang lebih disukai Dina saat waktu luang?',
      options: ['menonton televisi', 'bermain game', 'membaca buku', 'tidur'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Setiap hari Minggu, keluarga Andi membersihkan rumah bersama-sama. Ayah menyapu, '
          'ibu mengepel, dan Andi merapikan mainan.\n'
          'Siapa yang mengepel lantai?',
      options: ['Ayah', 'Ibu', 'Andi', 'Kakak'],
      correctIndex: 1,
    ),
    ReadingQuestion(
      text:
          'Lina membawa bekal ke sekolah karena tidak sempat membeli makanan di kantin.\n'
          'Mengapa Lina membawa bekal?',
      options: [
        'Tidak suka makanan kantin',
        'Ingin berbagi dengan teman',
        'Tidak sempat membeli di kantin',
        'Kantin tutup',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Pada sore hari, Beni bermain sepeda di halaman. Setelah magrib, ia segera '
          'masuk rumah untuk belajar.\n'
          'Apa yang dilakukan Beni setelah magrib?',
      options: ['bermain sepeda', 'makan malam', 'belajar', 'tidur'],
      correctIndex: 2,
    ),
  ],

  // STEP 4 – Soal 41–45
  [
    ReadingQuestion(
      text:
          'Hujan turun sangat deras. Jalan menjadi licin sehingga Santi berjalan lebih pelan.\n'
          'Mengapa Santi berjalan lebih pelan?',
      options: [
        'karena lelah',
        'karena hujan berhenti',
        'karena jalan licin',
        'karena ingin bermain',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Andi rajin belajar setiap hari. Karena itu, ia sering mendapat nilai yang baik di sekolah.\n'
          'Apa hubungan belajar rajin dengan nilai Andi?',
      options: [
        'Tidak ada hubungan',
        'Belajar rajin membuat nilai buruk',
        'Belajar rajin membuat nilai baik',
        'Nilai tidak dipengaruhi belajar',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Di kebun, terdapat pohon mangga, jambu, dan pisang. Buah mangga sudah matang dan siap dipetik.\n'
          'Buah apa yang sudah siap dipetik?',
      options: ['pisang', 'jambu', 'mangga', 'semua buah'],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Sebelum tidur, Rani menyiapkan buku pelajaran untuk keesokan hari.\n'
          'Mengapa Rani menyiapkan buku sebelum tidur?',
      options: [
        'Agar tidak lupa',
        'Agar cepat tidur',
        'Agar buku rapi',
        'Agar terlihat rajin',
      ],
      correctIndex: 0,
    ),
    ReadingQuestion(
      text:
          'Pada hari Sabtu, sekolah mengadakan kerja bakti. Semua siswa diminta membawa alat kebersihan.\n'
          'Apa yang harus dibawa siswa saat kerja bakti?',
      options: ['buku pelajaran', 'alat tulis', 'alat kebersihan', 'makanan'],
      correctIndex: 2,
    ),
  ],

  // STEP 5 – Soal 46–50
  [
    ReadingQuestion(
      text:
          'Setiap sore, Seno membantu ibu menyiram tanaman. Jika hujan turun, Seno tidak perlu menyiram tanaman.\n'
          'Kapan Seno tidak menyiram tanaman?',
      options: [
        'saat pagi hari',
        'saat sore hari',
        'saat hujan turun',
        'saat malam hari',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Tina belajar dengan sungguh-sungguh karena besok akan ada ulangan matematika.\n'
          'Mengapa Tina belajar sungguh-sungguh?',
      options: [
        'karena disuruh ibu',
        'karena ingin bermain',
        'karena ada ulangan matematika',
        'karena ingin tidur',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Di perpustakaan, Rudi membaca buku dengan tenang agar tidak mengganggu pengunjung lain.\n'
          'Mengapa Rudi membaca dengan tenang?',
      options: [
        'karena buku sulit',
        'karena lelah',
        'agar tidak mengganggu orang lain',
        'agar cepat selesai',
      ],
      correctIndex: 2,
    ),
    ReadingQuestion(
      text:
          'Setelah makan siang, Sari mencuci piring lalu beristirahat sebentar.\n'
          'Apa yang dilakukan Sari setelah mencuci piring?',
      options: ['belajar', 'tidur', 'bermain', 'beristirahat'],
      correctIndex: 3,
    ),
    // Slot terakhir bisa diisi soal tambahan jika diperlukan.
  ],
];
