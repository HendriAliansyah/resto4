import 'package:flutter/material.dart';
import 'package:resto2/providers/staff_filter_provider.dart'; // We can reuse the SortOrder enum

class SortOrderToggle extends StatelessWidget {
  final SortOrder currentOrder;
  final ValueChanged<SortOrder> onOrderChanged;

  const SortOrderToggle({
    super.key,
    required this.currentOrder,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        currentOrder == SortOrder.asc,
        currentOrder == SortOrder.desc,
      ],
      onPressed: (index) {
        final newOrder = index == 0 ? SortOrder.asc : SortOrder.desc;
        onOrderChanged(newOrder);
      },
      children: const [Icon(Icons.arrow_upward), Icon(Icons.arrow_downward)],
    );
  }
}
