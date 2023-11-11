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
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrapping StepListWidget with BlocProvider to provide StepBloc to the widget tree.
    return BlocProvider(
      create: (context) => StepBloc()
        ..add(LoadFlowsEvent()), // Triggering the event to load flows
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body:
            StepListWidget(), // No need to pass steps here as it will be managed by BlocBuilder inside StepListWidget
      ),
    );
  }
}
