import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../../domain/usecases/add_to_watchlist_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/is_in_watchlist_usecase.dart';
import '../../domain/usecases/remove_from_watchlist_usecase.dart';

class WatchlistService {
  static Future<void> initialize() async {}

  static WatchlistRepository get repository => sl<WatchlistRepository>();
  static AddToWatchlistUseCase get addToWatchlistUseCase =>
      sl<AddToWatchlistUseCase>();
  static RemoveFromWatchlistUseCase get removeFromWatchlistUseCase =>
      sl<RemoveFromWatchlistUseCase>();
  static GetWatchlistUseCase get getWatchlistUseCase =>
      sl<GetWatchlistUseCase>();
  static IsInWatchlistUseCase get isInWatchlistUseCase =>
      sl<IsInWatchlistUseCase>();
}
