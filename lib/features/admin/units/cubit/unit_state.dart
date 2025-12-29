import 'package:systego/features/admin/units/model/unit_model.dart';

abstract class UnitsState {}

class UnitsInitial extends UnitsState {}

class UnitsLoading extends UnitsState {}

class UnitsSuccess extends UnitsState {
  final List<UnitModel> units;
  
  UnitsSuccess(this.units);
}

class UnitsError extends UnitsState {
  final String message;
  
  UnitsError(this.message);
}