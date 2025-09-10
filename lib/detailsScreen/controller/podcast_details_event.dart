// lib/bloc/player_event.dart
import 'package:equatable/equatable.dart';

import '../model/episode_model.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetEpisode extends PlayerEvent {
  final Episode episode;
  SetEpisode(this.episode);

  @override
  List<Object?> get props => [episode];
}
