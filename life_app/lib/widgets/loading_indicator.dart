import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color = const Color(0xFF059669),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
