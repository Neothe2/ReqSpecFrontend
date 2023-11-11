import 'package:flutter/material.dart';
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = 'Don\'t click this button';
    return BlocProvider<StepBloc>(
      create: (context) => StepBloc()
        ..add(LoadFlowsEvent()), // Triggering the event to load flows
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: <Widget>[
            StepListWidget(
              flowId: 5, // Replace with your first flowId
            ),
            TextButton(
              onPressed: () {
                text = 'Fuck you';
              },
              child: Text(text),
            ),
            StepListWidget(
              flowId: 6, // Replace with your second flowId
            ),
          ],
        ),
      ),
    );
  }
}
