import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReceiptPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? photoUrl;

  const ReceiptPhotoButton({
    super.key,
    required this.onTap,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              photoUrl == null ? FontAwesomeIcons.receipt : FontAwesomeIcons.image,
              size: 16,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(width: 8),
            Text(
              photoUrl == null ? '添加收据照片' : '查看收据照片',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFF97316),
              ),
            ),
            if (photoUrl != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
