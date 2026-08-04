import 'package:flutter/material.dart';
import '../../data/models/subtitle_model.dart';

class SubtitlesBottomSheet extends StatefulWidget {
  final List<SubtitleModel> wyzieSubtitles;
  final List<SubtitleModel> openSubtitles;
  final SubtitleModel? currentSubtitle;
  final Function(SubtitleModel?) onSubtitleSelected;
  final bool isLoading;

  const SubtitlesBottomSheet({
    super.key,
    required this.wyzieSubtitles,
    required this.openSubtitles,
    required this.currentSubtitle,
    required this.onSubtitleSelected,
    this.isLoading = false,
  });

  @override
  State<SubtitlesBottomSheet> createState() => _SubtitlesBottomSheetState();
}

class _SubtitlesBottomSheetState extends State<SubtitlesBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _server1Controller;
  late ScrollController _server2Controller;

  @override
  void initState() {
    super.initState();
    final int initialIndex =
        (widget.currentSubtitle?.server == SubtitleServer.openSubtitles)
        ? 1
        : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _server1Controller = ScrollController();
    _server2Controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _server1Controller.dispose();
    _server2Controller.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (widget.currentSubtitle == null) return;

    final bool isOpenSub =
        widget.currentSubtitle?.server == SubtitleServer.openSubtitles;
    final List<SubtitleModel> subtitles = isOpenSub
        ? widget.openSubtitles
        : widget.wyzieSubtitles;
    final ScrollController controller = isOpenSub
        ? _server2Controller
        : _server1Controller;

    final deduplicated = _getDeduplicatedSubtitles(subtitles);
    int selectedIndex = -1;

    for (int i = 0; i < deduplicated.length; i++) {
      final s = deduplicated[i];
      final bool isMatch =
          (s.url != null && s.url == widget.currentSubtitle!.url) ||
          (s.fileId != null && s.fileId == widget.currentSubtitle!.fileId);

      if (isMatch) {
        selectedIndex = i + 2; // +1 for 'Off', +1 for Header
        break;
      }
    }

    if (selectedIndex != -1 && controller.hasClients) {
      final double targetOffset = selectedIndex * 48.0;
      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<SubtitleModel> _getDeduplicatedSubtitles(List<SubtitleModel> subtitles) {
    final List<SubtitleModel> deduplicatedSubtitles = [];
    final Map<String, int> languageCounts = {};

    for (var sub in subtitles) {
      final lang = sub.language ?? 'Unknown';
      languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;

      if (languageCounts[lang]! > 1) {
        deduplicatedSubtitles.add(
          SubtitleModel(
            language: '$lang ${languageCounts[lang]}',
            url: sub.url,
            server: sub.server,
            fileId: sub.fileId,
          ),
        );
      } else {
        deduplicatedSubtitles.add(sub);
      }
    }
    return deduplicatedSubtitles;
  }

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
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Subtitles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.white38,
                tabs: const [
                  Tab(text: 'Server 1 '),
                  Tab(text: 'Server 2 '),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                )
              else
                Flexible(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSubtitleList(
                        widget.wyzieSubtitles,
                        SubtitleServer.wyzie,
                        _server1Controller,
                      ),
                      _buildSubtitleList(
                        widget.openSubtitles,
                        SubtitleServer.openSubtitles,
                        _server2Controller,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleList(
    List<SubtitleModel> subtitles,
    SubtitleServer server,
    ScrollController controller,
  ) {
    final List<SubtitleModel> deduplicatedSubtitles = _getDeduplicatedSubtitles(
      subtitles,
    );

    return ListView(
      controller: controller,
      shrinkWrap: true,
      children: [
        _buildSubtitleTile(context, 'Off', null, server),
        if (deduplicatedSubtitles.isNotEmpty) ...[
          _buildSectionHeader('AVAILABLE SUBTITLES'),
          ...deduplicatedSubtitles.map((s) {
            return _buildSubtitleTile(
              context,
              s.language ?? 'Unknown',
              s,
              server,
            );
          }),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No subtitles found for this server',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
      ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSubtitleTile(
    BuildContext context,
    String title,
    SubtitleModel? subtitle,
    SubtitleServer tabServer,
  ) {
    bool isSelected = false;

    if (subtitle == null) {
      // Logic for 'Off' tile:
      // It's selected if global state is null OR if active subtitle is from a different server
      isSelected =
          widget.currentSubtitle == null ||
          widget.currentSubtitle!.server != tabServer;
    } else {
      // Logic for track tile:
      // Selected only if it matches current global state AND server matches tab
      isSelected =
          widget.currentSubtitle != null &&
          widget.currentSubtitle!.server == tabServer &&
          ((subtitle.url != null &&
                  subtitle.url == widget.currentSubtitle!.url) ||
              (subtitle.fileId != null &&
                  subtitle.fileId == widget.currentSubtitle!.fileId));
    }

    return ListTile(
      dense: true,
      onTap: () {
        widget.onSubtitleSelected(subtitle);
        Navigator.pop(context);
      },
      leading: Icon(
        Icons.check,
        size: 18,
        color: isSelected ? Colors.blue : Colors.transparent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
