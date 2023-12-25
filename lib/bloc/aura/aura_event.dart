part of 'aura_bloc.dart';

abstract class AuraEvent {}

class StartAuraAnimation extends AuraEvent {}

class UpdateAuraAnimation extends AuraEvent {
  final double value;

  UpdateAuraAnimation(this.value);
}
