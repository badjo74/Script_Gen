import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _generatedText = '';
  bool _isLoading = false;
  bool _isDarkMode = false;
  bool _isArabic = true; // Default language is Arabic
  final TextEditingController _topicController = TextEditingController();
  final String apiKey = 'AIzaSyD_5U1hOrO4zxM-d8aztYlIwv5hobQ4kZI';

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> generateText(String topic) async {
    if (topic.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isArabic ? 'يرجى إدخال موضوع!' : 'Please enter a topic!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedText = '';
    });

    try {
      final generativeModel =
          GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      final prompt = _isArabic
          ? 'اكتب قصة قصيرة عن $topic لا تتجاوز 60 ثانية في القراءة.'
          : 'Write a short story about $topic that takes no more than 60 seconds to read.';
      final response =
          await generativeModel.generateContent([Content.text(prompt)]);

      setState(() {
        _generatedText = response.text ??
            (_isArabic ? 'لم يتم إنشاء نص.' : 'No text was generated.');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = _isArabic
            ? 'حدث خطأ أثناء إنشاء النص: $e'
            : 'An error occurred while generating text: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isArabic
              ? 'تم نسخ النص إلى الحافظة!'
              : 'Text copied to clipboard!'),
        ),
      );
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _topicController.clear();
      _generatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModeSystem = Theme.of(context).brightness == Brightness.dark;
    final effectiveDarkMode = _isDarkMode || isDarkModeSystem;

    return Theme(
      data: effectiveDarkMode
          ? ThemeData.dark(useMaterial3: true).copyWith(
              primaryColor: Colors.redAccent,
              colorScheme: const ColorScheme.dark(
                primary: Colors.redAccent,
                secondary: Colors.redAccent,
              ),
            )
          : ThemeData.light(useMaterial3: true).copyWith(
              primaryColor: Colors.redAccent,
              colorScheme: const ColorScheme.light(
                primary: Colors.redAccent,
                secondary: Colors.redAccent,
              ),
            ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(_isArabic ? 'مولد القصص' : 'Story Generator',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          actions: [
            // Language toggle button
            IconButton(
              icon: Icon(_isArabic ? Icons.language : Icons.translate),
              onPressed: _toggleLanguage,
              tooltip: _isArabic ? 'Switch to English' : 'التبديل إلى العربية',
            ),
            // Dark mode toggle button
            IconButton(
              icon:
                  Icon(effectiveDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: effectiveDarkMode ? 'Light mode' : 'Dark mode',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: effectiveDarkMode
                  ? [Colors.grey[900]!, Colors.black]
                  : [Colors.grey[300]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 100),

                // Story display area
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.redAccent))
                      : _generatedText.isNotEmpty
                          ? FadeIn(
                              duration: const Duration(milliseconds: 500),
                              child: Column(
                                children: [
                                  // Copy button above text
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: Text(_isArabic ? 'نسخ' : 'Copy',
                                        style: const TextStyle(fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _copyToClipboard,
                                  ),
                                  const SizedBox(height: 10),
                                  // Text display area
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 6,
                                      color: effectiveDarkMode
                                          ? Colors.grey[850]
                                          : Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                            _generatedText,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: effectiveDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            textAlign: _isArabic
                                                ? TextAlign.right
                                                : TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                _isArabic
                                    ? 'أدخل موضوعًا لإنشاء قصة'
                                    : 'Enter a topic to generate a story',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: effectiveDarkMode
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                ),

                const SizedBox(height: 20),

                // Search field moved to bottom
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _topicController,
                            decoration: InputDecoration(
                              hintText: _isArabic
                                  ? 'أدخل موضوع القصة...'
                                  : 'Enter your story topic...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            textAlign:
                                _isArabic ? TextAlign.right : TextAlign.left,
                            onSubmitted: (value) => generateText(value),
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.search, color: Colors.redAccent),
                          onPressed: () => generateText(_topicController.text),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
