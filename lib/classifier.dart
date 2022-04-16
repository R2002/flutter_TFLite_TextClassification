import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  final _modelFile = 'text_classification.tflite';
  final _vocabFile = 'text_classification_vocab.txt';
  Map<String, int>? _dict;
  Interpreter? _interpreter;

  // Maximum length of sentence
  final int _sentenceLen = 256;
  final String start = '<START>';
  final String pad = '<PAD>';
  final String unk = '<UNKNOWN>';

  Classifier() {
    print('Classifier Set Start');
    _loadDictionary();
    _loadModel();
  }

  void _loadDictionary() async {
    final vocab = await rootBundle.loadString('assets/$_vocabFile');
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    _dict = dict;
    print('Dictionary loaded successfully');
  }

  void _loadModel() async {
    _interpreter = await Interpreter.fromAsset(_modelFile);
    print('Interpreter loaded successfully');
  }

  List<List<double>> tokenizeInputText(String text) {
    // Whitespace tokenization
    final toks = text.split(' ');

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<double>.filled(_sentenceLen, _dict![pad]!.toDouble());

    var index = 0;
    if (_dict!.containsKey(start)) {
      vec[index++] = _dict![start]!.toDouble();
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in toks) {
      if (index > _sentenceLen) {
        break;
      }
      vec[index++] = _dict!.containsKey(tok)
          ? _dict![tok]!.toDouble()
          : _dict![unk]!.toDouble();
    }

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    return [vec];
  }

  int classify(String rawText) {
    // tokenizeInputText returns List<List<double>>
    // of shape [1, 256].
    List<List<double>> input = tokenizeInputText(rawText);

    // output of shape [1,2].
    var output = List.filled(2, 0.0).reshape([1, 2]);

    // The run method will run inference and
    // store the resulting values in output.
    _interpreter?.run(input, output);

    var result = 0;
    // If value of first element in output is greater than second,
    // then sentece is negative

    if ((output[0][0] as double) > (output[0][1] as double)) {
      result = 0;
    } else {
      result = 1;
    }
    return result;
  }
}
