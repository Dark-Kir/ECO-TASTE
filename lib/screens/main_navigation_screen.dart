import 'package:flutter/material.dart';

import 'home_content_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  /// 🔥 ключ для вложенного навигатора
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      /// 🔥 Вкладка "Главная" с отдельным стеком навигации
      Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const HomeContentScreen(),
          );
        },
      ),

      /// Вкладка "Профиль"
      const ProfileScreen(),
    ];
  }

  /// 🔥 обработка нажатия на нижнее меню
  void _onTap(int index) {
    if (index == 0) {
      /// 👉 если нажали "Главная" — сбрасываем стек
      _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  /// 🔥 обработка кнопки "назад"
  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      final navigator = _homeNavigatorKey.currentState;

      /// если внутри есть куда вернуться — возвращаемся
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
        return false;
      }
    }

    /// иначе — разрешаем закрытие приложения
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,

      child: Scaffold(
        backgroundColor: const Color(0xFFF5EBDD),

        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),

        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD4AF37).withOpacity(0.2),

          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTap,

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}