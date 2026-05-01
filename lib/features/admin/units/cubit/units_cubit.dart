import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';
import '../../../../../generated/locale_keys.g.dart';

import 'package:GoSystem/features/admin/units/data/repositories/unit_repository.dart';

part 'units_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  final UnitRepository _repository;
  UnitsCubit(this._repository) : super(UnitsInitial());

  List<UnitModel> allUnits = [];

  Future<void> getUnits() async {
    emit(GetUnitsLoading());
    try {
      final units = await _repository.getAllUnits();
      allUnits = units;
      emit(GetUnitsSuccess(units));
    } catch (e) {
      emit(GetUnitsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> changeUnitStatus(String unitId, String name, bool status) async {
    emit(ChangeUnitStatusLoading());
    try {
      await _repository.updateUnitStatus(unitId, status);
      emit(
        ChangeUnitStatusSuccess(
          '$name ${status ? LocaleKeys.activated_successfully.tr() : LocaleKeys.deactivated_successfully.tr()}',
        ),
      );
      await getUnits();
    } catch (e) {
      emit(ChangeUnitStatusError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createUnit({
    required String name,
    required String arName,
    required String code,
    String? baseUnit,
    required String operator,
    required double operatorValue,
    required bool status,
  }) async {
    emit(CreateUnitLoading());
    try {
      await _repository.createUnit(
        name: name,
        arName: arName,
        code: code,
        baseUnitId: baseUnit,
        operator: operator,
        operatorValue: operatorValue,
      );
      emit(CreateUnitSuccess(LocaleKeys.unit_created_successfully.tr()));
      await getUnits();
    } catch (e) {
      emit(CreateUnitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateUnit({
    required String unitId,
    required String name,
    required String arName,
    required String code,
    String? baseUnit,
    required String operator,
    required double operatorValue,
    required bool status,
  }) async {
    emit(UpdateUnitLoading());
    try {
      await _repository.updateUnit(
        id: unitId,
        name: name,
        arName: arName,
        code: code,
        baseUnitId: baseUnit,
        operator: operator,
        operatorValue: operatorValue,
      );
      emit(UpdateUnitSuccess(LocaleKeys.unit_updated_successfully.tr()));
      await getUnits();
    } catch (e) {
      emit(UpdateUnitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteUnit(String unitId) async {
    emit(DeleteUnitLoading());
    try {
      await _repository.deleteUnit(unitId);
      allUnits.removeWhere((unit) => unit.id == unitId);
      emit(DeleteUnitSuccess('Unit deleted successfully'));
    } catch (e) {
      emit(DeleteUnitError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
