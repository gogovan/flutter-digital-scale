import 'package:flutter/material.dart';
import 'package:flutter_digital_scale/wxl_t12.dart';
import 'package:flutter_digital_scale/weight.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scale = WXLT12();

  var status = 'Finding printer...';
  Stream<Weight>? stream;
  Future<Weight>? stabilizedWeight;

  @override
  void initState() {
    _connectPrinter();
  }

  void _connectPrinter() {
    scale.connect((device, service) {
      stream = scale.getWeightStream();
      setState(() {
        status = 'Printer connected';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digital Scale Demo"),
      ),
      body: Column(children: [
        Text(status),
        Text('Current Weight'),
        StreamBuilder<Weight>(
          stream: stream,
          builder: (context, snapshot) => Text(
            '${snapshot.data?.value} ${snapshot.data?.unit}',
          ),
        ),
        ElevatedButton(
            onPressed: getStabilizedWeight, child: Text('Stabilized Weight')),
        FutureBuilder(
          future: stabilizedWeight,
          builder: (context, snapshot) => Text(
            '${snapshot.data?.value} ${snapshot.data?.unit}',
          ),
        ),
      ]),
    );
  }

  void getStabilizedWeight() {
    setState(() {
      stabilizedWeight = scale.getStabilizedWeight(10, const Duration(seconds: 10));
    });
  }

  @override
  void dispose() {
    scale.disconnect();
  }
}
