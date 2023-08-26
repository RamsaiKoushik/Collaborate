import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

class CustomTextField extends StatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final Widget prefixIcon;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.text,
    required this.prefixIcon,
    required this.controller,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: color4),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              labelText: widget.label,
              labelStyle: const TextStyle(color: color4),
              filled: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: Colors.white.withOpacity(0.3),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      const BorderSide(width: 0, style: BorderStyle.none)),
            ),
            maxLines: widget.maxLines,
          ),
        ],
      );
}
