import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

class EcoTasteSplash extends StatefulWidget {
  const EcoTasteSplash({super.key});

  @override
  State<EcoTasteSplash> createState() => _EcoTasteSplashState();
}

class _EcoTasteSplashState extends State<EcoTasteSplash>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    /// АНИМАЦИЯ ОГОНЬКА
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// ПЕРЕХОД НА ГЛАВНЫЙ ЭКРАН
    Future.delayed(const Duration(seconds: 3), () {

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
        );
      }

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF07110D),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ЛОГОТИП
            Image.asset(
              'assets/images/splash.png',
              width: 360,
            ),

            const SizedBox(height: 80),

            /// ЛИНИЯ ЗАГРУЗКИ
            SizedBox(
              width: 180,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [

                  /// ОСНОВНАЯ ЛИНИЯ
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  /// АНИМИРОВАННЫЙ ОГОНЕК
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {

                      return Transform.translate(
                        offset: Offset(
                          _controller.value * 160,
                          0,
                        ),

                        child: Container(
                          width: 20,
                          height: 4,

                          decoration: BoxDecoration(
                            color: const Color(0xFFD4B06A),
                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4B06A),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ТЕКСТ
            const Text(
              "Loading...",
              style: TextStyle(
                color: Color(0xFFD4B06A),
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}