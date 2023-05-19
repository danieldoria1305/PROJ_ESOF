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

class SelectFromDropdown extends When2WithWorld<String, String, FlutterWorld> {
  @override
  Future<void> executeStep(String input1, String input2) async {
    final optioninput = find.text(input1);
    final dropdowninput = find.byValueKey(input2);
    bool dropdownExists = await FlutterDriverUtils.isPresent(world.driver, dropdowninput);
    expect(dropdownExists, true);
    await FlutterDriverUtils.tap(world.driver, dropdowninput);
    bool optionExists = await FlutterDriverUtils.isPresent(world.driver, optioninput);
    expect(optionExists, true);
    await FlutterDriverUtils.tap(world.driver, optioninput);
  }
  @override
  RegExp get pattern => RegExp(r"I select the option {string} from the {string} dropdown");
}

class HaveContains2 extends Given2WithWorld<String, String, FlutterWorld> {
  @override
  Future<void> executeStep(String input1, String input2) async {
    final widget = find.byValueKey(input1);
    final text = find.text(input2);
    bool widgetExists = await FlutterDriverUtils.isPresent(world.driver, widget);
    expect(widgetExists, true);
    bool text1Exists = await FlutterDriverUtils.isPresent(world.driver, text);
    expect(text1Exists, true);
  }
  @override
  RegExp get pattern => RegExp(r"I have a {string} that contains the text {string}");
}


