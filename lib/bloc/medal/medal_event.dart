part of 'medal_bloc.dart';

abstract class MedalEvent {}

class UpdateShine extends MedalEvent {
  final double shinePosition;

  UpdateShine(this.shinePosition);
}
