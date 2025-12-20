import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class AchievementsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // --- DATA ---
    final baseFaces = ['😊', '😎', '🤠', '🥳', '😐', '👧', '👦', '🐶', '🐱'];

    // Data Lencana (Trofi)
    final allBadges = [
      {
        'id': 'beginner',
        'name': 'Pemula',
        'emoji': '🎯',
        'color': AppColors.yellow,
      },
      {
        'id': 'reader',
        'name': 'Pembaca',
        'emoji': '📚',
        'color': const Color(0xFFFF6B9D),
      },
      {
        'id': 'fast',
        'name': 'Cepat',
        'emoji': '⚡',
        'color': const Color(0xFF4ECDC4),
      },
      {
        'id': 'streak',
        'name': 'Rajin',
        'emoji': '🔥',
        'color': AppColors.orange,
      },
      {
        'id': 'writer',
        'name': 'Penulis',
        'emoji': '✏️',
        'color': const Color(0xFFC7CEEA),
      },
      {
        'id': 'math',
        'name': 'Matematika',
        'emoji': '🧮',
        'color': const Color(0xFFA8E6CF),
      },
      {
        'id': 'master',
        'name': 'Master',
        'emoji': '👑',
        'color': AppColors.yellow,
      },
      {
        'id': 'genius',
        'name': 'Jenius',
        'emoji': '🧠',
        'color': const Color(0xFFFF6B9D),
      },
    ];

    // Data Toko
    final shopItems = [
      {
        'id': 'hat1',
        'name': 'Topi Merah',
        'emoji': '🎩',
        'cost': 50,
        'type': 'hat',
        'offset_y': -55.0,
      },
      {
        'id': 'hat2',
        'name': 'Mahkota',
        'emoji': '👑',
        'cost': 100,
        'type': 'hat',
        'offset_y': -60.0,
      },
      {
        'id': 'hat3',
        'name': 'Wisuda',
        'emoji': '🎓',
        'cost': 75,
        'type': 'hat',
        'offset_y': -50.0,
      },
      {
        'id': 'glasses1',
        'name': 'Kacamata',
        'emoji': '👓',
        'cost': 30,
        'type': 'glasses',
        'offset_y': -5.0,
      },
      {
        'id': 'glasses2',
        'name': 'Hitam',
        'emoji': '🕶️',
        'cost': 50,
        'type': 'glasses',
        'offset_y': -5.0,
      },
      {
        'id': 'glasses3',
        'name': 'Selam',
        'emoji': '🥽',
        'cost': 45,
        'type': 'glasses',
        'offset_y': -5.0,
      },
    ];

    // Helper
    Map<String, dynamic> getItemData(String? id) {
      if (id == null) return {'emoji': '', 'offset_y': 0.0};
      return shopItems.firstWhere(
        (e) => e['id'] == id,
        orElse: () => {'emoji': '', 'offset_y': 0.0},
      );
    }

    void showEditNameDialog() {
      final TextEditingController controller = TextEditingController(
        text: userName,
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
            decoration: InputDecoration(
              hintText: "Masukkan nama baru...",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onChangeName(controller.text.trim());
                  Navigator.pop(context);
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
                          currentFace,
                          style: const TextStyle(fontSize: 90, height: 1),
                        ),
                        if (equippedGlasses != null)
                          Transform.translate(
                            offset: Offset(
                              0,
                              getItemData(equippedGlasses)['offset_y'],
                            ),
                            child: Text(
                              getItemData(equippedGlasses)['emoji'],
                              style: const TextStyle(fontSize: 50, height: 1),
                            ),
                          ),
                        if (equippedHat != null)
                          Transform.translate(
                            offset: Offset(
                              0,
                              getItemData(equippedHat)['offset_y'],
                            ),
                            child: Text(
                              getItemData(equippedHat)['emoji'],
                              style: const TextStyle(fontSize: 60, height: 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // NAMA USER + EDIT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
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
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$stars Bintang",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 2. PILIHAN WAJAH
                const Text(
                  "Pilih Wajah",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: baseFaces.length,
                    itemBuilder: (context, index) {
                      final face = baseFaces[index];
                      final isSelected = face == currentFace;
                      return GestureDetector(
                        onTap: () => onChangeFace(face),
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

                // 3. TOKO AKSESORIS
                const Text(
                  "Aksesoris",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
                    final bool isOwned = ownedAvatars.contains(id);
                    final bool isEquipped =
                        (type == 'hat' && equippedHat == id) ||
                        (type == 'glasses' && equippedGlasses == id);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isEquipped
                            ? const Color(0xFFF0FDF4)
                            : Colors.white,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['emoji'] as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isOwned)
                                GestureDetector(
                                  onTap: () => onBuyItem(id, cost),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
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
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () => onEquipItem(id, type),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
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
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // --- 4. LEMARI TROFI (DITAMBAHKAN KEMBALI) ---
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
                    final isEarned = badges.contains(badge['id']);

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
                            color: isEarned ? AppColors.textDark : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
