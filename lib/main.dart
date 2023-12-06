import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/http_providor.dart';
import 'package:reqspec/step_list/step_bloc.dart';
import 'package:reqspec/step_list/step_list_widget.dart';

import 'step_list/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Steps Tree Widget :)'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NodeListPage> alternate_flows = [];
  List<NodeListPage> exception_flows = [];
  late NodeListPage main_flow;
  dynamic use_case_description = {};
  Map<int, NodeListPage> flow_map = {};
  bool treesFetched = false;

  void scrollToNode(GlobalKey key) {
    // final GlobalKey key = exception_flows[0].nodeListWidget.nodeKeys[nodeId]!;

    // Check if the context for the key is available
    if (key.currentContext != null) {
      // Scroll to the position of the key
      Scrollable.ensureVisible(key.currentContext!,
          duration: Duration(milliseconds: 1000));
    }
  }

  getTrees(int use_case_description_id) async {
    var response = await http.get(Uri.parse(
        'http://10.0.2.2:8000/reqspec/use_case_descriptions/$use_case_description_id'));
    var serializedData = jsonDecode(response.body);
    use_case_description = serializedData;
    for (var alternateFlowId in serializedData['alternate_flows']) {
      var nodeListPage = NodeListPage(
        treeId: alternateFlowId, // Replace with your first flowId
        httpProvider: AlternateFlowHttpProvidor(),
      );
      alternate_flows.add(nodeListPage);
      flow_map[alternateFlowId] = nodeListPage;
    }
    for (var exceptionFlowId in serializedData['exception_flows']) {
      var nodeListPage = NodeListPage(
        treeId: exceptionFlowId, // Replace with your first flowId
        httpProvider: ExceptionFlowHttpProvidor(),
      );
      exception_flows.add(nodeListPage);
      flow_map[exceptionFlowId] = nodeListPage;
    }

    main_flow = NodeListPage(
      treeId: serializedData['main_flow'], // Replace with your first flowId
      httpProvider: StepHttpProvider(),
    );

    flow_map[serializedData['main_flow']] = main_flow;
    main_flow.associationStream.listen((event) {
      // var a = flow_map[event['tree_id']]!.nodeListWidget;
      final GlobalKey key =
          flow_map[event['tree_id']]!.nodeListWidget.nodeKeys[event['id']]!;
      scrollToNode(key);
    });

    setState(() {
      treesFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getTrees(1);
  }

  @override
  Widget build(BuildContext context) {
    var text = 'Add Alternate Flows';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: treesFetched
            ? <Widget>[
                TextButton(
                  onPressed: () {
                    print(flow_map[16]!.nodeListWidget);
                  },
                  child: Text('SCROOOOOL!!!'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.yellow),
                    foregroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),
                main_flow,
                TextButton(
                  onPressed: () async {
                    await addAlternateFlow();
                  },
                  child: Text(text),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.yellow),
                    foregroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),
                Column(
                  children: alternate_flows,
                ),
                TextButton(
                  onPressed: () async {
                    await addExceptionFlow();
                  },
                  child: Text('Add Exception Flow'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.yellow),
                    foregroundColor: MaterialStatePropertyAll(Colors.black),
                  ),
                ),

                Column(
                  children: exception_flows,
                )
                // NodeListPage(
                //   treeId: 6, // Replace with your second flowId
                // ),
              ]
            : [],
      ),
    );
  }

  addAlternateFlow() async {
    var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/reqspec/alternate_flows/'),
        body: {});

    var serializedResponse = jsonDecode(response.body);
    setState(() {
      use_case_description['alternate_flows'] = [
        ...use_case_description['alternate_flows'],
        serializedResponse['id']
      ];
    });
    var newresponse = await http.put(
        Uri.parse('http://10.0.2.2:8000/reqspec/use_case_descriptions/1/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(use_case_description));

    print(newresponse.body);
    print(newresponse.statusCode);
    setState(() {
      alternate_flows.add(NodeListPage(
        treeId: serializedResponse['id'], // Replace with your first flowId
        httpProvider: AlternateFlowHttpProvidor(),
      ));
    });
  }

  addExceptionFlow() async {
    var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/reqspec/exception_flows/'),
        body: {});

    var serializedResponse = jsonDecode(response.body);
    setState(() {
      use_case_description['exception_flows'] = [
        ...use_case_description['exception_flows'],
        serializedResponse['id']
      ];
    });
    var newresponse = await http.put(
        Uri.parse('http://10.0.2.2:8000/reqspec/use_case_descriptions/1/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(use_case_description));

    print(newresponse.body);
    print(newresponse.statusCode);
    setState(() {
      exception_flows.add(NodeListPage(
        treeId: serializedResponse['id'], // Replace with your first flowId
        httpProvider: ExceptionFlowHttpProvidor(),
      ));
    });
  }
}
