import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class LineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String placeholder;
  final Widget? right;

  const LineTextField({
    super.key,
    required this.title,
    required this.placeholder,
    required this.controller,
    this.right,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: right,
            hintText: placeholder,
            hintStyle: TextStyle(
              color: TColor.placeholder,
              fontSize: 17,
            ),
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 1,
          color: const Color(0xffE2E2E2),
        )
      ],
    );
  }
}
