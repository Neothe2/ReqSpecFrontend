import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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
    //TODO Replace with actual data fetching logic
    var jsonRecieved = [
      {
        "id": 5,
        "type": "MAIN",
        "steps": [
          {
            "id": 8,
            "forward_step_associations": [],
            "type": "MAIN",
            "children": [],
            "text": "this is a step",
            "parent": null,
            "flow": 5
          },
          {
            "id": 9,
            "forward_step_associations": [],
            "type": "MAIN",
            "children": [
              {
                "id": 11,
                "forward_step_associations": [],
                "type": "MAIN",
                "children": [
                  {
                    "id": 15,
                    "forward_step_associations": [],
                    "type": "MAIN",
                    "children": [],
                    "text": "child666",
                    "parent": 11,
                    "flow": null
                  }
                ],
                "text": "some step",
                "parent": 9,
                "flow": null
              },
              {
                "id": 12,
                "forward_step_associations": [13],
                "type": "MAIN",
                "children": [],
                "text": "some step 2",
                "parent": 9,
                "flow": null
              }
            ],
            "text": "this is a step 2",
            "parent": null,
            "flow": 5
          },
          {
            "id": 10,
            "forward_step_associations": [],
            "type": "MAIN",
            "children": [],
            "text": "this is a step 3",
            "parent": null,
            "flow": 5
          }
        ]
      },
      {
        "id": 6,
        "type": "EXCEPTION",
        "steps": [
          {
            "id": 13,
            "forward_step_associations": [12],
            "type": "EXCEPTION",
            "children": [],
            "text": "exception flow step 1",
            "parent": null,
            "flow": 6
          },
          {
            "id": 14,
            "forward_step_associations": [],
            "type": "EXCEPTION",
            "children": [],
            "text": "exception flow step 2",
            "parent": null,
            "flow": 6
          }
        ]
      }
    ];

    return parseFlowsFromJson(jsonEncode(jsonRecieved)); // Dummy data
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
