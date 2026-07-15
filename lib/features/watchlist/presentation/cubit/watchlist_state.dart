import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/movie.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<Movie> movies;

  const WatchlistLoaded(this.movies);

  @override
  List<Object?> get props => [movies];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WatchlistToggleSuccess extends WatchlistState {
  final bool isInWatchlist;
  final String message;

  const WatchlistToggleSuccess(this.isInWatchlist, this.message);

  @override
  List<Object?> get props => [isInWatchlist, message];
}
