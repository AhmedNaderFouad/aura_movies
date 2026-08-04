enum SubtitleServer { wyzie, openSubtitles }

class SubtitleModel {
  final String? language;
  final String? url;
  final SubtitleServer server;
  final String? fileId; // Specifically for OpenSubtitles download

  SubtitleModel({
    this.language,
    this.url,
    this.server = SubtitleServer.wyzie,
    this.fileId,
  });

  factory SubtitleModel.fromJson(Map<String, dynamic> json) {
    return SubtitleModel(
      language:
          json['display'] as String? ??
          json['label'] as String? ??
          json['language'] as String? ??
          json['lang'] as String?,
      url: json['url'] as String?,
      server: _parseServer(json['server']),
      fileId: json['file_id']?.toString(),
    );
  }

  static SubtitleServer _parseServer(dynamic server) {
    if (server == 'openSubtitles' || server == 1) {
      return SubtitleServer.openSubtitles;
    }
    return SubtitleServer.wyzie;
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'url': url,
      'server': server.name,
      'file_id': fileId,
    };
  }
}
