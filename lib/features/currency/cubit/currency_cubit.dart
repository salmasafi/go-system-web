import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/currency/model/currency_model.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/services/endpoints.dart';
import '../../../core/utils/error_handler.dart';
part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(CurrencyInitial());

  //CreateCurrencyModel? currencyModel;
  List<CurrencyModel> allCurrencies = [];
  //CurrencyItem? selectedCurrency;

  Future<void> getCurrencies() async {
    emit(GetCurrenciesLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCurrencies,
      );

      if (response.statusCode == 200) {
        final model = CurrenciesResponse.fromJson(response.data);
        if (model.success == true && model.data.currencies.isNotEmpty) {
          emit(GetCurrenciesSuccess(model.data.currencies));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCurrenciesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCurrenciesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCurrenciesError(errorMessage));
    }
  }

  // Future<void> getCurrencyById(String CurrencyId) async {
  //   emit(GetCurrencyByIdLoading());
  //   try {
  //    // final token = CacheHelper.getData(key: 'token') as String?;
  //     final response = await DioHelper.getData(
  //       url: EndPoint.getCurrencyById(CurrencyId),
  //      // token: token,
  //     );

  //     if (response.statusCode == 200) {
  //       final json = response.data;
  //       if (json['success'] == true && json['data']?['Currency'] != null) {
  //         selectedCurrency = CurrencyItem.fromJson(json['data']['Currency']);
  //         emit(GetCurrencyByIdSuccess(selectedCurrency!));
  //       } else {
  //         final errorMessage = ErrorHandler.handleError(response);
  //         emit(GetCurrencyByIdError(errorMessage));
  //       }
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(GetCurrencyByIdError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(GetCurrencyByIdError(errorMessage));
  //   }
  // }

  // Future<void> createCurrency({
  //   required String name,
  //   required File imageFile,
  //   String? parentId,
  // }) async {
  //   emit(CreateCurrencyLoading());
  //   try {
  //     if (await imageFile.length() > 5 * 1024 * 1024) {
  //       emit(CreateCurrencyError('Image exceeds 5MB'));
  //       return;
  //     }

  //    // final token = CacheHelper.getData(key: 'token') as String?;
  //     final bytes = await imageFile.readAsBytes();
  //     final base64Image = base64Encode(bytes);

  //     final data = {
  //       'name': name,
  //       'image': base64Image,
  //       if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
  //     };

  //     final response = await DioHelper.postData(
  //       url: EndPoint.createCurrency,
  //       data: data,
  //       //token: token,
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       CurrencyModel = CreateCurrencyModel.fromJson(response.data);
  //       if (CurrencyModel?.success == true) {
  //         await getCurrency();
  //         emit(CreateCurrencySuccess(
  //           CurrencyModel?.data?.message ?? 'Currency created successfully',
  //         ));
  //       } else {
  //         final errorMessage = ErrorHandler.handleError(response);
  //         emit(CreateCurrencyError(errorMessage));
  //       }
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(CreateCurrencyError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(CreateCurrencyError(errorMessage));
  //   }
  // }

  // Future<void> updateCurrency({
  //   required String CurrencyId,
  //   required String name,
  //   File? imageFile,
  //   String? parentId,
  // }) async {
  //   emit(UpdateCurrencyLoading());
  //   try {
  //  //   final token = CacheHelper.getData(key: 'token') as String?;

  //     final data = <String, dynamic>{'name': name};

  //     if (imageFile != null) {
  //       if (await imageFile.length() > 5 * 1024 * 1024) {
  //         emit(UpdateCurrencyError('Image exceeds 5MB'));
  //         return;
  //       }
  //       final bytes = await imageFile.readAsBytes();
  //       data['image'] = base64Encode(bytes);
  //     }

  //     if (parentId != null && parentId.isNotEmpty) {
  //       data['parentId'] = parentId;
  //     }
  //     // Remove the else clause to avoid sending parentId: null

  //     final response = await DioHelper.putData(
  //       url: EndPoint.getCurrencyById(CurrencyId),
  //       data: data,
  //       //token: token,
  //     );

  //     if (response.statusCode == 200) {
  //       final model = CreateCurrencyModel.fromJson(response.data);
  //       if (model.success == true) {
  //         await getCurrency();
  //         emit(UpdateCurrencySuccess(
  //           model.data?.message ?? 'Currency updated successfully',
  //         ));
  //       } else {
  //         final errorMessage = ErrorHandler.handleError(response);
  //         emit(UpdateCurrencyError(errorMessage));
  //       }
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(UpdateCurrencyError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(UpdateCurrencyError(errorMessage));
  //   }
  // }

  // Future<void> deleteCurrency(String CurrencyId) async {
  //   emit(DeleteCurrencyLoading());
  //   try {
  //    // final token = CacheHelper.getData(key: 'token') as String?;

  //     final response = await DioHelper.deleteData(
  //       url: EndPoint.getCurrencyById(CurrencyId),
  //      // token: token,
  //     );

  //     if (response.statusCode == 200) {
  //       final model = DeleteCurrencyModel.fromJson(response.data);
  //       if (model.success == true) {
  //         allCurrency.removeWhere((Currency) => Currency.id == CurrencyId);
  //         parentCurrency.removeWhere((Currency) => Currency.id == CurrencyId);

  //         if (selectedCurrency?.id == CurrencyId) {
  //           selectedCurrency = null;
  //         }

  //         emit(DeleteCurrencySuccess(
  //           model.data?.message ?? 'Currency deleted successfully',
  //         ));
  //       } else {
  //         final errorMessage = ErrorHandler.handleError(response);
  //         emit(DeleteCurrencyError(errorMessage));
  //       }
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(DeleteCurrencyError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(DeleteCurrencyError(errorMessage));
  //   }
  // }

}