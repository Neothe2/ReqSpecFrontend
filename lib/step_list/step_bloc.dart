import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

part 'step_event.dart';
part 'step_state.dart';

class StepBloc extends Bloc<StepEvent, ReqSpecStepState> {
  StepBloc() : super(InitialReqSpecStepState()) {
    on<LoadFlowsEvent>(_onLoadFlowsEvent);
    on<NumberStepsEvent>(_onNumberStepsEvent);
  }

  Future<void> _onLoadFlowsEvent(
      LoadFlowsEvent event, Emitter<ReqSpecStepState> emit) async {
    try {
      List<Flow> flows = await fetchFlows(); // Fetch the flows
      emit(FlowsLoadedState(flows)); // Emit loaded state
      add(NumberStepsEvent(flows)); // Dispatch NumberStepsEvent
    } catch (e) {
      emit(ErrorReqSpecStepState(
          e.toString())); // Emit error state if something goes wrong
    }
  }

  void _onNumberStepsEvent(
      NumberStepsEvent event, Emitter<ReqSpecStepState> emit) {
    numberSteps(event.flows); // Number the steps
    emit(FlowsNumberedState(event.flows)); // Emit numbered state
  }

  Future<List<Flow>> fetchFlows() async {
    final uri = Uri.parse('http://10.0.2.2:8000/reqspec/flows/');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return parseFlowsFromJson(response.body);
    } else {
      print(response.body);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load flows');
    }
  }

  void numberSteps(List<Flow> flows) {
    for (var flow in flows) {
      _numberStepsRecursive(flow.steps);
    }
  }

  void _numberStepsRecursive(List<ReqStep> steps, [String prefix = '']) {
    for (int i = 0; i < steps.length; i++) {
      var currentStep = steps[i];
      currentStep.number = prefix.isEmpty ? '${i + 1}' : '$prefix.${i + 1}';

      if (currentStep.children.isNotEmpty) {
        _numberStepsRecursive(currentStep.children, currentStep.number);
      }
    }
  }
}
