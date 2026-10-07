import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import '../theme/app_colors.dart';
import '../di/service_locator.dart';
import '../../features/streaming/presentation/cubit/server_selection_cubit.dart';
import '../../features/streaming/presentation/cubit/server_selection_state.dart';
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
  static const List<Map<String, String>> _providers = [
    {'id': 'vaplayer', 'name': 'NovaStream'},
    {'id': 'vidlink', 'name': 'PulseStream'},
    {'id': 'showbox', 'name': 'FluxStream'},
    {'id': 'netmirror', 'name': 'LumaStream'},
    {'id': 'onetouchtv', 'name': 'HuntStream'},
  ];

  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel('User dismissed server selection');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ServerSelectionCubit>(),
      child: BlocConsumer<ServerSelectionCubit, ServerSelectionState>(
        listener: (context, state) {
          if (state is ServerSelectionSuccess) {
            Navigator.pop(context, state.selectedSource);
          } else if (state is ServerSelectionEmpty ||
              state is ServerSelectionError) {
            StreamErrorDialog.show(context);
          }
        },
        builder: (context, state) {
          final String? selectedProviderId =
              state is ServerSelectionLoading ? state.providerId : null;
          final bool isLoading = state is ServerSelectionLoading;

          return Dialog(
            backgroundColor: AppColors.surface,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.r),
            ),
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
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final provider = _providers[index];
                        final String providerId = provider['id']!;
                        final String providerName = provider['name']!;
                        final isSelected = selectedProviderId == providerId;

                        return Material(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30.r),
                          child: InkWell(
                            onTap: isLoading
                                ? null
                                : () {
                                    context
                                        .read<ServerSelectionCubit>()
                                        .selectServer(
                                          providerId: providerId,
                                          tmdbId: widget.tmdbId,
                                          type: widget.type,
                                          season: widget.season,
                                          episode: widget.episode,
                                          originalLanguage:
                                              widget.originalLanguage,
                                          cancelToken: _cancelToken,
                                        );
                                  },
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
                                      providerName,
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
        },
      ),
    );
  }
}
