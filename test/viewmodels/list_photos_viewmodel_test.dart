import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ListPhotosViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
