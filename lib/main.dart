import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'duo_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ISLApp(),
    ),
  );
}

class ISLApp extends StatelessWidget {
  const ISLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Duo.bg,
            cardColor: Duo.cardBg,
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Duo.textPrimary),
              bodyMedium: TextStyle(color: Duo.textPrimary),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF131F24),
            cardColor: const Color(0xFF1F2E35),
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AppShell(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  APP SHELL — Bottom navigation
// ═══════════════════════════════════════════════════

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentTab = 0;

  final _screens = const [
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: isDark ? Colors.white10 : Duo.border, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          selectedItemColor: Duo.green,
          unselectedItemColor: isDark ? Colors.white38 : Duo.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 30),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 30),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
