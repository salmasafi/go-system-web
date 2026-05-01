import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/points_model.dart';
import 'points_state.dart';

import 'package:systego/features/admin/points/data/repositories/points_repository.dart';

class PointsCubit extends Cubit<PointsState> {
  final PointsRepository _repository;
  PointsCubit(this._repository) : super(PointsInitial());

  List<PointsModel> points = [];
  List<PointsModel> _filtered = [];
  String _searchQuery = '';

  List<PointsModel> get displayed =>
      _searchQuery.isEmpty ? points : _filtered;

  Future<void> getPoints() async {
    emit(GetPointsLoading());
    try {
      final list = await _repository.getPointsRules();
      points = list;
      _applySearch();
      emit(GetPointsSuccess(displayed));
    } catch (e) {
      emit(GetPointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createPoints({
    required double amount,
    required int points,
  }) async {
    emit(CreatePointsLoading());
    try {
      await _repository.createPointsRule(PointsModel(
        id: '',
        amount: amount,
        points: points,
      ));
      emit(CreatePointsSuccess('Points created successfully'));
      await getPoints();
    } catch (e) {
      emit(CreatePointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePoints({
    required String id,
    required double amount,
    required int points,
  }) async {
    emit(UpdatePointsLoading());
    try {
      await _repository.updatePointsRule(PointsModel(
        id: id,
        amount: amount,
        points: points,
      ));
      emit(UpdatePointsSuccess('Points updated successfully'));
      await getPoints();
    } catch (e) {
      emit(UpdatePointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePoints(String id) async {
    emit(DeletePointsLoading());
    try {
      await _repository.deletePointsRule(id);
      emit(DeletePointsSuccess('Points deleted successfully'));
      await getPoints();
    } catch (e) {
      emit(DeletePointsError(e.toString().replaceAll('Exception: ', '')));
    }
  }


  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    emit(GetPointsSuccess(displayed));
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filtered = [];
      return;
    }
    _filtered = points.where((p) {
      return p.amount.toString().contains(_searchQuery) ||
          p.points.toString().contains(_searchQuery);
    }).toList();
  }
}
