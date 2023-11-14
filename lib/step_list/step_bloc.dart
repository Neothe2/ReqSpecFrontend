import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

part 'step_event.dart';
part 'step_state.dart';

class StepBloc extends Bloc<StepEvent, ReqSpecStepState> {
  List<Flow> flows = [];

  StepBloc() : super(InitialReqSpecStepState()) {
    on<LoadFlowsEvent>(_onLoadFlowsEvent);
    on<NumberStepsEvent>(_onNumberStepsEvent);
    on<SelectStepEvent>(_onStepSelectedEvent);
    on<EditStepEvent>(_onEditStepEvent);
    on<UpdateStepTextEvent>(_onUpdateStepTextEvent);
  }

  // Handler for when a step is selected for editing
  void _onEditStepEvent(
    EditStepEvent event,
    Emitter<ReqSpecStepState> emit,
  ) {
    // You may need to fetch the current state of the flows here, if necessary.
    // For now, let's assume you can access them directly.
    emit(EditingStepState(flows, event.stepId));
  }

  // Handler for when the edited step text is submitted
  void _onUpdateStepTextEvent(
    UpdateStepTextEvent event,
    Emitter<ReqSpecStepState> emit,
  ) async {
    try {
      // Here you would implement the logic to update the step's text.
      // For now, let's assume there's a method that does this.
      await _updateStepText(event.stepId, event.newText);

      // After updating, you would typically want to refresh the list of flows.
      // Let's emit the FlowsLoadedState with the updated flows.
      emit(StepSelectedState(flows, event.stepId));
    } catch (error) {
      // If something goes wrong, emit an error state.
      emit(ErrorReqSpecStepState(error.toString()));
    }
  }

  // Placeholder method for updating the text of a step
  Future<void> _updateStepText(int stepId, String newText) async {
    // Find the step by ID and update its text.
    // This is where you'd put your logic for updating the step text.
    // For demonstration, let's just print the new text.
    http.patch(Uri.parse('http://10.0.2.2:8000/reqspec/steps/$stepId/'),
        body: {"text": newText});
    flows = await fetchFlows();
    numberSteps();
    print('Updated step $stepId with text: $newText');
  }

  Future<void> _onStepSelectedEvent(
    SelectStepEvent event,
    Emitter<ReqSpecStepState> emit,
  ) async {
    try {
      emit(StepSelectedState(flows, event.stepId)); // Emit loaded state
    } catch (e) {
      emit(ErrorReqSpecStepState(
          e.toString())); // Emit error state if something goes wrong
    }
  }

  Future<void> _onLoadFlowsEvent(
    LoadFlowsEvent event,
    Emitter<ReqSpecStepState> emit,
  ) async {
    try {
      flows = await fetchFlows(); // Fetch the flows
      emit(FlowsLoadedState(flows)); // Emit loaded state
      add(NumberStepsEvent(flows)); // Dispatch NumberStepsEvent
    } catch (e) {
      emit(ErrorReqSpecStepState(
          e.toString())); // Emit error state if something goes wrong
    }
  }

  void _onNumberStepsEvent(
    NumberStepsEvent event,
    Emitter<ReqSpecStepState> emit,
  ) {
    numberSteps(); // Number the steps
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

  void numberSteps() {
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
