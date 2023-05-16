import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

class CheckThenWidget extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String input1) async {
    final widget1 = find.byValueKey(input1);

    bool widget1Exists =
    await FlutterDriverUtils.isPresent(world.driver, widget1);

    expect(widget1Exists, true);
  }

  @override
  RegExp get pattern => RegExp(r"I have {string} on screen");
}

class CheckGivenWidgets
    extends Given3WithWorld<String,String,String,FlutterWorld> {
  @override
  Future<void> executeStep(String input1, String input2, String input3) async {
// TODO: implement executeStep
    final textinput1 = find.byValueKey(input1);
    final textinput2 = find.byValueKey(input2);
    final button = find.byValueKey(input3);
    bool input1Exists = await FlutterDriverUtils.isPresent(world.driver, textinput1);
    bool input2Exists = await FlutterDriverUtils.isPresent(world.driver,textinput2);
    bool buttonExists = await FlutterDriverUtils.isPresent(world.driver, button);
    expect(input1Exists, true);
    expect(input2Exists, true);
    expect(buttonExists, true);
  }
  @override
// TODO: implement pattern
  RegExp get pattern => RegExp(r"I have {string} and {string} and {string}");
}

/*
class ClickButton extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String btn) async {
// TODO: implement executeStep
    final finder = find.byValueKey(btn);
    await FlutterDriverUtils.tap(world.driver, finder);
  }
  @override
  RegExp get pattern => RegExp(r"I tap the {string} button");
} */
/*
class ClickRegisterLink extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String registerlink) async {
    final registerfinder = find.byValueKey(registerlink);
    await FlutterDriverUtils.tap(world.driver, registerfinder);
  }

  @override
  // TODO: implement pattern
  Pattern get pattern => RegExp("I tap the {string} link");
}
*/