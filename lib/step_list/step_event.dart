part of 'step_bloc.dart';

@immutable
abstract class StepEvent {}

class LoadFlowsEvent extends StepEvent {}

class NumberStepsEvent extends StepEvent {
  final List<Flow> flows;

  NumberStepsEvent(this.flows);
}

class SelectStepEvent extends StepEvent {
  final int stepId;
  SelectStepEvent(this.stepId);
}
