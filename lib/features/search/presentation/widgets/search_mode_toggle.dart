import 'package:flutter/material.dart';
import '../../../../core/widgets/app_sliding_toggle_widget.dart';
import '../utils/search_constants.dart';

class SearchModeToggle extends StatelessWidget {
  final SearchMode currentMode;
  final Function(SearchMode) onModeChanged;

  const SearchModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSlidingToggleWidget(
      selectedIndex: currentMode == SearchMode.keyword ? 0 : 1,
      options: const ['Keyword', 'By Categories'],
      onSelectedIndexChanged: (index) {
        onModeChanged(index == 0 ? SearchMode.keyword : SearchMode.categories);
      },
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
