import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class TreeHttpProvider {
  var url = 'http://192.168.0.4:8000/reqspec';
  var treesRoute = '/trees';
  var nodesRoute = '/nodes';

  Future<List<Flow>> getAll() async {
    var response = await http.get(Uri.parse('$url${treesRoute}/'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return parseFlowsFromJson(response.body);
    } else {
      print(response.body);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load flows');
    }
  }

  addNode(Tree tree, String text) async {
    var order = tree.children.length + 1;

    var response = await http.post(
      Uri.parse(
        '${url}/trees/${tree.id}/create_step/',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"value": text, "order": order}),
    );

    return response;
  }

  editNode(Node node, String newText) async {
    return await http
        .patch(Uri.parse('$url/nodes/${node.id}/'), body: {"text": newText});
  }

  setOrder(Map<String, int> orderMap) async {
    return await http.post(Uri.parse('${url}/steps/set_order/'),
        body: jsonEncode(orderMap));
  }

  indentForward(Node node, newParent) async {
    var requestBody = {
      "parent": newParent.id, // Assuming newParent.id is not null
      "tree": null, // Sending null as required
      "id": node.id,
      "type": node.type
    };

    return await http.patch(Uri.parse('${url}/nodes/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody)); // Encoding the request body as JSON
  }

  indentBackward(Node node, newParent) async {
    var requestBody = {};
    if (newParent is Node) {
      requestBody = {
        "parent": newParent.id, // Assuming newParent.id is not null
        "tree": null, // Sending null as required
        "id": node.id,
        "type": node.type
      };
    } else {
      requestBody = {
        "parent": null, // Sending null as required
        "tree": newParent.id, // Assuming newParent.id is not null
        "id": node.id,
        "type": node.type
      };
    }

    return await http.patch(Uri.parse('${url}/steps/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody)); // Encoding the request body as JSON
  }

  delete(Node node) async {
    return await http.delete(Uri.parse('${url}/nodes/${node.id}/'));
  }
}
