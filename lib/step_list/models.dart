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
