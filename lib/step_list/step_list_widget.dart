import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/http_providor.dart';
import 'package:reqspec/step_list/step_bloc.dart';
import 'package:reqspec/step_list/tree_bloc.dart';

import 'models.dart';
import 'models.dart' as reqspec_models;

class NodeListPage extends StatelessWidget {
  final int treeId;

  const NodeListPage({
    Key? key,
    required this.treeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a unique BlocProvider for each StepListWidget
    return BlocProvider<NodeBloc>(
      create: (_) => NodeBloc()..add(LoadTreesEvent()),
      child: NodeListWidget(treeId: treeId),
    );
  }
}

class NodeListWidget extends StatelessWidget {
  final List<Node>? nodes;
  final int treeId;
  const NodeListWidget({
    Key? key,
    required this.treeId,
    this.nodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If steps are provided, build the UI from the provided steps
    // Otherwise, build the UI from the steps in the current state
    return buildNodesFromBloc(context);
  }

  Widget buildNodeCard(
    Node node,
    bool isSelected,
    BuildContext context,
    bool isEditing,
  ) {
    var editingText = '';
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          context.read<NodeBloc>().add(SelectNodeEvent(-1)); // Deselect
        } else {
          context.read<NodeBloc>().add(SelectNodeEvent(node.id)); // Select
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
                node.number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              title: isEditing && isSelected
                  ? TextField(
                      controller: TextEditingController(text: node.text),
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
                            .read<NodeBloc>()
                            .add(UpdateNodeTextEvent(node, text));
                      },
                    )
                  : Text(
                      node.text,
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
                  elevation: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward_rounded),
                        onPressed: () {
                          context.read<NodeBloc>().add(MoveNodeUpEvent(node));
                          print('Move ${node.text} up');
                          // Handle move up
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_rounded),
                        onPressed: () {
                          context.read<NodeBloc>().add(MoveNodeDownEvent(node));
                          print('Move ${node.text} down');
                          // Handle move down
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_right_rounded),
                        onPressed: () {
                          context
                              .read<NodeBloc>()
                              .add(IndentNodeForwardEvent(node));
                          print('Indent ${node.text} to the right');
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_left_rounded),
                        onPressed: () {
                          context
                              .read<NodeBloc>()
                              .add(IndentNodeBackwardEvent(node));
                          print('Indent ${node.text} to the left');
                        },
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: () {
                          context.read<NodeBloc>().add(DeleteNodeEvent(node));
                          print('Delete ${node.text}');
                        },
                        color: Colors.white,
                      ),
                      !isEditing
                          ? IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                context
                                    .read<NodeBloc>()
                                    .add(EditNodeEvent(node.id));
                                // Handle delete
                              },
                              color: Colors.white,
                            )
                          : IconButton(
                              onPressed: () {
                                context.read<NodeBloc>().add(
                                    UpdateNodeTextEvent(node, editingText));
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              )),
                    ],
                  ),
                ),
              ),
            // ... existing submenu icons
          ],
        ),
      ),
    );
  }

  Widget buildNodesFromBloc(BuildContext context) {
    return BlocBuilder<NodeBloc, NodeState>(
      builder: (context, state) {
        if (state is InitialNodeState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TreesLoadedState ||
            state is TreesNumberedState ||
            state is NodeSelectedState ||
            state is EditingNodeState) {
          // final steps = state is treesLoadedState
          //     ? state.trees.first.steps
          //     : (state as treesNumberedState).trees.first.steps;
          reqspec_models.Tree tree =
              gettreeById((state as dynamic).trees, treeId);
          final nodes = getAllNodes(tree);
          var selectedNodeId = -1;
          var isEditing = false;
          if (state is NodeSelectedState) {
            selectedNodeId = (state as dynamic).selectedNodeId;
          }
          if (state is EditingNodeState) {
            selectedNodeId = state.editingNodeId;
            isEditing = true;
          }

          var treeType = convertWord(tree.type);

          return Card(
            margin: EdgeInsets.all(10.0),
            elevation: 4.0, // Increased elevation
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                  color: Colors.blueGrey[100]!, width: 1.0), // Border
            ),
            color: Colors.blueGrey[50], // Light background color
            child: Padding(
              padding: EdgeInsets.all(8.0), // Inner padding
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: Text(
                          treeType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Bold title
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ...getNodeList(
                        nodes,
                        selectedNodeId,
                        context,
                        isEditing,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(Icons.add,
                          color: Colors.blue), // Styled add button
                      onPressed: () async {
                        String? newText = await addNodeModal(context);
                        if (newText != null) {
                          context
                              .read<NodeBloc>()
                              .add(AddNodeEvent(tree.type, newText, tree));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const SizedBox(); // Fallback for any other unhandled states
        }
      },
    );
  }

  String convertWord(String word) {
    if (word.isEmpty) {
      return word;
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  void main() {
    String word = "THIS";
    String convertedWord = convertWord(word);
    print(convertedWord); // This
  }

  List<Widget> getNodeList(
    List<Node> nodes,
    int selectedNodeId,
    BuildContext context,
    bool isEditing,
  ) {
    // Map each step to a widget using the buildStepCard function
    // and then convert it to a list using toList().
    List<Widget> nodeWidgets = nodes.map<Widget>((node) {
      return buildNodeCard(node, node.id == selectedNodeId, context, isEditing);
    }).toList();

    return nodeWidgets; // Use the list of widgets here
  }

  getAllNodes(reqspec_models.Tree tree) {
    print(tree.children);
    List<Node> nodeList = [];
    for (var child in tree.children) {
      _getAllNodes(child, nodeList);
    }
    return nodeList;
  }

  _getAllNodes(Node root, List<Node> nodeList) {
    nodeList.add(root);
    for (var child in root.children) {
      _getAllNodes(child, nodeList);
    }
  }

  gettreeById(List<reqspec_models.Tree> trees, int treeId) {
    for (var tree in trees) {
      if (tree.id == treeId) {
        return tree;
      }
    }
    throw Exception('The tree id specified dosen\'t exist');
  }

  Future<String?> addNodeModal(BuildContext context) async {
    TextEditingController textController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Node'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: "Enter node text here"),
            onSubmitted: (String text) {
              Navigator.of(context).pop(text);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null); // Dismiss and return null
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(textController.text); // Return text
              },
            ),
          ],
        );
      },
    );
  }
}
