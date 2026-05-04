import 'package:flutter_test/flutter_test.dart';

Matcher hasLengthInt(int n) => predicate<List>((l) => l.length == n, 'length == $n');