part of 'step_bloc.dart';

@immutable
abstract class ReqSpecStepState {}

class InitialReqSpecStepState extends ReqSpecStepState {}

class FlowsLoadedState extends ReqSpecStepState {
  final List<Flow> flows;

  FlowsLoadedState(this.flows);
}

class FlowsNumberedState extends ReqSpecStepState {
  final List<Flow> flows;

  FlowsNumberedState(this.flows);
}

class ErrorReqSpecStepState extends ReqSpecStepState {
  final String message;

  ErrorReqSpecStepState(this.message);
}
