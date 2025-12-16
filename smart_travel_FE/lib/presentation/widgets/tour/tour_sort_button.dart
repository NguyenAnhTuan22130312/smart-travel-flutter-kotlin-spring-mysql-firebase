import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Demo Sort Button")),
        body: const Center(child: TourSortDemo()),
      ),
    );
  }
}

class TourSortDemo extends StatefulWidget {
  const TourSortDemo({super.key});

  @override
  State<TourSortDemo> createState() => _TourSortDemoState();
}

class _TourSortDemoState extends State<TourSortDemo> {
  String _selectedSort = "popular_desc"; // mặc định

  @override
  Widget build(BuildContext context) {
    return TourSortButton(
      sortValue: _selectedSort,
      onSelected: (value) {
        setState(() {
          _selectedSort = value; // cập nhật state
        });
      },
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 18, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              _label(sortValue),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
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
      case "price_asc":
        return "Giá tăng dần";
      case "price_desc":
        return "Giá giảm dần";
      case "rating_desc":
        return "Rating cao nhất";
      case "newest":
        return "Mới nhất";
      default:
        return "Phổ biến nhất";
    }
  }
}
