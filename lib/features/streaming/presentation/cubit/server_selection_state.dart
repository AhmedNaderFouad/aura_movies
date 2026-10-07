import 'package:equatable/equatable.dart';
import '../../../../core/models/video_source_model.dart';

abstract class ServerSelectionState extends Equatable {
  const ServerSelectionState();

  @override
  List<Object?> get props => [];
}

class ServerSelectionInitial extends ServerSelectionState {
  const ServerSelectionInitial();
}

class ServerSelectionLoading extends ServerSelectionState {
  final String providerId;

  const ServerSelectionLoading(this.providerId);

  @override
  List<Object?> get props => [providerId];
}

class ServerSelectionSuccess extends ServerSelectionState {
  final VideoSource selectedSource;

  const ServerSelectionSuccess(this.selectedSource);

  @override
  List<Object?> get props => [selectedSource];
}

class ServerSelectionError extends ServerSelectionState {
  final String message;

  const ServerSelectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerSelectionEmpty extends ServerSelectionState {
  const ServerSelectionEmpty();
}
