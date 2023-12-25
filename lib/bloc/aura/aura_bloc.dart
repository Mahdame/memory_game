import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'aura_event.dart';
part 'aura_state.dart';

class AuraBloc extends Bloc<AuraEvent, AuraState> {
  Timer? _timer;

  AuraBloc() : super(AuraState(0.0)) {
    on<UpdateAuraAnimation>((event, emit) {
      emit(AuraState(event.value));
    });
  }

  void startAnimation() {
    const period = Duration(milliseconds: 25);
    double animationValue = 0.0;
    const double step = 0.01; // Increment/Decrement step
    bool increasing = true;

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(period, (timer) {
      if (increasing) {
        animationValue += step;
        if (animationValue >= 1.0) {
          animationValue = 1.0; // Cap the value to 1.0
          increasing = false;
        }
      } else {
        animationValue -= step;
        if (animationValue <= 0.0) {
          animationValue = 0.0; // Cap the value to 0.0
          increasing = true;
        }
      }

      // Emit new animation state
      add(UpdateAuraAnimation(animationValue));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
