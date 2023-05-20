import 'dart:async';

import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';
import 'steps/test_steps.dart';


Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [Glob(r"test_driver/features/Acceptance_Tests.feature")]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      JsonReporter(path: './report.json')
    ]
    ..stepDefinitions = [CheckGivenWidgets(), CheckThenWidget(), HaveContains2(), SelectFromDropdown()]
    ..restartAppBetweenScenarios = true
    ..targetAppPath = "test_driver/app.dart";
  return GherkinRunner().execute(config);
}