import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English (EN)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
         Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Select Language',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Icon(Icons.language, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  buildLanguageOption('English (EN)', selectedLanguage),
                  buildLanguageOption('Bahasa Melayu', selectedLanguage),
                  buildLanguageOption('Chinese (中文)', selectedLanguage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageOption(String language, String selectedLanguage) {
    return GestureDetector(
        onTap: () {
          setState(() {
            this.selectedLanguage = language;
          });
        },
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: this.selectedLanguage == language
                    ? Colors.purple
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: this.selectedLanguage == language
                  ? Colors.purple.withOpacity(0.1)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (this.selectedLanguage == language)
                  Icon(
                    Icons.check_circle,
                    color: Colors.purple,
                  ),
              ],
            ),

        ),
    );

  }
}