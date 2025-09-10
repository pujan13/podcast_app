// lib/bloc/player_state.dart
import 'package:equatable/equatable.dart';
import '../model/episode_model.dart';

class PlayerState extends Equatable {
  final Episode? currentEpisode;

  const PlayerState({this.currentEpisode});

  PlayerState copyWith({Episode? currentEpisode}) {
    return PlayerState(
      currentEpisode: currentEpisode ?? this.currentEpisode,
    );
  }

  @override
  List<Object?> get props => [currentEpisode ?? ""];
}
