import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_theme.dart';

class NumberInput extends StatelessWidget {
  final double value;
  final double step;
  final double? min;
  final double? max;
  final ValueChanged<double> onChanged;
  final String? prefix;
  final String? suffix;

  const NumberInput({
    Key? key,
    required this.value,
    this.step = 1,
    this.min,
    this.max,
    required this.onChanged,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                prefix!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
          Expanded(
            child: TextFormField(
              initialValue: value.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (text) {
                final newValue = double.tryParse(text);
                if (newValue != null) {
                  final clampedValue = _clampValue(newValue);
                  if (clampedValue != newValue) {
                    onChanged(clampedValue);
                  } else {
                    onChanged(newValue);
                  }
                }
              },
            ),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                suffix!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
          Container(
            width: 1,
            height: 32,
            color: Colors.grey[300],
          ),
          SizedBox(
            width: 32,
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  icon: FontAwesomeIcons.plus,
                  onPressed: () {
                    final newValue = _clampValue(value + step);
                    if (newValue != value) {
                      onChanged(newValue);
                    }
                  },
                ),
                Container(
                  width: 32,
                  height: 1,
                  color: Colors.grey[300],
                ),
                _buildButton(
                  icon: FontAwesomeIcons.minus,
                  onPressed: () {
                    final newValue = _clampValue(value - step);
                    if (newValue != value) {
                      onChanged(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 22,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 12,
          color: Colors.grey[600],
        ),
        onPressed: onPressed,
      ),
    );
  }

  double _clampValue(double value) {
    if (min != null && value < min!) {
      return min!;
    }
    if (max != null && value > max!) {
      return max!;
    }
    return value;
  }
}
