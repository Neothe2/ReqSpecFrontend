import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class TreeHttpProvider {
  var url = 'http://192.168.0.4:8000/reqspec';
  var treesRoute = '/trees';
  var nodesRoute = '/nodes';

  Future<http.Response> httpIndentNodeBackward(
      Node node, dynamic newParent, bool newParentIsTree) async {
    var requestBody = newParentIsTree
        ? {
            "parent": null,
            "tree": newParent.id,
            "id": node.id,
            "type": node.type
          }
        : {
            "parent": newParent.id,
            "tree": null,
            "id": node.id,
            "type": node.type
          };

    return await http.patch(Uri.parse('${url}/reqspec/nodes/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody));
  }

  Future<http.Response> httpIndentNodeForward(Node node, Node newParent) async {
    var requestBody = {
      "parent": newParent.id,
      "tree": null,
      "id": node.id,
      "type": node.type
    };

    return await http.patch(Uri.parse('${url}/reqspec/nodes/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody));
  }

  Future<http.Response> httpLoadTrees() async {
    return await http.get(Uri.parse('${url}/trees/'));
  }

  Future<http.Response> httpUpdateNodeText(Node node, String newText) async {
    return await http
        .patch(Uri.parse('${url}/nodes/${node.id}/'), body: {"text": newText});
  }

  Future<http.Response> httpMoveNode(Node node, int newOrder) async {
    return await http.patch(Uri.parse('${url}/nodes/${node.id}/'),
        body: {'order': newOrder.toString()});
  }

  Future<http.Response> httpDeleteNode(Node node) async {
    return await http.delete(Uri.parse('${url}/nodes/${node.id}/'));
  }

  Future<http.Response> httpAddNode(Tree tree, String text, int order) async {
    return await http.post(Uri.parse('${url}/trees/${tree.id}/create_node/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "order": order}));
  }

  Future<http.Response> httpSetNodeOrder(Map<String, int> orderMap) async {
    return await http.post(Uri.parse('${url}/nodes/set_order/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderMap));
  }
}

class DummyHttpProvider extends TreeHttpProvider {
  @override
  var url = 'http://192.168.0.4:8000/reqspec';
  @override
  var treesRoute = '/trees';
  @override
  var nodesRoute = '/nodes';

  @override
  Future<http.Response> httpIndentNodeBackward(
      Node node, dynamic newParent, bool newParentIsTree) async {
    var requestBody = newParentIsTree
        ? {
            "parent": null,
            "tree": newParent.id,
            "id": node.id,
            "type": node.type
          }
        : {
            "parent": newParent.id,
            "tree": null,
            "id": node.id,
            "type": node.type
          };
    print('Syke');

    return await http.patch(Uri.parse('${url}/reqspec/nodes/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody));
  }

  @override
  Future<http.Response> httpIndentNodeForward(Node node, Node newParent) async {
    var requestBody = {
      "parent": newParent.id,
      "tree": null,
      "id": node.id,
      "type": node.type
    };

    print('Syke');
    return await http.patch(Uri.parse('${url}/reqspec/nodes/${node.id}/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody));
  }

  @override
  Future<http.Response> httpLoadTrees() async {
    print('Syke');
    return await http.get(Uri.parse('${url}/trees/'));
  }

  @override
  Future<http.Response> httpUpdateNodeText(Node node, String newText) async {
    print('Syke');
    return await http
        .patch(Uri.parse('${url}/nodes/${node.id}/'), body: {"text": newText});
  }

  @override
  Future<http.Response> httpMoveNode(Node node, int newOrder) async {
    print('Syke');
    return await http.patch(Uri.parse('${url}/nodes/${node.id}/'),
        body: {'order': newOrder.toString()});
  }

  @override
  Future<http.Response> httpDeleteNode(Node node) async {
    print('Syke');
    return await http.delete(Uri.parse('${url}/nodes/${node.id}/'));
  }

  @override
  Future<http.Response> httpAddNode(Tree tree, String text, int order) async {
    print('Syke');
    return await http.post(Uri.parse('${url}/trees/${tree.id}/create_node/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "order": order}));
  }

  @override
  Future<http.Response> httpSetNodeOrder(Map<String, int> orderMap) async {
    print('Syke');
    return await http.post(Uri.parse('${url}/nodes/set_order/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderMap));
  }
}
