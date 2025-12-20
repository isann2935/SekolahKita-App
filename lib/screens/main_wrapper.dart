import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/difficulty_modal.dart';
import '../widgets/feedback_popup.dart';
import 'home/home_screen.dart';
import 'practice/practice_screen.dart';
import 'achievements/achievements_screen.dart';
import 'map/adventure_map_screen.dart';
import 'question/question_screen.dart';
import 'writing/writing_screen.dart';
import 'onboarding_screen.dart';
import 'profile/profile_screen.dart'; // Pastikan import ini ada

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // --- STATE DATA ---
  String userName = "Budi";
  int stars = 0;
  bool hasOnboarded = false;
  bool isLoading = true;

  // State Navigasi
  int _bottomNavIndex = 0;
  String _currentFlow = 'root';
  String? selectedSubject;
  String? selectedDifficulty;
  int currentLevel = 1;

  // Data Game
  List<String> earnedBadges = ['beginner'];
  List<String> ownedAvatars = [];

  // State Kustomisasi Avatar
  String currentFace = '😊';
  String? equippedHat;
  String? equippedGlasses;

  // Progress tracking: Map<"subject_difficulty", highestCompletedLevel>
  Map<String, int> progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOGIC PENYIMPANAN DATA (OFFLINE) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load progress untuk semua kombinasi subject dan difficulty
    final subjects = ["Membaca", "Menulis", "Berhitung"];
    final difficulties = ["mudah", "sulit"];
    final Map<String, int> loadedProgress = {};

    for (var subject in subjects) {
      for (var difficulty in difficulties) {
        final key = "${subject}_$difficulty";
        loadedProgress[key] = prefs.getInt(key) ?? 0;
      }
    }

    setState(() {
      hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      userName = prefs.getString('userName') ?? "Budi";
      stars = prefs.getInt('stars') ?? 200;

      ownedAvatars = prefs.getStringList('ownedAvatars') ?? [];
      earnedBadges = prefs.getStringList('earnedBadges') ?? ['beginner'];

      currentFace = prefs.getString('currentFace') ?? '😊';
      equippedHat = prefs.getString('equippedHat');
      equippedGlasses = prefs.getString('equippedGlasses');

      progressMap = loadedProgress;

      isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', hasOnboarded);
    await prefs.setString('userName', userName);
    await prefs.setInt('stars', stars);
    await prefs.setStringList('ownedAvatars', ownedAvatars);
    await prefs.setStringList('earnedBadges', earnedBadges);
    await prefs.setString('currentFace', currentFace);

    if (equippedHat != null) {
      await prefs.setString('equippedHat', equippedHat!);
    } else {
      await prefs.remove('equippedHat');
    }

    if (equippedGlasses != null) {
      await prefs.setString('equippedGlasses', equippedGlasses!);
    } else {
      await prefs.remove('equippedGlasses');
    }

    // Save progress
    progressMap.forEach((key, value) {
      prefs.setInt(key, value);
    });
  }

  // Get progress untuk subject dan difficulty tertentu
  int _getProgress(String subject, String difficulty) {
    final key = "${subject}_$difficulty";
    return progressMap[key] ?? 0;
  }

  // Update progress setelah menyelesaikan level
  Future<void> _updateProgress(
    String subject,
    String difficulty,
    int completedLevel,
  ) async {
    final key = "${subject}_$difficulty";
    final currentProgress = progressMap[key] ?? 0;

    // Update hanya jika level yang diselesaikan lebih tinggi dari progress saat ini
    if (completedLevel > currentProgress) {
      setState(() {
        progressMap[key] = completedLevel;
      });
      await _saveData();
    }
  }

  // --- LOGIC GAME ---

  void _onBottomNavTap(int index) {
    setState(() {
      _bottomNavIndex = index;
      _currentFlow = 'root';
    });
  }

  void _goToMap(String subject, String difficulty) {
    setState(() {
      selectedSubject = subject;
      selectedDifficulty = difficulty;
      currentLevel = 1;
      _currentFlow = 'map';
    });
  }

  void _changeFace(String newFace) {
    setState(() {
      currentFace = newFace;
    });
    _saveData();
  }

  // LOGIC GANTI NAMA
  void _changeName(String newName) {
    setState(() {
      userName = newName;
    });
    _saveData();
    _showSnack("Nama berhasil diubah! ✨", AppColors.green);
  }

  void _buyAvatar(String id, int cost) {
    if (stars >= cost) {
      setState(() {
        stars -= cost;
        ownedAvatars.add(id);
      });
      _saveData();
      _showSnack("Berhasil membeli item! 🎉", AppColors.green);
    } else {
      _showSnack("Bintang tidak cukup! ⭐", AppColors.red);
    }
  }

  void _equipAvatar(String id, String type) {
    setState(() {
      if (type == 'hat') {
        equippedHat = (equippedHat == id) ? null : id;
      } else if (type == 'glasses') {
        equippedGlasses = (equippedGlasses == id) ? null : id;
      }
    });
    _saveData();
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- LOGIC UNLOCK BADGES ---
  void _checkAndUnlockBadges() {
    final newBadges = <String>[];

    // Badge 1: first_score - Dapatkan 10 bintang
    if (stars >= 10 && !earnedBadges.contains('first_score')) {
      newBadges.add('first_score');
      _showSnack("🎖️ Badge 'Bintang Pertama' terbuka!", AppColors.green);
    }

    // Badge 2: reader - Selesaikan level Membaca
    if (_getProgress("Membaca", "mudah") >= 1 &&
        !earnedBadges.contains('reader')) {
      newBadges.add('reader');
      _showSnack("📚 Badge 'Pembaca' terbuka!", AppColors.green);
    }

    // Badge 3: writer - Selesaikan level Menulis
    if (_getProgress("Menulis", "mudah") >= 1 &&
        !earnedBadges.contains('writer')) {
      newBadges.add('writer');
      _showSnack("✏️ Badge 'Penulis' terbuka!", AppColors.green);
    }

    // Badge 4: mathematician - Selesaikan level Berhitung
    if (_getProgress("Berhitung", "mudah") >= 1 &&
        !earnedBadges.contains('mathematician')) {
      newBadges.add('mathematician');
      _showSnack("🔢 Badge 'Matematikawan' terbuka!", AppColors.green);
    }

    // Badge 5: speedster - Dapatkan 50 bintang (cepat berkembang)
    if (stars >= 50 && !earnedBadges.contains('speedster')) {
      newBadges.add('speedster');
      _showSnack("⚡ Badge 'Cepat' terbuka!", AppColors.green);
    }

    // Badge 6: perfectionist - Selesaikan 5 level
    final totalLevels = (progressMap.values.fold(0, (sum, val) => sum + val));
    if (totalLevels >= 5 && !earnedBadges.contains('perfectionist')) {
      newBadges.add('perfectionist');
      _showSnack("💯 Badge 'Sempurna' terbuka!", AppColors.green);
    }

    // Badge 7: master - Selesaikan 10 level
    if (totalLevels >= 10 && !earnedBadges.contains('master')) {
      newBadges.add('master');
      _showSnack("👑 Badge 'Master' terbuka!", AppColors.green);
    }

    // Badge 8: genius - Dapatkan 200 bintang (ultimate reward)
    if (stars >= 200 && !earnedBadges.contains('genius')) {
      newBadges.add('genius');
      _showSnack("🧠 Badge 'Jenius' terbuka!", AppColors.green);
    }

    // Update state jika ada badge baru
    if (newBadges.isNotEmpty) {
      setState(() {
        earnedBadges.addAll(newBadges);
      });
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: AppColors.softTeal);
    }

    if (!hasOnboarded) {
      return OnboardingScreen(
        onStart: (name) {
          setState(() {
            userName = name;
            hasOnboarded = true;
          });
          _saveData();
        },
      );
    }

    if (_currentFlow == 'map') {
      return AdventureMapScreen(
        subject: selectedSubject!,
        difficulty: selectedDifficulty!,
        highestCompletedLevel: _getProgress(
          selectedSubject!,
          selectedDifficulty!,
        ),
        onBack: () => setState(() => _currentFlow = 'root'),
        onLevelClick: (level) => setState(() {
          currentLevel = level;
          if (selectedSubject == "Menulis") {
            _currentFlow = 'writing';
          } else {
            _currentFlow = 'question';
          }
        }),
      );
    } else if (_currentFlow == 'writing') {
      return WritingScreen(
        step: currentLevel,
        onBack: () => setState(() => _currentFlow = 'map'),
        onComplete: (canProceed) async {
          if (canProceed) {
            await _updateProgress("Menulis", "mudah", currentLevel);
            setState(() {
              stars += 10;
            });
            await _saveData();
            _checkAndUnlockBadges(); // ✅ CHECK BADGES

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => FeedbackPopup(
                onClose: () {
                  Navigator.pop(ctx);
                  setState(() => _currentFlow = 'map');
                },
              ),
            );
          } else {
            setState(() => _currentFlow = 'map');
          }
        },
      );
    } else if (_currentFlow == 'question') {
      return QuestionScreen(
        subject: selectedSubject ?? "Berhitung",
        level: currentLevel,
        mode: selectedDifficulty ?? "mudah",
        onBack: () => setState(() => _currentFlow = 'map'),
        onComplete: (canProceed) async {
          if (canProceed) {
            // Update progress dan stars hanya jika step selesai dengan benar
            await _updateProgress(
              selectedSubject ?? "Berhitung",
              selectedDifficulty ?? "mudah",
              currentLevel,
            );
            setState(() {
              stars += 10;
            });
            await _saveData();
            _checkAndUnlockBadges(); // ✅ CHECK BADGES

            // Tampilkan feedback popup hanya jika berhasil
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => FeedbackPopup(
                onClose: () {
                  Navigator.pop(ctx);
                  setState(() => _currentFlow = 'map');
                },
              ),
            );
          } else {
            // Jika perlu retry, langsung kembali ke map tanpa update progress
            setState(() => _currentFlow = 'map');
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Tab 0: Beranda
          HomeScreen(
            userName: userName,
            stars: stars,
            currentFace: currentFace,
            equippedHat: equippedHat,
            equippedGlasses: equippedGlasses,
            onSubjectSelect: (subject) {
              if (subject == "Menulis") {
                // Untuk Menulis, langsung ke map tanpa modal difficulty
                setState(() {
                  selectedSubject = "Menulis";
                  selectedDifficulty = "mudah"; // Default untuk menulis
                  currentLevel = 1;
                  _currentFlow = 'map';
                });
              } else {
                // Untuk Membaca dan Berhitung, tampilkan modal difficulty
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => DifficultyModal(
                    onSelect: (difficulty) {
                      Navigator.pop(ctx);
                      _goToMap(subject, difficulty);
                    },
                  ),
                );
              }
            },
          ),

          // Tab 1: Latihan
          const PracticeScreen(),

          // Tab 2: Prestasi
          AchievementsScreen(
            badges: earnedBadges,
            stars: stars,
            userName: userName,
            ownedAvatars: ownedAvatars,
            currentFace: currentFace,
            equippedHat: equippedHat,
            equippedGlasses: equippedGlasses,
            onBuyItem: _buyAvatar,
            onEquipItem: _equipAvatar,
            onChangeFace: _changeFace,
            onChangeName: _changeName,
          ),

          // Tab 3: Profil (INI YANG KITA TAMBAHKAN)
          ProfileScreen(
            userName: userName,
            stars: stars,
            daysLearned: 1,
            completedLevels: 0,
            onEditName: _changeName,

            // --- DATA BARU DIKIRIM KE SINI ---
            currentFace: currentFace,
            equippedHat: equippedHat,
            equippedGlasses: equippedGlasses,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}