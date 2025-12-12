import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BottomAppBar(
      color: theme.bottomAppBarTheme.color ??
          (isDarkMode ? Colors.black : Colors.white),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isLandscape = screenWidth > screenHeight;

          final navHeight = isLandscape ? 50.0 : 70.0;
          final fontSize = screenWidth < 350 ? 10.0 : 12.0;

          return Container(
            height: navHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.home_rounded,
                    label: "Home",
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    label: "Scan to pay",
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildNavItem(
                    context,
                    icon: Icons.settings,
                    label: "Settings",
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemTapped(2),
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isSelected,
        required VoidCallback onTap,
        required double fontSize,
      }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell( // ✅ full clickable surface
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.indigo.shade900, // Selected background
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
