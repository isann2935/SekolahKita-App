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

  // Data Game
  List<String> earnedBadges = ['beginner'];
  List<String> ownedAvatars = [];

  // State Kustomisasi Avatar
  String currentFace = '😊';
  String? equippedHat;
  String? equippedGlasses;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOGIC PENYIMPANAN DATA (OFFLINE) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      userName = prefs.getString('userName') ?? "Budi";
      stars = prefs.getInt('stars') ?? 200;

      ownedAvatars = prefs.getStringList('ownedAvatars') ?? [];
      earnedBadges = prefs.getStringList('earnedBadges') ?? ['beginner'];

      currentFace = prefs.getString('currentFace') ?? '😊';
      equippedHat = prefs.getString('equippedHat');
      equippedGlasses = prefs.getString('equippedGlasses');

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: AppColors.softTeal);
    }

    if (!hasOnboarded) {
      return OnboardingScreen(onStart: (name) {
        setState(() {
          userName = name;
          hasOnboarded = true;
        });
        _saveData();
      });
    }

    if (_currentFlow == 'map') {
      return AdventureMapScreen(
        subject: selectedSubject!,
        difficulty: selectedDifficulty!,
        onBack: () => setState(() => _currentFlow = 'root'),
        onLevelClick: () => setState(() => _currentFlow = 'question'),
      );
    } else if (_currentFlow == 'question') {
      return QuestionScreen(
        mode: selectedDifficulty!,
        onBack: () => setState(() => _currentFlow = 'map'),
        onComplete: (correct) {
          if (correct) {
            setState(() {
              stars += 10;
            });
            _saveData();
          }
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