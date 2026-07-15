import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/movie.dart';
import '../../domain/usecases/add_to_watchlist_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/is_in_watchlist_usecase.dart';
import '../../domain/usecases/remove_from_watchlist_usecase.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  final AddToWatchlistUseCase addToWatchlistUseCase;
  final RemoveFromWatchlistUseCase removeFromWatchlistUseCase;
  final GetWatchlistUseCase getWatchlistUseCase;
  final IsInWatchlistUseCase isInWatchlistUseCase;

  WatchlistCubit({
    required this.addToWatchlistUseCase,
    required this.removeFromWatchlistUseCase,
    required this.getWatchlistUseCase,
    required this.isInWatchlistUseCase,
  }) : super(WatchlistInitial());

  Future<void> loadWatchlist() async {
    emit(WatchlistLoading());
    try {
      final movies = await getWatchlistUseCase();
      emit(WatchlistLoaded(movies));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> toggleWatchlist(Movie movie) async {
    try {
      final isCurrentlyIn = await isInWatchlistUseCase(movie.id);
      if (isCurrentlyIn) {
        await removeFromWatchlistUseCase(movie.id);
        emit(const WatchlistToggleSuccess(false, 'Removed from watchlist'));
      } else {
        await addToWatchlistUseCase(movie);
        emit(const WatchlistToggleSuccess(true, 'Added to watchlist'));
      }
      loadWatchlist();
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await removeFromWatchlistUseCase(movieId);
      emit(const WatchlistToggleSuccess(false, 'Removed from watchlist'));
      loadWatchlist();
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<bool> checkIsInWatchlist(int movieId) async {
    return await isInWatchlistUseCase(movieId);
  }
}
