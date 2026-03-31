import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/units/model/units_model.dart';
import '../../../../../generated/locale_keys.g.dart';

part 'units_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  UnitsCubit() : super(UnitsInitial());

  List<UnitModel> allUnits = [];

  Future<void> getUnits() async {
    emit(GetUnitsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getUnits);
      log(response.data.toString());
      if (response.statusCode == 200) {
        final model = UnitsResponse.fromJson(response.data);
        if (model.success == true) {
          emit(GetUnitsSuccess(model.data.units));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetUnitsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetUnitsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetUnitsError(errorMessage));
    }
  }

  Future<void> changeUnitStatus(String unitId, String name, bool status) async {
    emit(ChangeUnitStatusLoading());
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.getUnits}/$unitId',
        data: {'status': status},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          ChangeUnitStatusSuccess(
            '$name ${status ? LocaleKeys.activated_successfully.tr() : LocaleKeys.deactivated_successfully.tr()}',
          ),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(ChangeUnitStatusError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(ChangeUnitStatusError(errorMessage));
    }
  }

  Future<void> createUnit({
    required String name,
    required String arName,
    required String code,
    String? baseUnit,
    required String operator,
    required double operatorValue,
    required bool isBaseUnit,
    required bool status,
  }) async {
    emit(CreateUnitLoading());
    try {
      final data = {
        'name': name,
        'ar_name': arName,
        'code': code,
        if (baseUnit != null) 'base_unit': baseUnit,
        'operator': operator,
        'operator_value': operatorValue,
        'is_base_unit': isBaseUnit,
        'status': status,
      };

      final response = await DioHelper.postData(
        url: EndPoint.getUnits,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateUnitSuccess(LocaleKeys.unit_created_successfully.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateUnitError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateUnitError(errorMessage));
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
    required bool isBaseUnit,
    required bool status,
  }) async {
    emit(UpdateUnitLoading());
    try {
      final data = {
        'name': name,
        'ar_name': arName,
        'code': code,
        if (baseUnit != null) 'base_unit': baseUnit,
        'operator': operator,
        'operator_value': operatorValue,
        'is_base_unit': isBaseUnit,
        'status': status,
      };

      final response = await DioHelper.putData(
        url: '${EndPoint.getUnits}/$unitId',
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateUnitSuccess(LocaleKeys.unit_updated_successfully.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateUnitError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateUnitError(errorMessage));
    }
  }

  Future<void> deleteUnit(String unitId) async {
    emit(DeleteUnitLoading());
    try {
      final response = await DioHelper.deleteData(
        url: '${EndPoint.getUnits}/$unitId',
      );

      if (response.statusCode == 200) {
        allUnits.removeWhere((unit) => unit.id == unitId);
        emit(DeleteUnitSuccess('Unit deleted successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteUnitError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteUnitError(errorMessage));
    }
  }
}
