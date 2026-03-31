import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import '../model/points_model.dart';
import 'points_state.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit() : super(PointsInitial());

  List<PointsModel> points = [];
  List<PointsModel> _filtered = [];
  String _searchQuery = '';

  List<PointsModel> get displayed =>
      _searchQuery.isEmpty ? points : _filtered;

  Future<void> getPoints() async {
    emit(GetPointsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getPoints);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = PointsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        points = data.data.points;
        _applySearch();
        emit(GetPointsSuccess(displayed));
      } else {
        emit(GetPointsError(
          response.data['message']?.toString() ?? 'Failed to load points',
        ));
      }
    } catch (e) {
      emit(GetPointsError(e.toString()));
    }
  }

  Future<void> createPoints({
    required double amount,
    required int points,
  }) async {
    emit(CreatePointsLoading());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addPoint,
        data: {
          'amount': amount,
          'points': points,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreatePointsSuccess('Points created successfully'));
        await getPoints();
      } else {
        emit(CreatePointsError(
          response.data['message']?.toString() ?? 'Failed to create points',
        ));
      }
    } catch (e) {
      emit(CreatePointsError(e.toString()));
    }
  }

  Future<void> updatePoints({
    required String id,
    required double amount,
    required int points,
  }) async {
    emit(UpdatePointsLoading());
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.updatePoint}/$id',
        data: {
          'amount': amount,
          'points': points,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UpdatePointsSuccess('Points updated successfully'));
        await getPoints();
      } else {
        emit(UpdatePointsError(
          response.data['message']?.toString() ?? 'Failed to update points',
        ));
      }
    } catch (e) {
      emit(UpdatePointsError(e.toString()));
    }
  }

  Future<void> deletePoints(String id) async {
    emit(DeletePointsLoading());
    try {
      final response = await DioHelper.deleteData(url: '${EndPoint.deletePoint}/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DeletePointsSuccess('Points deleted successfully'));
        await getPoints();
      } else {
        emit(DeletePointsError(
          response.data['message']?.toString() ?? 'Failed to delete points',
        ));
      }
    } catch (e) {
      emit(DeletePointsError(e.toString()));
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
