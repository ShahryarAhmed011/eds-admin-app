/// Simulated latency for dummy data sources until real APIs land.
Future<void> dummyDelay([
  Duration duration = const Duration(milliseconds: 350),
]) => Future<void>.delayed(duration);
