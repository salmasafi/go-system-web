import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/redeem_points/model/redeem_points_model.dart';
import 'package:GoSystem/features/admin/redeem_points/data/repositories/redeem_points_repository.dart';

part 'redeem_points_state.dart';

class RedeemPointsCubit extends Cubit<RedeemPointsState> {
  final RedeemPointsRepository _repository;
  RedeemPointsCubit(this._repository) : super(RedeemPointsInitial());

  List<RedeemPointsModel> allRedeemPoints = [];
  List<RedeemPointsModel> filteredRedeemPoints = [];

  // Get all redeem points
  Future<void> getRedeemPoints() async {
    emit(GetRedeemPointsLoading());
    try {
      final list = await _repository.getRedeemRules();
      allRedeemPoints = list;
      filteredRedeemPoints = List.from(allRedeemPoints);
      emit(GetRedeemPointsSuccess(filteredRedeemPoints));
    } catch (e) {
      emit(GetRedeemPointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Create new redeem points
  Future<void> createRedeemPoints({
    required double amount,
    required int points,
  }) async {
    emit(CreateRedeemPointsLoading());
    try {
      await _repository.createRedeemRule(
        RedeemPointsModel(id: '', amount: amount, points: points),
      );
      await getRedeemPoints(); // Refresh the list
      emit(CreateRedeemPointsSuccess('Redeem points created successfully'));
    } catch (e) {
      emit(GetRedeemPointsError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.updateRedeemRule(
        RedeemPointsModel(id: id, amount: amount, points: points),
      );
      await getRedeemPoints(); // Refresh the list
      emit(UpdateRedeemPointsSuccess('Redeem points updated successfully'));
    } catch (e) {
      emit(UpdateRedeemPointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Delete redeem points
  Future<void> deleteRedeemPoints(String id) async {
    emit(DeleteRedeemPointsLoading());
    try {
      await _repository.deleteRedeemRule(id);
      await getRedeemPoints(); // Refresh the list
      emit(DeleteRedeemPointsSuccess('Redeem points deleted successfully'));
    } catch (e) {
      emit(DeleteRedeemPointsError(e.toString().replaceAll('Exception: ', '')));
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
