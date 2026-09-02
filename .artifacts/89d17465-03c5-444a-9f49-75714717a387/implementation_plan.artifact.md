# Refactor Media Streaming Providers Module

Refactor the streaming providers to a modular, isolated architecture without shared logic. Implement 6 new providers with specific API specifications and add a Server Selection UI.

## User Review Required

> [!IMPORTANT]
> - **Isolation Policy**: Each provider will have zero shared code. This means duplicated logic for HTTP requests and parsing is intentional as per instructions.
> - **Subtitles**: Subtitles from provider APIs will be ignored. We will continue using `SubtitleService`.
> - **Language Matching**: Isolated logic in each provider will prioritize streams matching the media's `originalLanguage`.

## Proposed Changes

### [Cleanup]

#### [DELETE] [video_extractor_service.dart](file:///C:/aura_movies/lib/core/services/video_extractor_service.dart)

---

### [Streaming Providers]

#### [NEW] [videasy_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/videasy_provider.dart)
#### [NEW] [vaplayer_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/vaplayer_provider.dart)
#### [NEW] [castletv_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/castletv_provider.dart)
#### [NEW] [hdghartv_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/hdghartv_provider.dart)
#### [NEW] [onetouchtv_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/onetouchtv_provider.dart)
#### [NEW] [netmirror_provider.dart](file:///C:/aura_movies/lib/core/services/streaming_providers/netmirror_provider.dart)

---

### [UI Components]

#### [NEW] [server_selection_bottom_sheet.dart](file:///C:/aura_movies/lib/core/widgets/server_selection_bottom_sheet.dart)
#### [MODIFY] [watch_now_handler.dart](file:///C:/aura_movies/lib/core/utils/watch_now_handler.dart)
- Update to trigger `ServerSelectionBottomSheet` and use the new providers.

---

### [Core Models]

#### [MODIFY] [video_source_model.dart](file:///C:/aura_movies/lib/core/models/video_source_model.dart)
- Ensure it accommodates all provider-specific data (e.g., specific headers).

## Verification Plan

### Automated Tests
- I will verify each provider's parsing logic by checking if it correctly maps the sample payloads.

### Manual Verification
- Verify the Server Selection UI matches the app's `ThemeData`.
- Test language matching logic by providing different `originalLanguage` values and checking the stream order.
- Ensure no shared imports or utilities are used between provider files.
