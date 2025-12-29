import 'package:flutter_test/flutter_test.dart';
import 'package:netcut/features/groups/domain/app_group.dart';

void main() {
  test('AppGroup encodes/decodes a list round-trip', () {
    final original = <AppGroup>[
      const AppGroup(
        id: '1',
        name: 'Social',
        enabled: true,
        packageNames: ['com.a', 'com.b'],
      ),
      const AppGroup(id: '2', name: 'Games', enabled: false, packageNames: []),
    ];

    final raw = AppGroup.encodeList(original);
    final decoded = AppGroup.decodeList(raw);

    // Compare via maps to avoid “list identity” issues.
    expect(
      decoded.map((g) => g.toMap()).toList(),
      equals(original.map((g) => g.toMap()).toList()),
    );
  });

  test('AppGroup.fromMap converts packageNames to strings', () {
    final g = AppGroup.fromMap({
      'id': 'x',
      'name': 'Test',
      'enabled': true,
      'packageNames': [1, true, 'abc'],
    });

    expect(g.packageNames, equals(['1', 'true', 'abc']));
  });
}
