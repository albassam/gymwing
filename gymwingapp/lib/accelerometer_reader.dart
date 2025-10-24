import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A simple wrapper of sensors-plus
class AccelerometerReader {
  final Duration samplingPeriod;

  static final AccelerometerReader instance = AccelerometerReader();

  /// Constructor allows setting sampling rate, default is 50ms (20Hz)
  AccelerometerReader({this.samplingPeriod = const Duration(milliseconds: 50)});

  /// The underlying stream from sensors_plus. Emits SensorEvent-like triples
  /// (x, y, z) in m/s^2.
  Stream<AccelerometerEvent> get stream =>
      accelerometerEventStream(samplingPeriod: samplingPeriod);

  Stream<List<double>> get vectorStream => stream.map((e) => [e.x, e.y, e.z]);

  /// Check and request sensor permissions if needed
  Future<bool> requestSensorPermission() async {
    if (await Permission.sensors.status.isDenied) {
      final status = await Permission.sensors.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> hasAccelerometer({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    try {
      final completer = Completer<bool>();
      final sub = stream.listen(
        (event) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      final result = await completer.future.timeout(
        timeout,
        onTimeout: () => false,
      );
      await sub.cancel();
      return result;
    } catch (_) {
      return false;
    }
  }
}

/// A small demo widget that shows live accelerometer values.
/// for debugging purposes.
class AccelerometerWidget extends StatefulWidget {
  final TextStyle? style;
  final Duration updateInterval;

  const AccelerometerWidget({
    Key? key,
    this.style,
    this.updateInterval = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<AccelerometerWidget> createState() => _AccelerometerWidgetState();
}

class _AccelerometerWidgetState extends State<AccelerometerWidget> {
  late StreamSubscription<List<double>> _sub;
  List<double> _vec = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    // Throttle updates to a reasonable rate to avoid UI jank.
    _sub = AccelerometerReader.instance.vectorStream
        .transform(_ThrottleStreamTransformer(widget.updateInterval))
        .listen((v) {
          setState(() => _vec = v);
        });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style ?? const TextStyle(fontSize: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accelerometer (m/s²):',
          style: s.copyWith(fontWeight: FontWeight.bold),
        ),
        Text('x: ${_vec[0].toStringAsFixed(3)}', style: s),
        Text('y: ${_vec[1].toStringAsFixed(3)}', style: s),
        Text('z: ${_vec[2].toStringAsFixed(3)}', style: s),
      ],
    );
  }
}

/// A simple stream transformer that throttles events to at most one event per
/// [duration] by dropping intermediate events.
/// This is to be used in the UI component only not for the actual analytics
class _ThrottleStreamTransformer<T> implements StreamTransformer<T, T> {
  final Duration duration;
  _ThrottleStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamController<T> controller;
    Timer? timer;
    T? latest;
    bool hasLatest = false;

    void emitLatest() {
      if (hasLatest) {
        controller.add(latest as T);
        hasLatest = false;
        latest = null;
        timer = Timer(duration, emitLatest);
      } else {
        timer = null;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        controller.onCancel;
        stream.listen(
          (event) {
            if (timer == null) {
              controller.add(event);
              timer = Timer(duration, emitLatest);
            } else {
              latest = event;
              hasLatest = true;
            }
          },
          onError: controller.addError,
          onDone: controller.close,
          cancelOnError: false,
        );
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom(this);
}
