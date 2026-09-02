import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../models/video_source_model.dart';
import '../services/streaming_providers/vaplayer_provider.dart';
import '../services/streaming_providers/hdghartv_provider.dart';
import '../services/streaming_providers/onetouchtv_provider.dart';
import '../services/streaming_providers/netmirror_provider.dart';
import '../services/streaming_providers/showbox_provider.dart';

class ServerSelectionBottomSheet extends StatefulWidget {
  final String tmdbId;
  final String type;
  final int? season;
  final int? episode;
  final String? originalLanguage;

  const ServerSelectionBottomSheet({
    super.key,
    required this.tmdbId,
    required this.type,
    this.season,
    this.episode,
    this.originalLanguage,
  });

  @override
  State<ServerSelectionBottomSheet> createState() =>
      _ServerSelectionBottomSheetState();
}

class _ServerSelectionBottomSheetState
    extends State<ServerSelectionBottomSheet> {
  final List<Map<String, dynamic>> _providers = [
    {
      'id': 'vaplayer',
      'name': 'VaPlayer ok ',
      'icon': Icons.play_circle_filled_rounded,
    },
    {'id': 'hdghartv', 'name': 'HDGharTV', 'icon': Icons.tv_rounded},
    {
      'id': 'onetouchtv',
      'name': 'OneTouchTV ok',
      'icon': Icons.touch_app_rounded,
    },
    {'id': 'netmirror', 'name': 'NetMirror ok', 'icon': Icons.layers_rounded},
    {'id': 'showbox', 'name': 'Showbox', 'icon': Icons.slideshow_rounded},
  ];

  bool _isLoading = false;

  Future<void> _handleProviderSelection(String providerId) async {
    setState(() => _isLoading = true);

    List<VideoSource> sources = [];

    try {
      switch (providerId) {
        case 'vaplayer':
          sources = await VaPlayerProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
          );
          break;
        case 'hdghartv':
          sources = await HDGharTVProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
          );
          break;
        case 'onetouchtv':
          sources = await OneTouchTVProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
          );
          break;
        case 'netmirror':
          sources = await NetMirrorProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
          );
          break;
        case 'showbox':
          sources = await ShowboxProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
          );
          break;
      }
    } catch (e) {
      debugPrint('Error fetching from $providerId: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (sources.isNotEmpty) {
        // Return the first matching source (sorted by language matching logic in providers)
        Navigator.pop(context, sources.first);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No streams found for $providerId'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Streaming Server',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose a provider to start watching',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _providers.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () => _handleProviderSelection(provider['id']),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        color: AppColors.surface.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              provider['icon'],
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              provider['name'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
