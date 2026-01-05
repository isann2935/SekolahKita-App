import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomQuestionModel {
  final String text;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final bool isMath; 

  CustomQuestionModel({
    required this.text,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.isMath,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'correctAnswer': correctAnswer,
        'wrongAnswers': wrongAnswers,
        'isMath': isMath,
      };

  factory CustomQuestionModel.fromJson(Map<String, dynamic> json) {
    return CustomQuestionModel(
      text: json['text'],
      correctAnswer: json['correctAnswer'],
      wrongAnswers: List<String>.from(json['wrongAnswers']),
      isMath: json['isMath'],
    );
  }
}

class CustomQuestionService {
  static const String _key = 'custom_questions_data';

  // 1. Ambil Semua Soal
  static Future<List<CustomQuestionModel>> getQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];

    List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => CustomQuestionModel.fromJson(e)).toList();
  }

  // 2. Tambah Soal Baru
  static Future<void> addQuestion(CustomQuestionModel question) async {
    final prefs = await SharedPreferences.getInstance();
    List<CustomQuestionModel> currentQuestions = await getQuestions();
    
    currentQuestions.add(question);
    
    String encoded = jsonEncode(currentQuestions.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  // 3. 🔥 BARU: Hapus Soal Berdasarkan Index
  static Future<void> deleteQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<CustomQuestionModel> currentQuestions = await getQuestions();
    
    if (index >= 0 && index < currentQuestions.length) {
      currentQuestions.removeAt(index); // Hapus soal
      
      // Simpan ulang sisanya
      String encoded = jsonEncode(currentQuestions.map((e) => e.toJson()).toList());
      await prefs.setString(_key, encoded);
    }
  }
}