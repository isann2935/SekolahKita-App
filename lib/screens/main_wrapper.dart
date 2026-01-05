import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/difficulty_modal.dart';
import '../widgets/feedback_popup.dart';
import 'home/home_screen.dart';
import 'practice/practice_screen.dart';
import 'achievements/achievements_screen.dart'; 
import 'profile/profile_screen.dart';
import 'map/adventure_map_screen.dart';
import 'question/question_screen.dart';
import 'writing/writing_screen.dart';
import 'onboarding_screen.dart';

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
  
  // Avatar
  String currentFace = '😊';
  String? equippedHat;
  String? equippedGlasses;
  
  // Progress Map
  Map<String, int> progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOGIC PENYIMPANAN DATA (OFFLINE) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
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

    progressMap.forEach((key, value) {
      prefs.setInt(key, value);
    });
  }

  int _getProgress(String subject, String difficulty) {
    final key = "${subject}_$difficulty";
    return progressMap[key] ?? 0;
  }

  Future<void> _updateProgress(String subject, String difficulty, int completedLevel) async {
    final key = "${subject}_$difficulty";
    final currentProgress = progressMap[key] ?? 0;

    if (completedLevel > currentProgress) {
      setState(() {
        final newMap = Map<String, int>.from(progressMap);
        newMap[key] = completedLevel;
        progressMap = newMap;
      });
      await _saveData();
    }
  }

  // --- LOGIC GAME & NAVIGASI ---
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
    setState(() => currentFace = newFace);
    _saveData();
  }

  void _changeName(String newName) {
    setState(() => userName = newName);
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nama berhasil diubah! ✨"), backgroundColor: AppColors.green, duration: Duration(seconds: 1)),
    );
  }

  void _buyAvatar(String id, int cost) {
    if (stars >= cost) {
      setState(() {
        stars -= cost;
        ownedAvatars.add(id);
      });
      _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil membeli item! 🎉"), backgroundColor: AppColors.green, duration: Duration(seconds: 1)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bintang tidak cukup! ⭐"), backgroundColor: AppColors.red, duration: Duration(seconds: 1)),
      );
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

  void _checkAndUnlockBadges() {
    final newBadges = <String>[];
    if (stars >= 10 && !earnedBadges.contains('first_score')) newBadges.add('first_score');
    if (_getProgress("Membaca", "mudah") >= 1 && !earnedBadges.contains('reader')) newBadges.add('reader');
    if (_getProgress("Menulis", "mudah") >= 1 && !earnedBadges.contains('writer')) newBadges.add('writer');
    if (_getProgress("Berhitung", "mudah") >= 1 && !earnedBadges.contains('mathematician')) newBadges.add('mathematician');
    if (stars >= 50 && !earnedBadges.contains('speedster')) newBadges.add('speedster');
    
    final totalLevels = (progressMap.values.fold(0, (sum, val) => sum + val));
    if (totalLevels >= 5 && !earnedBadges.contains('perfectionist')) newBadges.add('perfectionist');
    if (totalLevels >= 10 && !earnedBadges.contains('master')) newBadges.add('master');
    if (stars >= 200 && !earnedBadges.contains('genius')) newBadges.add('genius');

    if (newBadges.isNotEmpty) {
      setState(() { earnedBadges.addAll(newBadges); });
      _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎖️ Badge Baru Terbuka!"), backgroundColor: AppColors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(backgroundColor: AppColors.softTeal);

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

    int totalLevelsDone = progressMap.values.fold(0, (sum, level) => sum + level);

    final List<Widget> pages = [
      // Tab 0: Beranda
      HomeScreen(
        userName: userName,
        stars: stars,
        currentFace: currentFace,
        equippedHat: equippedHat,
        equippedGlasses: equippedGlasses,
        subjectProgress: progressMap, 
        onSubjectSelect: (subject) {
          if (subject == "Menulis") {
            setState(() {
              selectedSubject = "Menulis";
              selectedDifficulty = "mudah";
              currentLevel = 1;
              _currentFlow = 'map';
            });
          } else {
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

      // 🔥 TAB 2: PRESTASI (AchievementsScreen)
      // Menerima data untuk Trofi, Statistik, dan Lencana
      AchievementsScreen(
        badges: earnedBadges,
        completedLevels: totalLevelsDone,
        stars: stars, // Dikirim juga untuk logika trofi jika perlu
      ),

      // 🔥 TAB 3: PROFIL (ProfileScreen)
      // Menerima data untuk Kustomisasi dan Info Dasar
      ProfileScreen(
        userName: userName,
        stars: stars,
        daysLearned: 1, 
        completedLevels: totalLevelsDone,
        onEditName: _changeName,
        // Data Kustomisasi
        currentFace: currentFace,
        equippedHat: equippedHat,
        equippedGlasses: equippedGlasses,
        ownedAvatars: ownedAvatars,
        onBuyItem: _buyAvatar,
        onEquipItem: _equipAvatar,
        onChangeFace: _changeFace,
      ),
    ];

    if (_currentFlow == 'map') {
      return AdventureMapScreen(
        subject: selectedSubject!,
        difficulty: selectedDifficulty!,
        highestCompletedLevel: _getProgress(selectedSubject!, selectedDifficulty!),
        onBack: () => setState(() => _currentFlow = 'root'),
        onLevelClick: (level) => setState(() {
          currentLevel = level;
          _currentFlow = (selectedSubject == "Menulis") ? 'writing' : 'question';
        }),
      );
    } else if (_currentFlow == 'writing') {
      return WritingScreen(
        step: currentLevel,
        onBack: () => setState(() => _currentFlow = 'map'),
        onComplete: (canProceed) async {
          if (canProceed) {
            await _updateProgress("Menulis", "mudah", currentLevel);
            setState(() { stars += 10; });
            await _saveData();
            _checkAndUnlockBadges();
            showDialog(context: context, barrierDismissible: false, builder: (ctx) => FeedbackPopup(onClose: () { Navigator.pop(ctx); setState(() => _currentFlow = 'map'); }));
          } else { setState(() => _currentFlow = 'map'); }
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
            await _updateProgress(selectedSubject ?? "Berhitung", selectedDifficulty ?? "mudah", currentLevel);
            setState(() { stars += 10; });
            await _saveData();
            _checkAndUnlockBadges();
            showDialog(context: context, barrierDismissible: false, builder: (ctx) => FeedbackPopup(onClose: () { Navigator.pop(ctx); setState(() => _currentFlow = 'map'); }));
          } else { setState(() => _currentFlow = 'map'); }
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softTeal,
      body: pages[_bottomNavIndex], 
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}