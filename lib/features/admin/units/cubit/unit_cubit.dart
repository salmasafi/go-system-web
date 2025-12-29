import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/units/model/unit_model.dart';
import 'unit_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  UnitsCubit() : super(UnitsInitial());

  static UnitsCubit get(context) => BlocProvider.of(context);

  List<UnitModel> _units = [];
  List<UnitModel> get units => _units;

  Future<void> getUnits() async {
    emit(UnitsLoading());

    try {
      log('Starting units request...');

      final response = await DioHelper.getData(url: EndPoint.getUnits);

      log('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final unitResponse = UnitResponse.fromJson(data);
          _units = unitResponse.data.units;
          
          log('Units fetch successful: ${_units.length} units loaded');
          emit(UnitsSuccess(_units));
        } else {
          final errorMessage = data['message'] ?? 'Failed to fetch units';
          log('Units fetch failed: $errorMessage');
          emit(UnitsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(UnitsError(errorMessage));
      }
    } catch (error) {
      log('Units fetch error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(UnitsError(errorMessage));
    }
  }

}