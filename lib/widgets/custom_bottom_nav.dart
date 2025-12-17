import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: "Beranda",
            isActive: currentIndex == 0,
            color: AppColors.green,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.fitness_center_rounded,
            label: "Latihan",
            isActive: currentIndex == 1,
            color: AppColors.blue,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.emoji_events_rounded,
            label: "Prestasi",
            isActive: currentIndex == 2,
            color: AppColors.yellow,
            onTap: () => onTap(2),
          ),
          // --- ITEM BARU: PROFIL ---
          _NavItem(
            icon: Icons.person_rounded,
            label: "Profil",
            isActive: currentIndex == 3,
            color: AppColors.red,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? color : Colors.grey, size: 28),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}