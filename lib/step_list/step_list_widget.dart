import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/step_bloc.dart';

import 'models.dart';
import 'models.dart' as reqspec_models;

class StepListPage extends StatelessWidget {
  final int flowId;

  const StepListPage({
    Key? key,
    required this.flowId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a unique BlocProvider for each StepListWidget
    return BlocProvider<StepBloc>(
      create: (_) => StepBloc()..add(LoadFlowsEvent()),
      child: StepListWidget(flowId: flowId),
    );
  }
}

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
    return buildStepsFromBloc(context);
  }

  Widget buildStepCard(ReqStep step, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          return context.read<StepBloc>().add(SelectStepEvent(-1));
        }
        context.read<StepBloc>().add(SelectStepEvent(step.id));
      },
      child: Card(
        color: isSelected ? Colors.lightBlue : null,

        elevation: 2, // Adds a subtle shadow
        margin: const EdgeInsets.all(8.0), // Space around the card
        child: ListTile(
          tileColor: null,
          leading: Text(
            step.number,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ), // Step number
          title: Text(
            step.text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                )
              : null,
          // You can add onTap, trailing and other properties as needed
        ),
      ),
    );
  }

  Widget buildStepsFromBloc(BuildContext context) {
    return BlocBuilder<StepBloc, ReqSpecStepState>(
      builder: (context, state) {
        if (state is InitialReqSpecStepState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FlowsLoadedState ||
            state is FlowsNumberedState ||
            state is StepSelectedState) {
          // final steps = state is FlowsLoadedState
          //     ? state.flows.first.steps
          //     : (state as FlowsNumberedState).flows.first.steps;
          final steps =
              getAllSteps(getFlowById((state as dynamic).flows, flowId));
          var selectedStepId = -1;
          if (state is StepSelectedState) {
            selectedStepId = (state as dynamic).selectedStepId;
          }

          return getStepList(steps, selectedStepId,
              context); // Use the new method to build the list
        } else if (state is ErrorReqSpecStepState) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox(); // Fallback for any other unhandled states
        }
      },
    );
  }

  Widget getStepList(
      List<ReqStep> steps, int selectedStepId, BuildContext context) {
    // Map each step to a widget using the buildStepCard function
    // and then convert it to a list using toList().
    List<Widget> stepWidgets = steps.map<Widget>((step) {
      return buildStepCard(
        step,
        step.id == selectedStepId,
        context,
      );
    }).toList();

    return Column(
      children: stepWidgets, // Use the list of widgets here
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
