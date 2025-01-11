import 'package:flutter/material.dart';

class AmbulanceBottomNavigation extends StatelessWidget {
  final int selectedIndex; // Current selected index
  final Function(int) onItemTapped; // Callback for item tap

  const AmbulanceBottomNavigation({
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
        height: 70, // Increased height for better touch targets
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton('Home', Icons.home, () => onItemTapped(0)),
            _buildNavButton('Record', Icons.history, () => onItemTapped(1)),
            // Corrected index
            _buildNavButton('Report', Icons.file_copy, () => onItemTapped(2)),
            _buildNavButton('Setting', Icons.settings, () => onItemTapped(3)),

          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onPressed) {
    final bool isSelected = label.toLowerCase() ==
        ['home', 'record', 'report', 'setting'][selectedIndex].toLowerCase(); // Updated to match the correct order

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: MaterialButton(
        minWidth: 0,
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28.0, // Increased icon size for better visibility
              color: isSelected ? Colors.blue : Colors.grey, // Changed color to blue for selected state
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.0, // Increased font size for better readability
                color: isSelected ? Colors.blue : Colors.grey, // Changed color to blue for selected state
              ),
            ),
          ],
        ),
      ),
    );
  }
}