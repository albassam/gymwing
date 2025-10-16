import 'package:flutter/material.dart';
import 'dart:async';
import 'zacc_binding.dart';
import 'accelerometer_reader.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum ExerciseConcentricity { unknown, concentric, eccentric }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymWing',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: 'Exercise Overview'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  ExerciseConcentricity _concentricity = ExerciseConcentricity.unknown;
  double _average = 0.0;
  final List<double> _values = [];
  StreamSubscription<List<double>>? _accelSub;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _accelSub = AccelerometerReader.instance.vectorStream.listen((vector) {
      setState(() {
        _values.add(vector[2]); // z acceleration
        _average = averageFromList(_values);
        _updateConcentricity(_average);
      });
    });
  }

  void _updateConcentricity(double average) {
    ExerciseConcentricity newConcentricity;
    if (average > 0.5) {
      newConcentricity = ExerciseConcentricity.concentric;
    } else if (average < -0.5) {
      newConcentricity = ExerciseConcentricity.eccentric;
    } else {
      newConcentricity = ExerciseConcentricity.unknown;
    }

    if (newConcentricity != _concentricity) {
      setState(() {
        _concentricity = newConcentricity;
        if (_concentricity != ExerciseConcentricity.unknown) {
          _speak(_concentricity.toString().split('.').last);
        }
      });
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Reps: ${_counter.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Exercise Concentricity: ${_concentricity.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const AccelerometerWidget(),
          ],
        ),
      ),
    );
  }
}
