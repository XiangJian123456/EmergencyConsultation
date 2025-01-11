import 'package:flutter/material.dart';

class Doc_User_CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex; // Current selected index
  final Function(int) onItemTapped; // Callback for item tap

  const Doc_User_CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavButton('Home', 'assets/home.png', () => onItemTapped(0)),
              ],
            ),
            // Right side buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavButton('Wallet', 'assets/wallet.png', () => onItemTapped(1)),
                _buildNavButton('Setting', 'assets/settings-gear-icon.png', () => onItemTapped(2)),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, String imagePath, VoidCallback onPressed) {
    final bool isSelected = label.toLowerCase() == ['home','wallet', 'setting'][selectedIndex].toLowerCase();

    return MaterialButton(
      minWidth: 50,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 24.0,
            height: 24.0,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}