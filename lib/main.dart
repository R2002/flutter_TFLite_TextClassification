import 'package:flutter/material.dart';
import 'package:sandbox/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Classifier _classifier = Classifier();
  String _text = 'I liked the movie.';
  int? _class;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Classification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                initialValue: _text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input Text',
                ),
                onChanged: (String value) {
                  setState(() {
                    _text = value;
                  });
                },
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Check(1:Positive, 0:Negative)'),
                  onPressed: () {
                    calcTest();
                  },
                ),
              ),
              Text('Type: $_class'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void calcTest() {
    setState(() {
      _class = _classifier.classify(_text);
    });
    print('(calc)$_text => $_class');
  }
}
