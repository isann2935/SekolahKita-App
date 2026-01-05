import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/custom_question_service.dart';

class MyQuestionsScreen extends StatefulWidget {
  const MyQuestionsScreen({super.key});

  @override
  State<MyQuestionsScreen> createState() => _MyQuestionsScreenState();
}

class _MyQuestionsScreenState extends State<MyQuestionsScreen> {
  List<CustomQuestionModel> myQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await CustomQuestionService.getQuestions();
    setState(() {
      myQuestions = data;
      isLoading = false;
    });
  }

  void _deleteItem(int index) async {
    await CustomQuestionService.deleteQuestion(index);
    _loadData(); // Refresh list setelah hapus
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Soal dihapus 👋"), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text("Bank Soal Saya 📂"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("Belum ada soal buatanmu.", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myQuestions.length,
                  itemBuilder: (context, index) {
                    final q = myQuestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: q.isMath ? AppColors.blue.withOpacity(0.1) : AppColors.green.withOpacity(0.1),
                          child: Text(q.isMath ? "🔢" : "📖"),
                        ),
                        title: Text(
                          q.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("✅ ${q.correctAnswer}", style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                            Text("❌ ${q.wrongAnswers.join(', ')}", style: const TextStyle(color: AppColors.red, fontSize: 12)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _showDeleteConfirm(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteConfirm(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Soal?"),
        content: const Text("Soal ini akan hilang permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteItem(index);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}