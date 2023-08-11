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

  var status = 'Pending...';
  Stream<WeightStatus>? stream;
  Future<Weight>? stabilizedWeight;

  Future<void> _connectPrinter() async {
    setState(() {
      status = 'Finding Digital scale...';
    });

    await scale.connect();

    stream = scale.getWeightStream();
    setState(() {
      status = 'Digital scale connected';
    });
  }

  Future<void> _disconnectPrinter() async {
    setState(() {
      status = 'Disconnecting Digital scale...';
    });

    await scale.disconnect();

    setState(() {
      status = 'Digital scale disconnected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digital Scale Demo"),
      ),
      body: Column(children: [
        ElevatedButton(onPressed: _connectPrinter, child: Text('Connect')),
        Text(status),
        Text('Current Weight'),
        StreamBuilder<WeightStatus>(
          stream: stream,
          builder: (context, snapshot) => Text(
            '${snapshot.data}',
          ),
        ),
        ElevatedButton(
            onPressed: getStabilizedWeight, child: Text('Stabilized Weight')),
        FutureBuilder(
          future: stabilizedWeight,
          builder: (context, snapshot) => Text(
            '${snapshot.data}',
          ),
        ),
        ElevatedButton(onPressed: _connectPrinter, child: Text('Disconnect')),
      ]),
    );
  }

  void getStabilizedWeight() {
    setState(() {
      stabilizedWeight =
          scale.getStabilizedWeight(const Duration(seconds: 10));
    });
  }

  @override
  void dispose() {
    scale.disconnect();
  }
}
