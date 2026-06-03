import 'package:flutter_test/flutter_test.dart';

import 'package:neno/data/models/movement.dart';

void main() {
  test('Movement equality uses all fields', () {
    const ts = null;
    final date = DateTime(2025, 1, 1, 10, 30);
    final m1 = Movement(id: '1', timestamp: date, notes: ts, intensity: 2);
    final m2 = Movement(id: '1', timestamp: date, notes: ts, intensity: 2);
    final m3 = Movement(id: '2', timestamp: date);
    expect(m1, equals(m2));
    expect(m1, isNot(equals(m3)));
  });
}
