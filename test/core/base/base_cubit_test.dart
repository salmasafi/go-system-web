import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class BaseCubitTest<C extends Cubit<Object?>> {
  late C cubit;

  C createCubit();
  void testInitialState();

  void defineTests() {
    setUp(() => cubit = createCubit());
    tearDown(() async => cubit.close());
  }
}