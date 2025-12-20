import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  // Kunci untuk menyimpan data di memori HP
  static const String _keyMaterials = 'completed_materials_count';

  // 1. Ambil Data (Untuk ditampilkan di Profile)
  static Future<int> getCompletedMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaterials) ?? 0; // Default 0 kalau belum ada
  }

  // 2. Tambah Data +1 (Panggil ini saat Level Selesai!)
  static Future<void> incrementMaterialCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyMaterials) ?? 0;
    
    // Tambah 1
    int updated = current + 1;
    
    // Simpan
    await prefs.setInt(_keyMaterials, updated);
    print("✅ Statistik Update: Total Materi Selesai = $updated");
  }

  // 3. Reset Data (Opsional, buat testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaterials, 0);
  }
}