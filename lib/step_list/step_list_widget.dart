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

  Widget buildStepCard(
    ReqStep step,
    bool isSelected,
    BuildContext context,
    bool isEditing,
  ) {
    var editingText = '';
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          context.read<StepBloc>().add(SelectStepEvent(-1)); // Deselect
        } else {
          context.read<StepBloc>().add(SelectStepEvent(step.id)); // Select
        }
      },
      child: Card(
        color: isSelected ? Colors.lightBlue : null,
        elevation: 2,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Text(
                step.number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              title: isEditing && isSelected
                  ? TextField(
                      controller: TextEditingController(text: step.text),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      autofocus: true,
                      onChanged: (String text) {
                        editingText = text;
                      },
                      onSubmitted: (String text) {
                        context
                            .read<StepBloc>()
                            .add(UpdateStepTextEvent(step.id, text));
                      },
                    )
                  : Text(
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
            ),
            // Submenu appears as a row of icon buttons when the item is selected
            if (isSelected)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: Colors.lightBlue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward_rounded),
                        onPressed: () {
                          print('Move ${step.text} up');
                          // Handle move up
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_rounded),
                        onPressed: () {
                          print('Move ${step.text} down');
                          // Handle move down
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_right_rounded),
                        onPressed: () {
                          print('Indent ${step.text} to the right');
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_left_rounded),
                        onPressed: () {
                          print('Indent ${step.text} to the left');
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: () {
                          print('Delete ${step.text}');
                        },
                        color: Colors.white,
                      ),
                      !isEditing
                          ? IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                context
                                    .read<StepBloc>()
                                    .add(EditStepEvent(step.id));
                                // Handle delete
                              },
                              color: Colors.white,
                            )
                          : IconButton(
                              onPressed: () {
                                context.read<StepBloc>().add(
                                    UpdateStepTextEvent(step.id, editingText));
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              )),
                    ],
                  ),
                  elevation: 0,
                ),
              ),
            // ... existing submenu icons
          ],
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
            state is StepSelectedState ||
            state is EditingStepState) {
          // final steps = state is FlowsLoadedState
          //     ? state.flows.first.steps
          //     : (state as FlowsNumberedState).flows.first.steps;
          final steps =
              getAllSteps(getFlowById((state as dynamic).flows, flowId));
          var selectedStepId = -1;
          var isEditing = false;
          if (state is StepSelectedState) {
            selectedStepId = (state as dynamic).selectedStepId;
          }
          if (state is EditingStepState) {
            selectedStepId = state.editingStepId;
            isEditing = true;
          }

          return getStepList(
            steps,
            selectedStepId,
            context,
            isEditing,
          ); // Use the new method to build the list
        } else if (state is ErrorReqSpecStepState) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox(); // Fallback for any other unhandled states
        }
      },
    );
  }

  Widget getStepList(
    List<ReqStep> steps,
    int selectedStepId,
    BuildContext context,
    bool isEditing,
  ) {
    // Map each step to a widget using the buildStepCard function
    // and then convert it to a list using toList().
    List<Widget> stepWidgets = steps.map<Widget>((step) {
      return buildStepCard(step, step.id == selectedStepId, context, isEditing);
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
