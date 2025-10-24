import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io' show Platform;

typedef c_average =
    ffi.Double Function(ffi.Pointer<ffi.Double> arr, ffi.Size len);
typedef dart_average = double Function(ffi.Pointer<ffi.Double> arr, int len);

final ffi.DynamicLibrary zaccLib = () {
  try {
    if (Platform.isAndroid) {
      print('Attempting to load zacc library for Android...');
      const libPath = 'libzacc.so';
      print('Library path: \$libPath');
      return ffi.DynamicLibrary.open(libPath);
    } else if (Platform.isIOS) {
      print('Attempting to load zacc library for iOS...');
      return ffi.DynamicLibrary.executable();
    } else if (Platform.isWindows) {
      print('Attempting to load zacc library for Windows...');
      const libPath = 'lib/native/windows/libzacc.dll';
      print('Library path: \$libPath');
      return ffi.DynamicLibrary.open(libPath);
    } else if (Platform.isLinux) {
      print('Attempting to load zacc library for Linux...');
      const libPath = 'lib/native/linux/libzacc.so';
      print('Library path: \$libPath');
      return ffi.DynamicLibrary.open(libPath);
    } else if (Platform.isMacOS) {
      print('Attempting to load zacc library for macOS...');
      const libPath = 'lib/native/macos/libzacc.dylib';
      print('Library path: \$libPath');
      return ffi.DynamicLibrary.open(libPath);
    }
  } catch (e) {
    print('Error loading library: \$e');
    rethrow;
  }
  throw UnsupportedError('This platform is not supported.');
}();

typedef c_count_peaks =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Double> arr,
      ffi.Size len,
      ffi.Double threshold,
      ffi.Size min_duration,
    );
typedef dart_count_peaks =
    int Function(
      ffi.Pointer<ffi.Double> arr,
      int len,
      double threshold,
      int min_duration,
    );

final dart_count_peaks countPeaksFFI = zaccLib
    .lookupFunction<c_count_peaks, dart_count_peaks>('count_peaks');

int countPeaks(List<double> values, double threshold, int min_duration) {
  final ptr = calloc<ffi.Double>(values.length);
  try {
    for (var i = 0; i < values.length; i++) {
      ptr[i] = values[i];
    }
    return countPeaksFFI(ptr, values.length, threshold, min_duration).toInt();
  } finally {
    malloc.free(ptr);
  }
}
