import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';

class MoviePlayerScreen extends StatefulWidget {
  final String id;
  final String title;
  final bool isTvShow;
  final int? seasonNumber;
  final int? episodeNumber;

  const MoviePlayerScreen({
    Key? key,
    required this.id,
    required this.title,
    this.isTvShow = false,
    this.seasonNumber,
    this.episodeNumber,
  }) : super(key: key);

  @override
  State<MoviePlayerScreen> createState() => _MoviePlayerScreenState();
}

class _MoviePlayerScreenState extends State<MoviePlayerScreen> {
  int _selectedServer = 1;

  String _getVideoUrl() {
    if (widget.isTvShow) {
      switch (_selectedServer) {
        case 1:
          return 'https://vidlink.pro/tv/${widget.id}/${widget.seasonNumber}/${widget.episodeNumber}';
        case 2:
          return 'https://vidsrc.to/embed/tv/${widget.id}/${widget.seasonNumber}/${widget.episodeNumber}';
        case 3:
          return 'https://vidsrc.xyz/embed/tv/${widget.id}/${widget.seasonNumber}/${widget.episodeNumber}';
        case 4:
          return 'https://embed.smashystream.com/play/tv/${widget.id}/${widget.seasonNumber}/${widget.episodeNumber}';
        default:
          return 'https://vidlink.pro/tv/${widget.id}/${widget.seasonNumber}/${widget.episodeNumber}';
      }
    } else {
      switch (_selectedServer) {
        case 1:
          return 'https://vidlink.pro/movie/${widget.id}';
        case 2:
          return 'https://vidsrc.to/embed/movie/${widget.id}';
        case 3:
          return 'https://vidsrc.xyz/embed/movie/${widget.id}';
        case 4:
          return 'https://embed.smashystream.com/play/movie/${widget.id}';
        default:
          return 'https://vidlink.pro/movie/${widget.id}';
      }
    }
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontSize: 18.sp),
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.settings, color: Colors.white),
              onSelected: (int serverIndex) {
                setState(() {
                  _selectedServer = serverIndex;
                });
              },
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              itemBuilder: (context) => List.generate(4, (index) {
                final serverNum = index + 1;
                return PopupMenuItem(
                  value: serverNum,
                  child: Container(
                    width: 120.w,
                    child: Row(
                      children: [
                        Icon(
                          Icons.dns_rounded,
                          size: 18.r,
                          color: _selectedServer == serverNum
                              ? AppColors.primary
                              : Colors.white70,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Server $serverNum',
                          style: TextStyle(
                            color: _selectedServer == serverNum
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: _selectedServer == serverNum
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomVideoPlayerWidget(
            key: ValueKey(_getVideoUrl()),
            videoUrl: _getVideoUrl(),
          ),
        ),
      ),
    );
  }
}

class CustomVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const CustomVideoPlayerWidget({Key? key, required this.videoUrl})
    : super(key: key);

  @override
  State<CustomVideoPlayerWidget> createState() =>
      _CustomVideoPlayerWidgetState();
}

class _CustomVideoPlayerWidgetState extends State<CustomVideoPlayerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return _shouldAllowNavigation(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  bool _shouldAllowNavigation(String url) {
    final lowerUrl = url.toLowerCase();

    // Block keywords associated with ads and overlays
    const blockedKeywords = [
      'ad',
      'pop',
      'click',
      'doubleclick',
      'banner',
      'ads',
      'fembed',
      'upstream',
      'advertisement',
      'adservice',
      'googleads',
      'doubleclick.net',
    ];

    for (final keyword in blockedKeywords) {
      if (lowerUrl.contains(keyword)) {
        return false;
      }
    }

    // Whitelist trusted domains
    const allowedDomains = [
      'vidlink.pro',
      'vidsrc.to',
      'vidsrc.xyz',
      'smashystream.com',
      'embed.smashystream.com',
    ];
    final isFromAllowedDomain = allowedDomains.any(
      (domain) => lowerUrl.contains(domain),
    );

    final isMediaScheme =
        lowerUrl.startsWith('data:') ||
        lowerUrl.startsWith('blob:') ||
        lowerUrl.startsWith('about:');

    return isFromAllowedDomain || isMediaScheme;
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}
