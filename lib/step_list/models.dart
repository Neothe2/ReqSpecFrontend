import 'dart:convert';

class Flow {
  final int id;
  final String type; // MAIN, ALTERNATE, EXCEPTION
  final List<ReqStep> steps;

  Flow({required this.type, required this.steps, required this.id});
}

class ReqStep {
  final int id;
  final String text;
  final String type;
  final int? parent;
  final List<int> forwardStepAssociations;
  final List<ReqStep> children;
  final String flowId;
  String number; // Will be assigned later

  ReqStep({
    required this.id,
    required this.text,
    required this.type,
    this.parent,
    required this.forwardStepAssociations,
    required this.children,
    required this.flowId,
    this.number = '',
  });
}

// Assuming the Flow and Step classes are defined as shown previously

List<Flow> parseFlowsFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  List<Flow> flows = [];

  for (var flowJson in jsonData) {
    List<ReqStep> steps = parseSteps(flowJson['steps']);
    Flow flow = Flow(type: flowJson['type'], steps: steps, id: flowJson['id']);
    flows.add(flow);
  }

  return flows;
}

List<ReqStep> parseSteps(List stepsJson) {
  List<ReqStep> steps = [];
  for (var stepJson in stepsJson) {
    List<ReqStep> children = [];
    if (stepJson['children'] != null && stepJson['children'].isNotEmpty) {
      children = parseSteps(stepJson['children']);
    }
    ReqStep step = ReqStep(
      id: stepJson['id'],
      text: stepJson['text'],
      type: stepJson['type'],
      parent: stepJson['parent'],
      forwardStepAssociations:
          List<int>.from(stepJson['forward_step_associations']),
      children: children,
      flowId: stepJson['flow'].toString(),
    );
    steps.add(step);
  }
  return steps;
}
