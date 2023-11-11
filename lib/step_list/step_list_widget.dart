import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/step_bloc.dart';

import 'models.dart';
import 'models.dart' as reqspec_models;

class StepListWidget extends StatelessWidget {
  final List<ReqStep>? steps;
  final int flowId;

  const StepListWidget({
    Key? key,
    required this.flowId,
    this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If steps are provided, build the UI from the provided steps
    // Otherwise, build the UI from the steps in the current state
    return steps != null ? buildStepsList(steps!) : buildStepsFromBloc(context);
  }

  Widget buildStepsList(List<ReqStep> steps) {
    return Column(
      children: steps.map((step) => buildStepCard(step)).toList(),
    );
  }

  Widget buildStepCard(ReqStep step) {
    return Card(
      elevation: 2, // Adds a subtle shadow
      margin: const EdgeInsets.all(8.0), // Space around the card
      child: ListTile(
        leading: Text(
          step.number,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ), // Step number
        title: Text(
          step.text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // You can add onTap, trailing and other properties as needed
      ),
    );
  }

  Widget buildStepsFromBloc(BuildContext context) {
    return BlocBuilder<StepBloc, ReqSpecStepState>(
      builder: (context, state) {
        if (state is InitialReqSpecStepState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FlowsLoadedState || state is FlowsNumberedState) {
          // final steps = state is FlowsLoadedState
          //     ? state.flows.first.steps
          //     : (state as FlowsNumberedState).flows.first.steps;
          final steps = getAllSteps(state is FlowsLoadedState
              ? getFlowById(state.flows, flowId)
              : getFlowById((state as FlowsNumberedState).flows, flowId));
          return buildStepsList(steps); // Use the new method to build the list
        } else if (state is ErrorReqSpecStepState) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox(); // Fallback for any other unhandled states
        }
      },
    );
  }

  getAllSteps(reqspec_models.Flow flow) {
    print(flow.steps);
    List<ReqStep> stepList = [];
    for (var child in flow.steps) {
      _getAllSteps(child, stepList);
    }
    return stepList;
  }

  _getAllSteps(ReqStep root, List<ReqStep> stepList) {
    stepList.add(root);
    for (var child in root.children) {
      _getAllSteps(child, stepList);
    }
  }

  getFlowById(List<reqspec_models.Flow> flows, int flowId) {
    for (var flow in flows) {
      if (flow.id == flowId) {
        return flow;
      }
    }
    throw Exception('The flow id specified dosen\'t exist');
  }
}
