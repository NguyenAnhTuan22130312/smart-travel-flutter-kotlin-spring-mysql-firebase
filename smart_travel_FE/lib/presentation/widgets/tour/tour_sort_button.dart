import 'package:flutter/material.dart';

class TourSortButton extends StatelessWidget {
  final String? sortValue;
  final Function(String) onSelected;

  const TourSortButton({
    super.key,
    required this.sortValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) => onSelected(value),
      itemBuilder: (context) => [
        _item("popular_desc", "Phổ biến nhất"),
        _item("price_asc", "Giá tăng dần"),
        _item("price_desc", "Giá giảm dần"),
        _item("rating_desc", "Rating cao nhất"),
        _item("newest", "Mới nhất"),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort, color: Colors.blue),
            const SizedBox(width: 6),
            Text(_label(sortValue)),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(String value, String label) {
    final selected = sortValue == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.blue : Colors.black,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check, color: Colors.blue, size: 18),
        ],
      ),
    );
  }

  String _label(String? sort) {
    switch (sort) {
      case "price_asc": return "Giá tăng dần";
      case "price_desc": return "Giá giảm dần";
      case "rating_desc": return "Rating cao nhất";
      case "newest": return "Mới nhất";
      default: return "Phổ biến nhất";
    }
  }
}
