/// Web implementation of the accelerometer binding
double averageFromList(List<double> values) {
  if (values.isEmpty) return 0;
  // For web, we'll implement the average calculation in Dart
  // You could also call a JavaScript implementation if needed
  return values.reduce((a, b) => a + b) / values.length;
}
