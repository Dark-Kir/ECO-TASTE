import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  'Профиль',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 28),

                /// 👤 Аватар
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFD4B483),
                  backgroundImage:
                      user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),

                const SizedBox(height: 16),

                /// 👤 Имя
                Text(
                  user?.displayName ?? 'Гость',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// 📩 Email или текст
                Text(
                  user?.email ?? 'Добро пожаловать в Balkhash Taste',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔐 КНОПКА ВХОД / ВЫХОД
                if (user == null)
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.signInWithGoogle();
                    },
                    child: const Text("Войти через Google"),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.signOut();
                    },
                    child: const Text("Выйти"),
                  ),

                const SizedBox(height: 30),

                /// ❤️ Избранное
                _profileItem(
                  context,
                  Icons.favorite,
                  'Избранные места',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                          

                /// ⚙️ Настройки
                _profileItem(
                  context,
                  Icons.settings,
                  'Настройки',
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4B483)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF8B6A43)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}