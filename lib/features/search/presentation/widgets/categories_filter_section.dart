import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/search_constants.dart';

class CategoriesFilterSection extends StatelessWidget {
  final String selectedMediaType;
  final int? selectedGenreId;
  final String? selectedLanguage;
  final int? selectedYear;
  final int? selectedCompanyId;
  final Function(String) onMediaTypeChanged;
  final Function(int?) onGenreChanged;
  final Function(String?) onLanguageChanged;
  final Function(int?) onYearChanged;
  final Function(int?) onCompanyChanged;

  const CategoriesFilterSection({
    super.key,
    required this.selectedMediaType,
    required this.selectedGenreId,
    required this.selectedLanguage,
    required this.selectedYear,
    required this.selectedCompanyId,
    required this.onMediaTypeChanged,
    required this.onGenreChanged,
    required this.onLanguageChanged,
    required this.onYearChanged,
    required this.onCompanyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Media Type',
          child: _buildHorizontalChipList<String>(
            items: const {
              'all': 'All Media',
              'movie': 'Movies',
              'tv': 'TV Shows',
            },
            selectedValue: selectedMediaType,
            onSelected: onMediaTypeChanged,
          ),
        ),
        _buildFilterSection(
          title: 'Genres',
          child: _buildHorizontalChipList<int?>(
            items: {
              null: 'All Genres',
              if (selectedMediaType == 'movie' || selectedMediaType == 'all')
                ...SearchConstants.movieGenres,
              if (selectedMediaType == 'tv') ...SearchConstants.tvGenres,
            },
            selectedValue: selectedGenreId,
            onSelected: onGenreChanged,
          ),
        ),
        _buildFilterSection(
          title: 'Languages',
          child: _buildHorizontalChipList<String?>(
            items: {null: 'All Languages', ...SearchConstants.languages},
            selectedValue: selectedLanguage,
            onSelected: onLanguageChanged,
          ),
        ),
        _buildFilterSection(
          title: 'Release Year',
          child: _buildHorizontalChipList<int?>(
            items: {
              null: 'All Years',
              for (var year in SearchConstants.years) year: year.toString(),
            },
            selectedValue: selectedYear,
            onSelected: onYearChanged,
          ),
        ),
        _buildFilterSection(
          title: 'Production Companies / Studios',
          child: _buildHorizontalChipList<int?>(
            items: {
              null: 'All Studios',
              ...SearchConstants.productionCompanies,
              ...SearchConstants.streamingPlatforms,
            },
            selectedValue: selectedCompanyId,
            onSelected: onCompanyChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  Widget _buildHorizontalChipList<T>({
    required Map<T, String> items,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    final keys = items.keys.toList();
    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: keys.length,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemBuilder: (context, index) {
          final key = keys[index];
          final label = items[key]!;
          final isSelected = selectedValue == key;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: _buildFilterChip(
              label: label,
              isSelected: isSelected,
              onTap: () => onSelected(key),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
