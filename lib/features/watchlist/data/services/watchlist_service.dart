import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../repositories/watchlist_repository_impl.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../../domain/usecases/add_to_watchlist_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/is_in_watchlist_usecase.dart';
import '../../domain/usecases/remove_from_watchlist_usecase.dart';

class WatchlistService {
  static late WatchlistRepository _watchlistRepository;
  static late AddToWatchlistUseCase _addToWatchlistUseCase;
  static late RemoveFromWatchlistUseCase _removeFromWatchlistUseCase;
  static late GetWatchlistUseCase _getWatchlistUseCase;
  static late IsInWatchlistUseCase _isInWatchlistUseCase;

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final localDataSource = WatchlistLocalDataSourceImpl(
      sharedPreferences: preferences,
    );
    _watchlistRepository = WatchlistRepositoryImpl(
      localDataSource: localDataSource,
    );

    _addToWatchlistUseCase = AddToWatchlistUseCase(_watchlistRepository);
    _removeFromWatchlistUseCase = RemoveFromWatchlistUseCase(
      _watchlistRepository,
    );
    _getWatchlistUseCase = GetWatchlistUseCase(_watchlistRepository);
    _isInWatchlistUseCase = IsInWatchlistUseCase(_watchlistRepository);
  }

  static WatchlistRepository get repository => _watchlistRepository;
  static AddToWatchlistUseCase get addToWatchlistUseCase =>
      _addToWatchlistUseCase;
  static RemoveFromWatchlistUseCase get removeFromWatchlistUseCase =>
      _removeFromWatchlistUseCase;
  static GetWatchlistUseCase get getWatchlistUseCase => _getWatchlistUseCase;
  static IsInWatchlistUseCase get isInWatchlistUseCase => _isInWatchlistUseCase;
}
