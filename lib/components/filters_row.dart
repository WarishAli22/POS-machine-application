import 'package:flutter/material.dart';
import 'package:my_pos/components/buttons.dart';
import 'package:my_pos/components/dropdown_stub.dart';

class FiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownStub(
          label: 'All Items',
          onTap: () {}, // hook up real filter later
        ),
        const Spacer(),
        SquareIconButton(icon: Icons.qr_code_2_outlined, onTap: () {}),
        const SizedBox(width: 8),
        SquareIconButton(icon: Icons.search, onTap: () {}),
      ],
    );
  }
}