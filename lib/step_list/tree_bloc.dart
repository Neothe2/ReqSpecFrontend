import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

import 'step_bloc.dart';

class NodeBloc extends Bloc<TreeEvent, NodeState> {
  List<Tree> trees = [];
  var url = 'http://192.168.0.4:8000/reqspec';

  NodeBloc() : super(InitialNodeState()) {
    on<LoadTreesEvent>(_onLoadTreesEvent);
    on<NumberNodesEvent>(_onNumberNodesEvent);
    on<SelectNodeEvent>(_onNodeSelectedEvent);
    on<EditNodeEvent>(_onEditNodeEvent);
    on<UpdateNodeTextEvent>(_onUpdateNodeTextEvent);
    on<MoveNodeUpEvent>(_onMoveNodeUpEvent);
    on<MoveNodeDownEvent>(_onMoveNodeDownEvent);
    on<IndentNodeForwardEvent>(_onIndentNodeForwardEvent);
    on<IndentNodeBackwardEvent>(_onIndentNodeBackwardEvent);
    on<DeleteNodeEvent>(_onDeleteNodeEvent);
    on<AddNodeEvent>(_onAddNodeEvent);
  }

  FutureOr<void> _onIndentNodeBackwardEvent(
    IndentNodeBackwardEvent event,
    Emitter<NodeState> emit,
  ) async {
    if (event.node.parent != null) {
      var parent = event.node.parent;
      var newParent;
      bool newParentIsTree = false;
      if (event.node.parent!.parent == null) {
        newParent = event.node.parent!.tree;
        newParentIsTree = true;
      } else {
        newParent = event.node.parent!.parent;
      }
      var requestBody = {};
      if (!newParentIsTree) {
        requestBody = {
          "parent": newParent.id, // Assuming newParent.id is not null
          "tree": null, // Sending null as required
          "id": event.node.id,
          "type": event.node.type
        };
      } else {
        requestBody = {
          "parent": null, // Sending null as required
          "tree": newParent.id, // Assuming newParent.id is not null
          "id": event.node.id,
          "type": event.node.type
        };
      }

      var response = await http.patch(
          Uri.parse('${url}/reqspec/nodes/${event.node.id}/'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody)); // Encoding the request body as JSON

      print(response.body);
      print(response.statusCode);

      var orderMap = {};

      bool targetNodeReached = false;
      orderMap[event.node.id.toString()] = parent!.order + 1;
      event.node.order = parent.order + 1;

      for (Node node in newParent.getChildren()) {
        if (targetNodeReached) {
          orderMap[node.id.toString()] = node.order + 1;
          node.order = node.order + 1;
        } else {
          if (node == parent) {
            targetNodeReached = true;
          }
        }
      }
      newParent.addAsChild(event.node);
      // for (var i = 1; i <= newParent.getChildren().length; i++) {
      //   if (!(newParent.getChildren()[i - 1].order == i)) {
      //     newParent.getChildren()[i - 1].order = i;
      //     orderMap[(newParent.getChildren()[i - 1].id).toString()] = i;
      //   }
      // }
      for (var i = 1; i <= parent.getChildren().length; i++) {
        if (!(parent.getChildren()[i - 1].order == i)) {
          parent.getChildren()[i - 1].order = i;
          orderMap[(parent.getChildren()[i - 1].id).toString()] = i;
        }
      }

      print(orderMap);

      http.post(
        Uri.parse('${url}/reqspec/nodes/set_order/'),
        body: jsonEncode(orderMap),
      );

      parent.sortNodes();
      newParent.sortNodes();
      numberNodes();

      emit(NodeSelectedState(trees, event.node.id));
    }
  }

  FutureOr<void> _onIndentNodeForwardEvent(
      IndentNodeForwardEvent event, Emitter<NodeState> emit) async {
    if (event.node.order > 1) {
      var parent;
      if (event.node.parent == null) {
        parent = event.node.tree;
      } else {
        parent = event.node.parent;
      }
      Node newParent = parent.getNodeByOrder(event.node.order - 1);
      var requestBody = {
        "parent": newParent.id, // Assuming newParent.id is not null
        "tree": null, // Sending null as required
        "id": event.node.id,
        "type": event.node.type
      };

      var response = await http.patch(
          Uri.parse('${url}/reqspec/nodes/${event.node.id}/'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody)); // Encoding the request body as JSON

      print(response.body);
      print(response.statusCode);

      newParent.addAsChild(event.node);

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

      var a = {"parent": newParent.id, "tree": (null).toString()};
      print(a);

      print(orderMap);

      http.post(Uri.parse('${url}/reqspec/nodes/set_order/'),
          body: jsonEncode(orderMap));

      parent.sortNodes();
      newParent.sortNodes();
      numberNodes();

      emit(NodeSelectedState(trees, event.node.id));
    }
  }

  FutureOr<void> _onLoadTreesEvent(
    LoadTreesEvent event,
    Emitter<NodeState> emit,
  ) async {
    final response = await http.get(Uri.parse('${url}/trees/'));
    if (response.statusCode == 200) {
      trees = parseTreesFromJson(response.body);
      emit(TreesLoadedState(trees));
      add(NumberNodesEvent(trees));
    } else {
      emit(ErrorState('Failed to load trees'));
    }
  }

  void _onNumberNodesEvent(
    NumberNodesEvent event,
    Emitter<NodeState> emit,
  ) {
    for (var tree in trees) {
      _numberNodesRecursive(tree.children);
    }
    emit(TreesNumberedState(trees));
  }

  // void _numberNodesRecursive(List<Node> nodes, [String prefix = '']) {
  //   for (int i = 0; i < nodes.length; i++) {
  //     var currentNode = nodes[i];
  //     currentNode.number = prefix.isEmpty ? '${i + 1}' : '$prefix.${i + 1}';
  //     if (currentNode.children.isNotEmpty) {
  //       _numberNodesRecursive(currentNode.children, currentNode.number);
  //     }
  //   }
  // }

  FutureOr<void> _onNodeSelectedEvent(
    SelectNodeEvent event,
    Emitter<NodeState> emit,
  ) async {
    emit(NodeSelectedState(trees, event.nodeId));
  }

  FutureOr<void> _onEditNodeEvent(
    EditNodeEvent event,
    Emitter<NodeState> emit,
  ) async {
    emit(EditingNodeState(trees, event.nodeId));
  }

  FutureOr<void> _onUpdateNodeTextEvent(
    UpdateNodeTextEvent event,
    Emitter<NodeState> emit,
  ) async {
    final response = await http.patch(
        Uri.parse('${url}/nodes/${event.node.id}/'),
        body: {"text": event.newText});
    if (response.statusCode == 200) {
      event.node.text = event.newText;
      emit(NodeSelectedState(trees, event.node.id));
    } else {
      emit(ErrorState('Failed to update node text'));
    }
  }

  FutureOr<void> _onMoveNodeUpEvent(
    MoveNodeUpEvent event,
    Emitter<NodeState> emit,
  ) async {
    dynamic parent = event.node.parent ?? event.node.tree;
    if (event.node.order > 1) {
      Node nodeToSwap = parent.getNodeByOrder(event.node.order - 1);
      final responseSwap = await http.patch(
          Uri.parse('${url}/nodes/${nodeToSwap.id}/'),
          body: {'order': (event.node.order).toString()});
      final responseCurrent = await http.patch(
          Uri.parse('${url}/nodes/${event.node.id}/'),
          body: {'order': (event.node.order - 1).toString()});
      if (responseSwap.statusCode == 200 && responseCurrent.statusCode == 200) {
        nodeToSwap.order = event.node.order;
        event.node.order -= 1;
        parent.sortNodes();
        numberNodes();
        emit(NodeSelectedState(trees, event.node.id));
      } else {
        emit(ErrorState('Failed to move node up'));
      }
    }
  }

  FutureOr<void> _onMoveNodeDownEvent(
    MoveNodeDownEvent event,
    Emitter<NodeState> emit,
  ) async {
    dynamic parent = event.node.parent ?? event.node.tree;
    if (event.node.order < parent.children.length) {
      Node nodeToSwap = parent.getNodeByOrder(event.node.order + 1);
      final responseSwap = await http.patch(
          Uri.parse('${url}/nodes/${nodeToSwap.id}/'),
          body: {'order': (event.node.order).toString()});
      final responseCurrent = await http.patch(
          Uri.parse('${url}/nodes/${event.node.id}/'),
          body: {'order': (event.node.order + 1).toString()});
      if (responseSwap.statusCode == 200 && responseCurrent.statusCode == 200) {
        nodeToSwap.order = event.node.order;
        event.node.order += 1;
        parent!.sortNodes();
        numberNodes();
        emit(NodeSelectedState(trees, event.node.id));
      } else {
        emit(ErrorState('Failed to move node down'));
      }
    }
  }

  FutureOr<void> _onDeleteNodeEvent(
    DeleteNodeEvent event,
    Emitter<NodeState> emit,
  ) async {
    dynamic parent = event.node.parent ?? event.node.tree;
    final response =
        await http.delete(Uri.parse('${url}/nodes/${event.node.id}/'));
    print(response.statusCode);
    if (response.statusCode == 204) {
      parent!.removeChild(event.node);
      _updateNodeOrders(parent);
      emit(TreesNumberedState(trees));
    } else {
      emit(ErrorState('Failed to delete node'));
    }
  }

  void _updateNodeOrders(dynamic parent) {
    int order = 1;
    for (var node in parent.getChildren()) {
      node.order = order++;
    }
  }

  FutureOr<void> _onAddNodeEvent(
    AddNodeEvent event,
    Emitter<NodeState> emit,
  ) async {
    var order = event.tree.children.length + 1;
    final response = await http.post(
        Uri.parse('${url}/trees/${event.tree.id}/create_node/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"value": event.text, "order": order}));
    if (response.statusCode == 201) {
      var serializedResponse = jsonDecode(response.body);
      event.tree.children.add(Node(
          id: serializedResponse['id'],
          text: serializedResponse['text'],
          type: serializedResponse['type'],
          forwardNodeAssociations: [],
          children: [],
          order: order,
          tree: event.tree));
      event.tree.sortNodes();
      numberNodes();
      emit(TreesNumberedState(trees));
    } else {
      print(response.body);
      emit(ErrorState('Failed to add node'));
    }
  }

  Future<List<Tree>> fetchTrees() async {
    final uri = Uri.parse('${url}/trees/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      print(response.body);
      return parseTreesFromJson(response.body);
    } else {
      print(response.body);
      throw Exception('Failed to load trees');
    }
  }

  void numberNodes() {
    for (var tree in trees) {
      _numberNodesRecursive(tree.children);
    }
  }

  void _numberNodesRecursive(List<Node> nodes, [String prefix = '']) {
    for (int i = 0; i < nodes.length; i++) {
      var currentNode = nodes[i];
      currentNode.number = prefix.isEmpty ? '${i + 1}' : '$prefix.${i + 1}';

      if (currentNode.children.isNotEmpty) {
        _numberNodesRecursive(currentNode.children, currentNode.number);
      }
    }
  }
}

// List<Tree> parseTreesFromJson(String jsonString) {
//   final jsonData = json.decode(jsonString);
//   List<Tree> trees = [];
//   for (var treeJson in jsonData) {
//     Tree tree = Tree(
//         id: treeJson['id'],
//         type: treeJson['type'],
//         children: treeJson['children'] != null
//             ? parseNodes(treeJson['children'], null, null)
//             : []);
//     trees.add(tree);
//   }
//   return trees;
// }
//
// List<Node> parseNodes(List<dynamic> nodesJson, Node? parent, Tree? tree) {
//   List<Node> nodes = [];
//   for (var nodeJson in nodesJson) {
//     Node node = Node(
//       id: nodeJson['id'],
//       text: nodeJson['text'],
//       type: nodeJson['type'],
//       parent: parent,
//       forwardNodeAssociations:
//           List<int>.from(nodeJson['forward_step_associations'] ?? []),
//       children: parseNodes(nodeJson['children'] ?? [], null, tree),
//       tree: tree,
//       order: nodeJson['order'],
//     );
//     nodes.add(node);
//   }
//   return nodes;
// }
