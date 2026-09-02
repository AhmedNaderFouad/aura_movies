import 'package:flutter/material.dart';
import '../models/video_source_model.dart';

class QualitySelectionBottomSheet extends StatelessWidget {
  final List<VideoQuality> availableQualities;
  final VideoQuality? currentQuality;
  final ValueChanged<VideoQuality> onQualitySelected;

  const QualitySelectionBottomSheet({
    super.key,
    required this.availableQualities,
    required this.currentQuality,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableQualities.length,
                  itemBuilder: (context, index) {
                    final quality = availableQualities[index];
                    final isSelected = currentQuality == quality;

                    // Format "Auto (Recommended)" as "Auto"
                    final String displayLabel = quality.isAuto
                        ? 'Auto'
                        : quality.label;

                    return ListTile(
                      dense: true,
                      onTap: () {
                        onQualitySelected(quality);
                        Navigator.pop(context);
                      },
                      leading: Icon(
                        Icons.check,
                        size: 18,
                        color: isSelected ? Colors.blue : Colors.transparent,
                      ),
                      title: Text(
                        displayLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
