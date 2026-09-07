import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import '../theme/app_colors.dart';
import '../models/video_source_model.dart';
import '../services/streaming_providers/vaplayer_provider.dart';
import '../services/streaming_providers/onetouchtv_provider.dart';
import '../services/streaming_providers/netmirror_provider.dart';
import '../services/streaming_providers/showbox_provider.dart';
import '../services/streaming_providers/zxcstreams_provider.dart';
import 'stream_error_dialog.dart';

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
    {'id': 'vaplayer', 'name': 'NovaStream'},
    {'id': 'zxcstreams', 'name': 'PulseStream'},
    {'id': 'showbox', 'name': 'FluxStream'},
    {'id': 'netmirror', 'name': 'LumaStream'},
    {'id': 'onetouchtv', 'name': 'OneTouchTV'},
  ];

  bool _isLoading = false;
  String? _selectedProviderId;
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel('User dismissed server selection');
    super.dispose();
  }

  Future<void> _handleProviderSelection(String providerId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _selectedProviderId = providerId;
    });

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
            cancelToken: _cancelToken,
          );
          break;
        case 'onetouchtv':
          sources = await OneTouchTVProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
            cancelToken: _cancelToken,
          );
          break;
        case 'netmirror':
          sources = await NetMirrorProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
            cancelToken: _cancelToken,
          );
          break;
        case 'showbox':
          sources = await ShowboxProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
            cancelToken: _cancelToken,
          );
          break;
        case 'zxcstreams':
          sources = await ZXCStreamsProvider().fetchStreams(
            tmdbId: widget.tmdbId,
            type: widget.type,
            season: widget.season,
            episode: widget.episode,
            originalLanguage: widget.originalLanguage,
            cancelToken: _cancelToken,
          );
          break;
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      debugPrint('Error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedProviderId = null;
      });
      if (sources.isNotEmpty) {
        Navigator.pop(context, sources.first);
      } else {
        StreamErrorDialog.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "If the selected server isn't working, try another one below.",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 28.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: _providers.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  final isSelected = _selectedProviderId == provider['id'];

                  return Material(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30.r),
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () => _handleProviderSelection(provider['id']),
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider['name'],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                            if (isSelected)
                              SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              Icon(
                                Icons.dns_rounded,
                                color: AppColors.textSecondary,
                                size: 18.sp,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
