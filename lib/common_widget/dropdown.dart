

import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class Dropdown extends StatelessWidget {
  final String title;
  final String placeholder;
  final List ValueList ;
  final Function (Object?)didChange;
  const Dropdown({super.key,
  required this.title,
    required this.placeholder,
    required this.ValueList,
    required this.didChange
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
        color: TColor.textTitle,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
      SizedBox(
        height: 55,
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            onChanged: didChange,
            icon: Icon(Icons.expand_more, color: TColor.textTitle),
            hint: Text(
              placeholder,
              style: TextStyle(
                color: TColor.placeholder,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),),
            isExpanded: true,
            items: ValueList.map((obj) {
              return DropdownMenuItem(
                value: obj,
                child: Text(
                  obj.toString(),
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ) ,
        Container(
          width: double.maxFinite,
          height: 1,
          color: const Color(0xffE2E2E2),
        )
      ],
    );
  }
}



