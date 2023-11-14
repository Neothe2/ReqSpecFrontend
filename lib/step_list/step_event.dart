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

// Event triggered when the user wants to edit a step
class EditStepEvent extends StepEvent {
  final int stepId;
  EditStepEvent(this.stepId);
}

// Event triggered when the user submits their changes to a step's text
class UpdateStepTextEvent extends StepEvent {
  final int stepId;
  final String newText;
  UpdateStepTextEvent(this.stepId, this.newText);
}
