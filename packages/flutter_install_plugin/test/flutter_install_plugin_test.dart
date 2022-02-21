import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_install_plugin/flutter_install_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_install_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('gotoAppStore', () async {
    expect(await FlutterInstallPlugin.gotoAppStore, '42');
  });
}
