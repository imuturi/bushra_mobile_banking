import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

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
                    label: AppLocalizations.of(context)!.home,
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
                    label: AppLocalizations.of(context)!.scanToPay,
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
                    label: AppLocalizations.of(context)!.settings,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
