import 'package:flutter/material.dart';
import 'search_result_card.dart';

class SearchResultsList extends StatelessWidget {
  final List<dynamic> results;
  final bool showMediaType;
  final Widget? bottomWidget;

  const SearchResultsList({
    super.key,
    required this.results,
    this.showMediaType = false,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...results.map(
          (item) => SearchResultCard(item: item, showMediaType: showMediaType),
        ),
        if (bottomWidget != null) ...[bottomWidget!],
      ],
    );
  }
}
