import 'dart:convert';

class Flow {
  int id;
  String type; // MAIN, ALTERNATE, EXCEPTION
  List<ReqStep> steps;

  Flow({required this.type, required this.steps, required this.id});

  getStepByOrder(int order) {
    for (var step in steps) {
      if (step.order == order) {
        return step;
      }
    }
    return null;
  }

  sortSteps() {
    steps.sort((a, b) => a.order.compareTo(b.order));
  }

  getChildrenLength() {
    return steps.length;
  }

  getChildren() {
    return steps;
  }

  removeChild(ReqStep step) {
    steps.remove(step);
  }

  addAsChild(ReqStep step) {
    var parent;
    if (step.parent == null) {
      parent = step.flow;
    } else {
      parent = step.parent;
    }

    step.flow = this;
    parent.removeChild(step);
    steps.add(step);
    step.parent = null;
  }
}

class ReqStep {
  int id;
  String text;
  String type;
  ReqStep? parent;
  List<int> forwardStepAssociations;
  List<ReqStep> children;
  Flow? flow; // Changed to Flow?
  String number;
  int order;

  ReqStep({
    required this.id,
    required this.text,
    required this.type,
    this.parent,
    required this.forwardStepAssociations,
    required this.children,
    this.flow, // Changed to Flow?
    this.number = '',
    required this.order,
  });

  getStepByOrder(int order) {
    for (var step in children) {
      if (step.order == order) {
        return step;
      }
    }
    return null;
  }

  sortSteps() {
    children.sort((a, b) => a.order.compareTo(b.order));
  }

  getChildrenLength() {
    return children.length;
  }

  getChildren() {
    return children;
  }

  addAsChild(ReqStep step) {
    var parent;
    if (step.parent == null) {
      parent = step.flow;
    } else {
      parent = step.parent;
    }

    step.parent = this;
    parent.removeChild(step);
    children.add(step);
    step.flow = null;
  }

  removeChild(ReqStep step) {
    children.remove(step);
  }
}

// Assuming the Flow and Step classes are defined as shown previously

List<Flow> parseFlowsFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  List<Flow> flows = [];

  for (var flowJson in jsonData) {
    Flow flow = Flow(type: flowJson['type'], steps: [], id: flowJson['id']);
    flow.steps =
        parseSteps(flowJson['steps'], null, flow); // Pass the flow object
    flows.add(flow);
  }

  return flows;
}

List<ReqStep> parseSteps(List stepsJson, ReqStep? parent, Flow flow) {
  List<ReqStep> steps = [];
  for (var stepJson in stepsJson) {
    ReqStep step = ReqStep(
      id: stepJson['id'],
      text: stepJson['text'],
      type: stepJson['type'],
      parent: parent,
      forwardStepAssociations:
          List<int>.from(stepJson['forward_step_associations']),
      children: [],
      flow: flow, // Assign the flow object
      order: stepJson['order'],
    );

    if (stepJson['children'] != null && stepJson['children'].isNotEmpty) {
      step.children =
          parseSteps(stepJson['children'], step, flow); // Pass the flow object
    }

    steps.add(step);
  }

  steps.sort((a, b) => a.order.compareTo(b.order));
  return steps;
}

class Tree {
  int id;
  String type; // MAIN, ALTERNATE, EXCEPTION
  List<Node> children;

  Tree({required this.type, required this.children, required this.id});

  getNodeByOrder(int order) {
    for (var node in children) {
      if (node.order == order) {
        return node;
      }
    }
    return null;
  }

  sortNodes() {
    children.sort((a, b) => a.order.compareTo(b.order));
  }

  getChildrenLength() {
    return children.length;
  }

  getChildren() {
    return children;
  }

  removeChild(Node node) {
    children.remove(node);
  }

  addAsChild(Node node) {
    var parent;
    if (node.parent == null) {
      parent = node.tree;
    } else {
      parent = node.parent;
    }

    node.tree = this;
    parent.removeChild(node);
    children.add(node);
    node.parent = null;
  }
}

class Node {
  int id;
  String text;
  String type;
  Node? parent;
  List<int> forwardNodeAssociations;
  List<Node> children;
  Tree? tree; // Changed to Flow?
  String number;
  int order;

  Node({
    required this.id,
    required this.text,
    required this.type,
    this.parent,
    required this.forwardNodeAssociations,
    required this.children,
    this.tree, // Changed to Flow?
    this.number = '',
    required this.order,
  });

  getNodeByOrder(int order) {
    for (var node in children) {
      if (node.order == order) {
        return node;
      }
    }
    return null;
  }

  sortNodes() {
    children.sort((a, b) => a.order.compareTo(b.order));
  }

  getChildrenLength() {
    return children.length;
  }

  getChildren() {
    return children;
  }

  addAsChild(Node node) {
    var parent;
    if (node.parent == null) {
      parent = node.tree;
    } else {
      parent = node.parent;
    }

    node.parent = this;
    parent.removeChild(node);
    children.add(node);
    node.tree = null;
  }

  removeChild(Node node) {
    children.remove(node);
  }
}

List<Tree> parseTreesFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  List<Tree> trees = [];

  for (var treeJson in jsonData) {
    Tree tree = Tree(type: treeJson['type'], children: [], id: treeJson['id']);
    tree.children =
        parseNodes(treeJson['children'], null, tree); // Pass the tree object
    trees.add(tree);
  }

  return trees;
}

List<Node> parseNodes(List nodesJson, Node? parent, Tree tree) {
  List<Node> nodes = [];
  for (var nodeJson in nodesJson) {
    Node node = Node(
      id: nodeJson['id'],
      text: nodeJson['text'],
      type: nodeJson['type'],
      parent: parent,
      forwardNodeAssociations:
          List<int>.from(nodeJson['forward_node_associations']),
      children: [],
      tree: tree, // Assign the flow object
      order: nodeJson['order'],
    );

    if (nodeJson['children'] != null && nodeJson['children'].isNotEmpty) {
      node.children =
          parseNodes(nodeJson['children'], node, tree); // Pass the flow object
    }

    nodes.add(node);
  }

  nodes.sort((a, b) => a.order.compareTo(b.order));
  return nodes;
}
