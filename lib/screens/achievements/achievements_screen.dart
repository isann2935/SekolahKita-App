import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../constants/shop_data.dart'; // Pastikan path ini benar sesuai strukturmu
import '../../services/user_progress_service.dart'; // 👈 Import Service Penyimpanan

class AchievementsScreen extends StatefulWidget {
  final String userName;
  final List<String> badges;
  final int stars;
  final List<String> ownedAvatars;
  final String currentFace;
  final String? equippedHat;
  final String? equippedGlasses;
  final Function(String id, int cost) onBuyItem;
  final Function(String id, String type) onEquipItem;
  final Function(String newFace) onChangeFace;
  final Function(String newName) onChangeName;

  const AchievementsScreen({
    super.key,
    required this.userName,
    required this.badges,
    required this.stars,
    required this.ownedAvatars,
    required this.currentFace,
    required this.equippedHat,
    required this.equippedGlasses,
    required this.onBuyItem,
    required this.onEquipItem,
    required this.onChangeFace,
    required this.onChangeName,
  });

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // --- STATE VARIABLES ---
  int _completedMaterials = 0; // Data Materi Selesai
  bool _isLoadingStats = true; // Status Loading

  @override
  void initState() {
    super.initState();
    _loadStatistics(); // 👈 Load data saat layar dibuka
  }

  // Fungsi Load Data dari Service
  Future<void> _loadStatistics() async {
    final count = await UserProgressService.getCompletedMaterials();
    if (mounted) {
      setState(() {
        _completedMaterials = count;
        _isLoadingStats = false;
      });
    }
  }

  // Dialog Ganti Nama
  void showEditNameDialog() {
    final TextEditingController controller = TextEditingController(
      text: widget.userName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Ganti Nama",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12, // Sesuaikan max length
          decoration: InputDecoration(
            hintText: "Masukkan nama baru...",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            helperText: 'Huruf dan spasi saja',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                widget.onChangeName(newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama berhasil diubah! ✨'),
                    backgroundColor: AppColors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- DATA ---
    final baseFaces = ['😊', '😎', '🤠', '🥳', '😐', '👧', '👦', '🐶', '🐱'];
    
    // Ambil data dari constants (sesuaikan nama variabel constant kamu)
    final allBadges = ALL_BADGES; 
    final shopItems = SHOP_ITEMS;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.yellow, Color(0xFFFFE66D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Prestasi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Koleksi & Kustomisasi",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const Text("🏆", style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
            ),
          ),

          // --- CONTENT ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. PREVIEW AVATAR
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.yellow, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          widget.currentFace,
                          style: const TextStyle(fontSize: 90, height: 1),
                        ),
                        if (widget.equippedGlasses != null &&
                            widget.equippedGlasses!.isNotEmpty)
                          _buildAccessoryLayer(
                            id: widget.equippedGlasses!,
                            size: 50,
                            shopItems: shopItems,
                          ),
                        if (widget.equippedHat != null &&
                            widget.equippedHat!.isNotEmpty)
                          _buildAccessoryLayer(
                            id: widget.equippedHat!,
                            size: 60,
                            shopItems: shopItems,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // NAMA USER + EDIT ICON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: showEditNameDialog,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // --- 2. KARTU STATISTIK (BARU) ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Statistik Bintang
                      Column(
                        children: [
                          const Icon(Icons.star, color: AppColors.orange, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.stars}",
                            style: const TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const Text(
                            "Bintang",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      // Statistik Materi Selesai (Dinamis)
                      Column(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.green, size: 28),
                          const SizedBox(height: 4),
                          _isLoadingStats
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2)
                                )
                              : Text(
                                  "$_completedMaterials",
                                  style: const TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                          const Text(
                            "Materi Selesai",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 3. PILIHAN WAJAH
                const Text(
                  "Pilih Wajah",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70, // Tinggi tetap agar ListView horizontal aman
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: baseFaces.length,
                    itemBuilder: (context, index) {
                      final face = baseFaces[index];
                      final isSelected = face == widget.currentFace;
                      return GestureDetector(
                        onTap: () {
                          widget.onChangeFace(face);
                          // Feedback visual/sound bisa ditambahkan di sini
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.green.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: AppColors.green, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              face,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 4. TOKO AKSESORIS
                const Text(
                  "Aksesoris",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Sesuaikan dengan layoutmu
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: shopItems.length,
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    final String id = item['id'] as String;
                    final String type = item['type'] as String;
                    final int cost = item['cost'] as int;
                    final bool isOwned = widget.ownedAvatars.contains(id);
                    final bool isEquipped =
                        (type == 'hat' && widget.equippedHat == id) ||
                        (type == 'glasses' && widget.equippedGlasses == id);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!isOwned) {
                          // Beli
                          try {
                            widget.onBuyItem(id, cost);
                          } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bintang tidak cukup!'), backgroundColor: Colors.red),
                            );
                          }
                        } else {
                          // Pakai/Lepas
                          widget.onEquipItem(id, type);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? const Color(0xFFF0FDF4)
                              : (isOwned ? Colors.grey.shade100 : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: isEquipped
                              ? Border.all(color: AppColors.green, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['emoji'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!isOwned)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 10),
                                    Text(
                                      " $cost",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isEquipped
                                      ? AppColors.red
                                      : AppColors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isEquipped ? "Lepas" : "Pakai",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 5. LEMARI TROFI
                Row(
                  children: const [
                    Icon(Icons.emoji_events, color: AppColors.yellow),
                    SizedBox(width: 8),
                    Text(
                      "Lemari Trofi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: allBadges.length,
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final isEarned = widget.badges.contains(badge['id']);

                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isEarned
                                  ? Colors.white
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isEarned
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                badge['emoji'] as String,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: isEarned
                                      ? null
                                      : Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge['name'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isEarned
                                ? AppColors.textDark
                                : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk render aksesoris di stack
  Widget _buildAccessoryLayer({
    required String id,
    required double size,
    required List<Map<String, dynamic>> shopItems,
  }) {
    final item = shopItems.firstWhere((e) => e['id'] == id, orElse: () => {});

    if (item.isEmpty || (item['emoji'] as String).isEmpty) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: Offset(0, item['offset_y'] as double),
      child: Text(
        item['emoji'] as String,
        style: TextStyle(fontSize: size, height: 1),
      ),
    );
  }
}