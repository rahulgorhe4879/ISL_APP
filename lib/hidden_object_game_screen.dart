import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class HiddenObjectGameScreen extends StatefulWidget {
  final int level;
  const HiddenObjectGameScreen({Key? key, required this.level}) : super(key: key);
  @override
  _HiddenObjectGameScreenState createState() => _HiddenObjectGameScreenState();
}

class _HiddenObjectGameScreenState extends State<HiddenObjectGameScreen> {
  bool isObjectFound = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Game Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Level 2: Find the Hidden Object!',
                      style: TextStyle(fontSize: 24, color: kPrimaryText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => setState(() => isObjectFound = true),
                    child: Container(
                      width: 250, height: 180,
                      decoration: BoxDecoration(
                        color: isObjectFound ? Colors.green.withValues(alpha: 0.2) : kLockedColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isObjectFound ? Colors.green : Colors.transparent, width: 3),
                      ),
                      child: Icon(isObjectFound ? Icons.check_circle : Icons.help_outline,
                          size: 80, color: isObjectFound ? Colors.green : kLockedText),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isObjectFound)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        Provider.of<LevelProgress>(context, listen: false).completeLevel(widget.level);
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('Level Complete! Return to Menu', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                ],
              ),
            ),
            // Back Button
            Positioned(
              top: 10, left: 10,
              child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}
