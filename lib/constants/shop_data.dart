import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Shop Items Data
const List<Map<String, dynamic>> SHOP_ITEMS = [
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

// Badge Data
final List<Map<String, dynamic>> ALL_BADGES = [
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
    'color': Color(0xFFFF6B9D),
  },
  {'id': 'fast', 'name': 'Cepat', 'emoji': '⚡', 'color': Color(0xFF4ECDC4)},
  {'id': 'streak', 'name': 'Rajin', 'emoji': '🔥', 'color': AppColors.orange},
  {
    'id': 'writer',
    'name': 'Penulis',
    'emoji': '✏️',
    'color': Color(0xFFC7CEEA),
  },
  {
    'id': 'math',
    'name': 'Matematika',
    'emoji': '🧮',
    'color': Color(0xFFA8E6CF),
  },
  {'id': 'master', 'name': 'Master', 'emoji': '👑', 'color': AppColors.yellow},
  {'id': 'genius', 'name': 'Jenius', 'emoji': '🧠', 'color': Color(0xFFFF6B9D)},
];

// App Dimensions/Spacing
class AppDimensions {
  static const double spacingXSmall = 8;
  static const double spacingSmall = 12;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;

  static const int gridCrossCount = 2;
  static const double gridAspectRatio = 1.4;
  static const double gridSpacing = 12;

  static const double faceListHeight = 70;
  static const double bottomPadding = 100;

  static const int maxNameLength = 20;
  static const int minNameLength = 1;
}

// Validation Constants
class ValidationRules {
  // Regex untuk huruf dan spasi saja
  static const String namePattern = r'^[a-zA-Z\s]+$';

  static bool isValidName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return false;
    if (trimmed.length > AppDimensions.maxNameLength) return false;
    if (!RegExp(ValidationRules.namePattern).hasMatch(trimmed)) return false;

    return true;
  }

  static String? getNameError(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (trimmed.length > AppDimensions.maxNameLength) {
      return 'Nama maksimal ${AppDimensions.maxNameLength} karakter';
    }

    if (!RegExp(ValidationRules.namePattern).hasMatch(trimmed)) {
      return 'Nama hanya boleh huruf dan spasi';
    }

    return null;
  }
}
