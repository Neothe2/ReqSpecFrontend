import 'dart:async';
import 'dart:collection';
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
    on<MoveStepUpEvent>(_onMoveStepUpEvent);
    on<MoveStepDownEvent>(_onMoveStepDownEvent);
    on<IndentStepForwardEvent>(_onIndentStepForwardEvent);
  }

  FutureOr<void> _onIndentStepForwardEvent(
      IndentStepForwardEvent event, Emitter<ReqSpecStepState> emit) async {
    if (event.step.order > 1) {
      var parent;
      if (event.step.parent == null) {
        parent = event.step.flow;
      } else {
        parent = event.step.parent;
      }
      ReqStep newParent = parent.getStepByOrder(event.step.order - 1);
      var requestBody = {
        "parent": newParent.id, // Assuming newParent.id is not null
        "flow": null, // Sending null as required
        "id": event.step.id,
        "type": event.step.type
      };

      var response = await http.patch(
          Uri.parse('http://10.0.2.2:8000/reqspec/steps/${event.step.id}/'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody)); // Encoding the request body as JSON

      print(response.body);
      print(response.statusCode);

      newParent.addAsChild(event.step);

      var orderMap = {};
      for (var i = 1; i <= newParent.children.length; i++) {
        if (!(newParent.children[i - 1].order == i)) {
          newParent.children[i - 1].order = i;
          orderMap[(newParent.children[i - 1].id).toString()] = i;
        }
      }
      for (var i = 1; i <= parent.getChildren().length; i++) {
        if (!(parent.getChildren()[i - 1].order == i)) {
          parent.getChildren()[i - 1].order = i;
          orderMap[(parent.getChildren()[i - 1].id).toString()] = i;
        }
      }

      var a = {"parent": newParent.id, "flow": (null).toString()};
      print(a);

      print(orderMap);

      http.post(Uri.parse('http://10.0.2.2:8000/reqspec/steps/set_order/'),
          body: jsonEncode(orderMap));

      parent.sortSteps();
      newParent.sortSteps();
      numberSteps();

      emit(StepSelectedState(flows, event.step.id));
    }
  }

  FutureOr<void> _onMoveStepUpEvent(
      MoveStepUpEvent event, Emitter<ReqSpecStepState> emit) async {
    if (event.step.order > 1) {
      var parent;
      if (event.step.parent == null) {
        parent = event.step.flow;
      } else {
        parent = event.step.parent;
      }
      ReqStep stepToSwap = parent.getStepByOrder(event.step.order - 1);
      await http.patch(
          Uri.parse('http://10.0.2.2:8000/reqspec/steps/${stepToSwap.id}/'),
          body: {'order': (event.step.order).toString()});
      await http.patch(
          Uri.parse('http://10.0.2.2:8000/reqspec/steps/${event.step.id}/'),
          body: {'order': (event.step.order - 1).toString()});
      stepToSwap.order = event.step.order;
      event.step.order = event.step.order - 1;

      parent.sortSteps();
      numberSteps();
      emit(StepSelectedState(flows, event.step.id));
    }
  }

  FutureOr<void> _onMoveStepDownEvent(
      MoveStepDownEvent event, Emitter<ReqSpecStepState> emit) async {
    var parent;
    if (event.step.parent == null) {
      parent = event.step.flow;
    } else {
      parent = event.step.parent;
    }
    if (event.step.order < parent.getChildrenLength()) {
      ReqStep stepToSwap = parent.getStepByOrder(event.step.order + 1);
      await http.patch(
          Uri.parse('http://10.0.2.2:8000/reqspec/steps/${stepToSwap.id}/'),
          body: {'order': (event.step.order).toString()});
      await http.patch(
          Uri.parse('http://10.0.2.2:8000/reqspec/steps/${event.step.id}/'),
          body: {'order': (event.step.order + 1).toString()});
      stepToSwap.order = event.step.order;
      event.step.order = event.step.order + 1;
      parent.sortSteps();
      numberSteps();
      emit(StepSelectedState(flows, event.step.id));
    }
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
      await _updateStepText(event.step, event.newText);

      // After updating, you would typically want to refresh the list of flows.
      // Let's emit the FlowsLoadedState with the updated flows.
      emit(StepSelectedState(flows, event.step.id));
    } catch (error) {
      // If something goes wrong, emit an error state.
      emit(ErrorReqSpecStepState(error.toString()));
    }
  }

  // Placeholder method for updating the text of a step
  Future<void> _updateStepText(ReqStep step, String newText) async {
    // Find the step by ID and update its text.
    // This is where you'd put your logic for updating the step text.
    // For demonstration, let's just print the new text.
    http.patch(Uri.parse('http://10.0.2.2:8000/reqspec/steps/${step.id}/'),
        body: {"text": newText});
    step.text = newText;
    // flows = await fetchFlows();
    // numberSteps();
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
