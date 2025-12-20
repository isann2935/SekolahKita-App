import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../constants/shop_data.dart';

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
    final allBadges = ALL_BADGES;
    // Data Toko
    final shopItems = SHOP_ITEMS;

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
            maxLength: AppDimensions.maxNameLength,
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

                // Validate name
                final error = ValidationRules.getNameError(newName);

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: AppColors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                try {
                  onChangeName(newName);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama berhasil diubah! ✨'),
                      backgroundColor: AppColors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal mengubah nama'),
                      backgroundColor: AppColors.red,
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
                        if (equippedGlasses != null &&
                            equippedGlasses!.isNotEmpty)
                          _buildAccessoryLayer(
                            id: equippedGlasses!,
                            size: 50,
                            shopItems: shopItems,
                          ),
                        if (equippedHat != null && equippedHat!.isNotEmpty)
                          _buildAccessoryLayer(
                            id: equippedHat!,
                            size: 60,
                            shopItems: shopItems,
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
                    const SizedBox(width: AppDimensions.spacingXSmall),
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
                  height: AppDimensions.faceListHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: baseFaces.length,
                    itemBuilder: (context, index) {
                      final face = baseFaces[index];
                      final isSelected = face == currentFace;
                      return GestureDetector(
                        onTap: () {
                          try {
                            onChangeFace(face);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wajah berhasil diubah! 😊'),
                                backgroundColor: AppColors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mengubah wajah'),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          }
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

                const SizedBox(height: AppDimensions.spacingLarge),

                const SizedBox(height: AppDimensions.spacingXLarge),
                // 3. TOKO AKSESORIS
                const Text(
                  "Aksesoris",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppDimensions.gridCrossCount,
                    mainAxisSpacing: AppDimensions.gridSpacing,
                    crossAxisSpacing: AppDimensions.gridSpacing,
                    childAspectRatio: AppDimensions.gridAspectRatio,
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

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!isOwned) {
                          // Belum punya → Beli
                          try {
                            onBuyItem(id, cost);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil membeli item! 🎉'),
                                backgroundColor: AppColors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bintang tidak cukup! ⭐'),
                                backgroundColor: AppColors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          // Sudah punya → Toggle equip/unequip
                          try {
                            onEquipItem(id, type);
                            final action = isEquipped ? 'Dilepas' : 'Dipasang';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Item $action! ✨'),
                                backgroundColor: AppColors.green,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mengubah item'),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          }
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

                const SizedBox(height: AppDimensions.spacingXLarge),

                // --- 4. LEMARI TROFI (DITAMBAHKAN KEMBALI) ---
                Row(
                  children: const [
                    Icon(Icons.emoji_events, color: AppColors.yellow),
                    SizedBox(width: AppDimensions.spacingXSmall),
                    Text(
                      "Lemari Trofi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppDimensions.gridSpacing,
                    crossAxisSpacing: AppDimensions.gridSpacing,
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
                        const SizedBox(height: AppDimensions.spacingXSmall),
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

                const SizedBox(height: AppDimensions.bottomPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
