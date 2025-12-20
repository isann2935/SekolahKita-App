import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../services/user_progress_service.dart'; // 👈 Wajib import ini
import '../../services/notification_service.dart'; // 👈 Untuk kontrol notifikasi

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int stars;
  final int daysLearned;
  final int completedLevels;
  final Function(String) onEditName;

  // Data Avatar Baru
  final String currentFace;
  final String? equippedHat;
  final String? equippedGlasses;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.stars,
    required this.daysLearned,
    required this.completedLevels,
    required this.onEditName,
    required this.currentFace,
    required this.equippedHat,
    required this.equippedGlasses,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController _nameController;
  bool _notificationsEnabled = true;
  static const String _notifKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    setState(() {
      _notificationsEnabled = value;
    });
    
    if (value) {
      // Aktifkan notifikasi
      await NotificationService().scheduleDailyReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔔 Notifikasi pengingat diaktifkan"), backgroundColor: AppColors.green),
        );
      }
    } else {
      // Matikan notifikasi
      await NotificationService().cancelTodayReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔕 Notifikasi pengingat dimatikan"), backgroundColor: AppColors.orange),
        );
      }
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings, color: AppColors.blue),
                  SizedBox(width: 12),
                  Text(
                    "Pengaturan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Toggle Notifikasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _notificationsEnabled ? AppColors.orange : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Notifikasi Pengingat",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            _notificationsEnabled ? "Aktif • Setiap hari jam 17:00" : "Tidak aktif",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        _toggleNotifications(value);
                        setModalState(() {}); // Update modal state
                      },
                      activeColor: AppColors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      widget.onEditName(_nameController.text.trim());
      setState(() {
        isEditing = false;
      });
    }
  }

  // Helper untuk Mapping Aksesoris
  Map<String, dynamic> _getAccessoryData(String? id) {
    if (id == null) return {'emoji': '', 'offset_y': 0.0};
    const map = {
      'hat1': {'emoji': '🎩', 'offset_y': -35.0},
      'hat2': {'emoji': '👑', 'offset_y': -40.0},
      'hat3': {'emoji': '🎓', 'offset_y': -32.0},
      'glasses1': {'emoji': '👓', 'offset_y': -3.0},
      'glasses2': {'emoji': '🕶️', 'offset_y': -3.0},
      'glasses3': {'emoji': '🥽', 'offset_y': -3.0},
    };
    return map[id] ?? {'emoji': '', 'offset_y': 0.0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // --- HEADER SECTION ---
          Container(
            padding: const EdgeInsets.only(bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.green, Color(0xFF4ECDC4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Bar - Layout seperti Prestasi
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kiri: Judul & Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Profil",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Informasi & Pengaturan",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        // Kanan: Icon Settings
                        GestureDetector(
                          onTap: _showSettings,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar & Name
                  Column(
                    children: [
                      // --- AVATAR DINAMIS ---
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Wajah Dasar
                            Text(
                              widget.currentFace,
                              style: const TextStyle(fontSize: 55, height: 1),
                            ),

                            // Layer Kacamata
                            if (widget.equippedGlasses != null)
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  _getAccessoryData(
                                    widget.equippedGlasses,
                                  )['offset_y']
                                      as double,
                                ),
                                child: Text(
                                  _getAccessoryData(
                                    widget.equippedGlasses,
                                  )['emoji']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    height: 1,
                                  ),
                                ),
                              ),

                            // Layer Topi
                            if (widget.equippedHat != null)
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  _getAccessoryData(
                                    widget.equippedHat,
                                  )['offset_y']
                                      as double,
                                ),
                                child: Text(
                                  _getAccessoryData(
                                      widget.equippedHat)['emoji']
                                      as String,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    height: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate().scale(
                        curve: Curves.elasticOut,
                        duration: 800.ms,
                      ),

                      const SizedBox(height: 16),

                      // Name Display / Edit
                      if (isEditing)
                        Container(
                          width: 200,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: AppColors.green,
                                ),
                                onPressed: _saveName,
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => isEditing = true),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- CONTENT SECTION ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    _StatCard(
                      title: "Bintang",
                      value: "${widget.stars}",
                      icon: Icons.star,
                      color: AppColors.yellow,
                      iconColor: AppColors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: "Level",
                      value: "${widget.completedLevels}",
                      icon: Icons.emoji_events,
                      color: AppColors.green,
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: "Hari",
                      value: "${widget.daysLearned}",
                      icon: Icons.calendar_today,
                      color: const Color(0xFFFF6B9D),
                      iconColor: Colors.white,
                    ),
                  ],
                ).animate().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // --- BAGIAN STATISTIK MATERI SELESAI (BARU) ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Statistik Belajar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Menampilkan Data Materi Selesai
                      FutureBuilder<int>(
                        future: UserProgressService.getCompletedMaterials(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return _StatRow(
                            label: "Materi Selesai",
                            value: "$count Pelajaran",
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Progress Bar Statis (Contoh)
                      const Text(
                        "Kemajuan",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (widget.completedLevels / 8).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.green, Color(0xFF4ECDC4)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- LENCANA PRESTASI ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.military_tech, color: AppColors.yellow),
                          SizedBox(width: 8),
                          Text(
                            "Lencana Prestasi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _BadgeItem(emoji: "🎯", label: "Pemula"),
                          _BadgeItem(
                            emoji: "🔥",
                            label: "Rajin",
                            isLocked: true,
                          ),
                          _BadgeItem(
                            emoji: "⚡",
                            label: "Cepat",
                            isLocked: true,
                          ),
                          _BadgeItem(
                            emoji: "👑",
                            label: "Master",
                            isLocked: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isLocked;

  const _BadgeItem({
    required this.emoji,
    required this.label,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.4 : 1.0,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey[200] : AppColors.yellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}