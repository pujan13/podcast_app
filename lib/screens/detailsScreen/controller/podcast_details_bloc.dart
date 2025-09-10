import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast_app/screens/detailsScreen/controller/podcast_details_event.dart';
import 'package:podcast_app/screens/detailsScreen/controller/podcast_details_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState()) {
    on<SetEpisode>((event, emit) {
      emit(state.copyWith(currentEpisode: event.episode));
    });
  }
}
