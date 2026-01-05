import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/custom_question_service.dart';
import 'my_questions_screen.dart'; // ✅ PENTING: Import halaman Bank Soal

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk mengambil teks inputan
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _correctController = TextEditingController();
  final TextEditingController _wrong1Controller = TextEditingController();
  final TextEditingController _wrong2Controller = TextEditingController();
  final TextEditingController _wrong3Controller = TextEditingController();
  
  bool _isMath = false; // Default soal membaca

  void _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      // Buat object soal
      final newQuestion = CustomQuestionModel(
        text: _questionController.text,
        correctAnswer: _correctController.text,
        wrongAnswers: [
          _wrong1Controller.text,
          _wrong2Controller.text,
          _wrong3Controller.text,
        ],
        isMath: _isMath,
      );

      // Simpan ke SharedPreferences
      await CustomQuestionService.addQuestion(newQuestion);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Soal berhasil disimpan! 🎉"), backgroundColor: AppColors.green),
      );
      
      // Reset form setelah simpan (opsional, biar bisa input lagi)
      _questionController.clear();
      _correctController.clear();
      _wrong1Controller.clear();
      _wrong2Controller.clear();
      _wrong3Controller.clear();
      
      // Atau bisa langsung kembali: Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Soal Sendiri 📝"),
        actions: [
          // 🔥 TOMBOL BARU: Lihat Bank Soal
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: "Lihat Bank Soal",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyQuestionsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Jenis Soal", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Membaca/Teks"),
                    selected: !_isMath,
                    onSelected: (val) => setState(() => _isMath = !val),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("Matematika"),
                    selected: _isMath,
                    onSelected: (val) => setState(() => _isMath = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildTextField("Pertanyaan", _questionController, "Contoh: Apa warna langit?", maxLines: 2),
              _buildTextField("Jawaban BENAR ✅", _correctController, "Contoh: Biru"),
              
              const Divider(height: 40),
              const Text("Pilihan Jawaban SALAH ❌", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red)),
              const SizedBox(height: 8),
              
              _buildTextField("Salah 1", _wrong1Controller, "Contoh: Merah"),
              _buildTextField("Salah 2", _wrong2Controller, "Contoh: Hijau"),
              _buildTextField("Salah 3", _wrong3Controller, "Contoh: Kuning"),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("SIMPAN SOAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }
}