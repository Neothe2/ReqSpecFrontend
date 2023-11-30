import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqspec/step_list/step_bloc.dart';
import 'package:reqspec/step_list/step_list_widget.dart';

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

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = 'Add alternate flows';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: <Widget>[
          NodeListPage(
            treeId: 1, // Replace with your first flowId
          ),
          TextButton(
            onPressed: () {
              // SystemNavigator.pop();
              // throw Exception('FUCK YOU!');
            },
            child: Text(text),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.yellow),
              foregroundColor: MaterialStatePropertyAll(Colors.black),
            ),
          ),
          // NodeListPage(
          //   treeId: 6, // Replace with your second flowId
          // ),
        ],
      ),
    );
  }
}
