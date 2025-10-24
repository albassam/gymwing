/// Web implementation of the accelerometer binding.
///
/// This implementation uses pure-Dart fallbacks and does not depend on
/// any web-specific APIs.

/// Count peaks (simple implementation):
/// - A peak is a sample that is greater than its immediate neighbors and
///   above the provided [threshold].
/// - After detecting a peak, skip forward by [minDuration] samples to avoid
///   counting the same event multiple times.
int countPeaks(List<double> values, double threshold, int minDuration) {
  if (values.length < 3) return 0;
  var count = 0;
  var i = 1; // start at second sample to allow checking neighbors
  while (i < values.length - 1) {
    if (values[i] > threshold &&
        values[i] > values[i - 1] &&
        values[i] > values[i + 1]) {
      count++;
      i += (minDuration > 0 ? minDuration : 1);
    } else {
      i++;
    }
  }
  return count;
}
