import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';


class CustomCategory extends StatefulWidget {
  const CustomCategory({Key? key}) : super(key: key);

  @override
  State<CustomCategory> createState() => _CustomCategoryState();
}

class _CustomCategoryState extends State<CustomCategory> {
  // Danh mục du lịch
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'Tất cả',
      'icon': Icons.all_inclusive,
      'label': 'Tất cả',
      'gradient': [AppColors.primary, AppColors.green],
    },
    {
      'id': 'Biển',
      'icon': Icons.beach_access,
      'label': 'Biển',
      'gradient': [AppColors.primary, AppColors.green],
    },

    {
      'id': 'Văn hóa',
      'icon': Icons.temple_buddhist,
      'label': 'Văn hóa',
      'gradient': [AppColors.primary, AppColors.green],
    },
    {
      'id': 'Thiên nhiên',
      'icon': Icons.landscape,
      'label': 'Thiên nhiên',
      'gradient': [AppColors.primary, AppColors.green],
    },
    {
      'id': 'Gải trí',
      'icon': Icons.fitness_center,
      'label': 'Gải trí',
      'gradient': [AppColors.primary, AppColors.green],
    },
    {
      'id': 'Thể thao',
      'icon': Icons.sports_gymnastics,
      'label': 'Thể thao',
      'gradient': [AppColors.primary, AppColors.green],
    },
  ];

  String _selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['id'];
                });

                //Nếu có DestinationBloc, kích hoạt filter
                if (category['id'] == 'Tất cả') {
                  context.read<DestinationBloc>().add(LoadAllDestinations());
                } else {
                  context
                      .read<DestinationBloc>()
                      .add(FilterDestinationsByCategory(category['id']));
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 85,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: category['gradient'],
                  )
                      : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? (category['gradient'][0] as Color).withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 15 : 8,
                      offset: Offset(0, isSelected ? 6 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category['icon'],
                        color:
                        isSelected ? Colors.white : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                        isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
