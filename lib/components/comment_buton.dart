import 'package:flutter/material.dart';

class CommentButon extends StatelessWidget {
  final void Function()? onTap;
  const CommentButon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.comment, color: Colors.grey, size: 19),
    );
  }
}
