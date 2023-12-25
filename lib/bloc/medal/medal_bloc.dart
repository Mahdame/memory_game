import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'medal_event.dart';
part 'medal_state.dart';

class MedalBloc extends Bloc<MedalEvent, MedalState> {
  Timer? _timer;

  MedalBloc() : super(MedalState(0.0)) {
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      add(UpdateShine(timer.tick / 60.0 % 2.0 - 0.5)); // Loop from -0.5 to 1.5
    });

    on<UpdateShine>((event, emit) => emit(MedalState(event.shinePosition)));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
