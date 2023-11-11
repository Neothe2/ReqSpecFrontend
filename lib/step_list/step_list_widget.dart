import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/step_bloc.dart';

import 'models.dart';
import 'models.dart' as reqspec_models;

class StepListWidget extends StatelessWidget {
  final List<ReqStep>? steps;

  const StepListWidget({
    Key? key,
    this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If steps are provided, build the UI from the provided steps
    // Otherwise, build the UI from the steps in the current state
    return steps != null ? buildStepsList(steps!) : buildStepsFromBloc(context);
  }

  Widget buildStepsList(List<ReqStep> steps) {
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return ListTile(
          title: Text('${step.number} ${step.text}'),
          // subtitle:
          // step.children.isNotEmpty
          //     ? Padding(
          //         padding: const EdgeInsets.only(left: 16.0),
          //         child: StepListWidget(
          //             steps:
          //                 step.children), // Recursion with the children steps
          //       )
          //     : null,
        );
      },
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
              ? state.flows.first
              : (state as FlowsNumberedState).flows.first);
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
}
