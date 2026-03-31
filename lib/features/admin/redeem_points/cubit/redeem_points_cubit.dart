import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/redeem_points/model/redeem_points_model.dart';
part 'redeem_points_state.dart';

class RedeemPointsCubit extends Cubit<RedeemPointsState> {
  RedeemPointsCubit() : super(RedeemPointsInitial());

  List<RedeemPointsModel> allRedeemPoints = [];
  List<RedeemPointsModel> filteredRedeemPoints = [];

  // Get all redeem points
  Future<void> getRedeemPoints() async {
    emit(GetRedeemPointsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.redeemPoints);
      if (response.statusCode == 200) {
        final data = response.data['data']['points'] as List;
        allRedeemPoints = data.map((e) => RedeemPointsModel.fromJson(e)).toList();
        filteredRedeemPoints = List.from(allRedeemPoints);
        emit(GetRedeemPointsSuccess(filteredRedeemPoints));
      } else {
        emit(GetRedeemPointsError('Failed to load redeem points'));
      }
    } catch (e) {
      final msg = ErrorHandler.handleError(e);
      emit(GetRedeemPointsError(msg));
    }
  }

  // Create new redeem points
  Future<void> createRedeemPoints({
    required double amount,
    required int points,
  }) async {
    emit(CreateRedeemPointsLoading());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.redeemPoints,
        data: {
          'amount': amount,
          'points': points,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['data']['message'] ?? 'Redeem points created successfully';
        await getRedeemPoints(); // Refresh the list
        emit(CreateRedeemPointsSuccess(message));
      } else {
        emit(CreateRedeemPointsError('Failed to create redeem points'));
      }
    } catch (e) {
      final msg = ErrorHandler.handleError(e);
      emit(CreateRedeemPointsError(msg));
    }
  }

  // Update redeem points
  Future<void> updateRedeemPoints({
    required String id,
    required double amount,
    required int points,
  }) async {
    emit(UpdateRedeemPointsLoading());
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.redeemPoints}/$id',
        data: {
          'amount': amount,
          'points': points,
        },
      );
      if (response.statusCode == 200) {
        final message = response.data['data']['message'] ?? 'Redeem points updated successfully';
        await getRedeemPoints(); // Refresh the list
        emit(UpdateRedeemPointsSuccess(message));
      } else {
        emit(UpdateRedeemPointsError('Failed to update redeem points'));
      }
    } catch (e) {
      final msg = ErrorHandler.handleError(e);
      emit(UpdateRedeemPointsError(msg));
    }
  }

  // Delete redeem points
  Future<void> deleteRedeemPoints(String id) async {
    emit(DeleteRedeemPointsLoading());
    try {
      final response = await DioHelper.deleteData(url: '${EndPoint.redeemPoints}/$id');
      if (response.statusCode == 200) {
        final message = response.data['data']['message'] ?? 'Redeem points deleted successfully';
        await getRedeemPoints(); // Refresh the list
        emit(DeleteRedeemPointsSuccess(message));
      } else {
        emit(DeleteRedeemPointsError('Failed to delete redeem points'));
      }
    } catch (e) {
      final msg = ErrorHandler.handleError(e);
      emit(DeleteRedeemPointsError(msg));
    }
  }

  // Search functionality
  void search(String query) {
    if (query.isEmpty) {
      filteredRedeemPoints = List.from(allRedeemPoints);
    } else {
      filteredRedeemPoints = allRedeemPoints.where((redeemPoint) {
        return redeemPoint.amount.toString().contains(query.toLowerCase()) ||
               redeemPoint.points.toString().contains(query.toLowerCase());
      }).toList();
    }
    
    if (state is GetRedeemPointsSuccess) {
      emit(GetRedeemPointsSuccess(filteredRedeemPoints));
    }
  }
}
