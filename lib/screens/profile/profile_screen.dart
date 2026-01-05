import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import untuk simpan setting
import '../../theme/colors.dart';
import '../../constants/shop_data.dart'; 
import '../../services/notification_service.dart'; // ✅ Import Service Notifikasi

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int stars;
  final int daysLearned;
  final int completedLevels;
  final Function(String) onEditName;

  // Data Kustomisasi
  final List<String> ownedAvatars;
  final String currentFace;
  final String? equippedHat;
  final String? equippedGlasses;
  final Function(String id, int cost) onBuyItem;
  final Function(String id, String type) onEquipItem;
  final Function(String newFace) onChangeFace;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.stars,
    required this.daysLearned,
    required this.completedLevels,
    required this.onEditName,
    required this.ownedAvatars,
    required this.currentFace,
    required this.equippedHat,
    required this.equippedGlasses,
    required this.onBuyItem,
    required this.onEquipItem,
    required this.onChangeFace,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late TextEditingController _nameController;
  
  // State Notifikasi
  bool _isNotifEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _loadNotifSetting(); // Load setting saat buka
  }

  // Load status notifikasi dari HP
  Future<void> _loadNotifSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotifEnabled = prefs.getBool('daily_reminder') ?? true; // Default nyala
    });
  }

  // Toggle Notifikasi (On/Off)
  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotifEnabled = value;
    });
    await prefs.setBool('daily_reminder', value);

    if (value) {
      await NotificationService().scheduleDailyReminder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔔 Pengingat harian diaktifkan!"), backgroundColor: AppColors.green),
      );
    } else {
      await NotificationService().cancelTodayReminder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔕 Pengingat dimatikan."), backgroundColor: Colors.grey),
      );
    }
  }

  void _saveName() {
    if (_nameController.text.trim().isNotEmpty) {
      widget.onEditName(_nameController.text.trim());
      setState(() => isEditing = false);
    }
  }

  Map<String, dynamic> _getAccessoryData(String? id) {
    if (id == null) return {'emoji': '', 'offset_y': 0.0};
    const customPosition = {
      'hat1': {'emoji': '🎩', 'offset_y': -33.0},
      'hat2': {'emoji': '👑', 'offset_y': -34.0},
      'hat3': {'emoji': '🎓', 'offset_y': -25.0},
      'glasses1': {'emoji': '👓', 'offset_y': 0.0},
      'glasses2': {'emoji': '🕶️', 'offset_y': 0.0},
      'glasses3': {'emoji': '🥽', 'offset_y': 0.0},
    };
    if (customPosition.containsKey(id)) return customPosition[id]!;
    final item = SHOP_ITEMS.firstWhere((e) => e['id'] == id, orElse: () => {});
    return item.isEmpty ? {'emoji': '', 'offset_y': 0.0} : item;
  }

  // 🔥 FUNGSI MENAMPILKAN POPUP PENGATURAN
  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder( // Pakai StatefulBuilder biar switch bisa gerak real-time
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Modal
                Row(
                  children: const [
                    Icon(Icons.settings, color: AppColors.blue, size: 28),
                    SizedBox(width: 12),
                    Text("Pengaturan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),

                // Kartu Toggle Notifikasi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      // Ikon Lonceng Background Orange
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      
                      // Teks Keterangan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Notifikasi Pengingat",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isNotifEnabled ? "Aktif • Setiap hari jam 17:00" : "Tidak aktif",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Switch Toggle
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: _isNotifEnabled,
                          activeColor: AppColors.green,
                          onChanged: (value) {
                            // Update state di layar Profile
                            _toggleNotification(value);
                            // Update state di dalam Modal
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40), // Jarak bawah
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseFaces = ['😊', '😎', '🤠', '🥳', '😐', '👧', '👦', '🐶', '🐱'];
    final shopItems = SHOP_ITEMS;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // --- HEADER PROFIL ---
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Profil & Kustomisasi", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        
                        // 🔥 TOMBOL SETTINGS (ICON GEAR)
                        GestureDetector(
                          onTap: _showSettingsModal,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.settings, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // AVATAR
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white, width: 4)),
                        child: Center(child: Text(widget.currentFace, style: const TextStyle(fontSize: 55, height: 1))),
                      ),
                      if (widget.equippedGlasses != null) _buildAccessoryLayer(id: widget.equippedGlasses!, size: 35),
                      if (widget.equippedHat != null) _buildAccessoryLayer(id: widget.equippedHat!, size: 45),
                    ],
                  ).animate().scale(duration: 500.ms),

                  const SizedBox(height: 12),
                  
                  // NAMA
                  if (isEditing)
                    Container(
                      width: 200, height: 45,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(children: [Expanded(child: TextField(controller: _nameController, autofocus: true, decoration: const InputDecoration(border: InputBorder.none))), IconButton(icon: const Icon(Icons.check, color: AppColors.green), onPressed: _saveName)]),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        GestureDetector(onTap: () => setState(() => isEditing = true), child: const Icon(Icons.edit, color: Colors.white, size: 18)),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  // Sisa Bintang (Dipindah ke bawah nama biar rapi)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.yellow, size: 18),
                        const SizedBox(width: 4),
                        Text("${widget.stars}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. TIGA KARTU STATS
                Row(
                  children: [
                    _StatCard(title: "Bintang", value: "${widget.stars}", icon: Icons.star, color: AppColors.yellow, iconColor: AppColors.orange),
                    const SizedBox(width: 12),
                    _StatCard(title: "Level", value: "${widget.completedLevels}", icon: Icons.emoji_events, color: AppColors.green, iconColor: Colors.white),
                    const SizedBox(width: 12),
                    _StatCard(title: "Hari", value: "${widget.daysLearned}", icon: Icons.calendar_today, color: const Color(0xFFFF6B9D), iconColor: Colors.white),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. KUSTOMISASI WAJAH
                const Text("Ganti Wajah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: baseFaces.length,
                    itemBuilder: (context, index) {
                      final face = baseFaces[index];
                      final isSelected = face == widget.currentFace;
                      return GestureDetector(
                        onTap: () => widget.onChangeFace(face),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.green.withValues(alpha: 0.2) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected ? Border.all(color: AppColors.green, width: 2) : null,
                          ),
                          child: Center(child: Text(face, style: const TextStyle(fontSize: 32))),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. TOKO AKSESORIS
                const Text("Toko Aksesoris", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    mainAxisSpacing: 16, 
                    crossAxisSpacing: 16, 
                    childAspectRatio: 1.2,
                  ),
                  itemCount: shopItems.length,
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    final String id = item['id'] as String;
                    final String type = item['type'] as String;
                    final int cost = item['cost'] as int;
                    final bool isOwned = widget.ownedAvatars.contains(id);
                    final bool isEquipped = (type == 'hat' && widget.equippedHat == id) || (type == 'glasses' && widget.equippedGlasses == id);

                    return GestureDetector(
                      onTap: () {
                        if (!isOwned) {
                          try { widget.onBuyItem(id, cost); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bintang tidak cukup!'), backgroundColor: Colors.red)); }
                        } else { widget.onEquipItem(id, type); }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: isEquipped ? Border.all(color: AppColors.green, width: 3) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item['emoji'] as String, style: const TextStyle(fontSize: 40)),
                            const Spacer(),
                            if (!isOwned) 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
                                child: Text("⭐ $cost", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                              )
                            else 
                              Text(isEquipped ? "Dipakai" : "Milikmu", style: TextStyle(fontSize: 14, color: isEquipped ? AppColors.green : Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryLayer({required String id, required double size}) {
    final item = _getAccessoryData(id);
    return Transform.translate(offset: Offset(0, item['offset_y'] as double), child: Text(item['emoji'] as String, style: TextStyle(fontSize: size, height: 1)));
  }
}

class _StatCard extends StatelessWidget {
  final String title, value; final IconData icon; final Color color, iconColor;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.iconColor});
  @override Widget build(BuildContext context) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))]), child: Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))])));
  }
}