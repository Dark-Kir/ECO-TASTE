import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentInput extends StatefulWidget {
  final String restaurantId;

  const CommentInput({super.key, required this.restaurantId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 0;

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите, чтобы оставить отзыв')),
      );
      return;
    }

    if (_controller.text.trim().isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните текст и рейтинг')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('comments')
        .add({
      'text': _controller.text.trim(),
      'rating': _rating,
      'userId': user.uid,
      'userName': user.email ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    setState(() => _rating = 0);
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index < _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
      onPressed: () {
        setState(() => _rating = index + 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuth = user != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Оставить отзыв',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        /// ⭐ звезды
        Row(
          children: List.generate(5, (index) => _buildStar(index)),
        ),

        /// 💬 текст
        TextField(
          controller: _controller,
          enabled: isAuth,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: isAuth
                ? 'Напишите отзыв...'
                : 'Войдите, чтобы оставить отзыв',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// 🚀 кнопка
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAuth ? _submit : null,
            child: const Text('Отправить'),
          ),
        ),
      ],
    );
  }
}