import 'package:pewpew_connect/service/imports.dart';

class PerformanceService {
  PerformanceService._();

  static final PerformanceService instance = PerformanceService._();

  Future<Trace?> startTrace(String name) async {
    final allowed = await ConsentService.instance.isAllowed();
    if (!allowed) return null;
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();
    return trace;
  }

  Future<void> stopTrace(Trace? trace) async {
    if (trace == null) return;
    await trace.stop();
  }

  Future<void> setCollectionEnabled(bool enabled) async {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(enabled);
  }
}
