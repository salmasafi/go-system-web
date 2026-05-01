import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/attribute_value_model.dart';
import '../../data/repositories/attribute_repository.dart';
import 'attribute_value_state.dart';

class AttributeValueCubit extends Cubit<AttributeValueState> {
  final AttributeValueRepository _repository;
  String _currentAttributeTypeId = '';

  AttributeValueCubit(this._repository) : super(AttributeValueInitial());

  List<AttributeValue> get attributeValues => state is AttributeValueLoaded
      ? (state as AttributeValueLoaded).attributeValues
      : [];

  String get currentAttributeTypeId => _currentAttributeTypeId;

  static AttributeValueCubit get(context) => BlocProvider.of(context);

  Future<void> loadAttributeValues(String attributeTypeId) async {
    _currentAttributeTypeId = attributeTypeId;
    emit(AttributeValueLoading());
    try {
      final values = await _repository.getValuesByType(attributeTypeId);
      emit(AttributeValueLoaded(values));
    } catch (e) {
      emit(AttributeValueError(e.toString()));
    }
  }

  Future<void> createAttributeValue({
    required String attributeTypeId,
    required String name,
    required String arName,
    bool status = true,
  }) async {
    emit(AttributeValueCreating());
    try {
      final attributeValue = AttributeValue(
        id: '',
        attributeTypeId: attributeTypeId,
        name: name,
        arName: arName,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createAttributeValue(attributeValue);
      await loadAttributeValues(attributeTypeId);
      emit(AttributeValueCreated('Attribute value created successfully'));
    } catch (e) {
      final errorStr = e.toString();
      // Check for unique constraint violation
      if (errorStr.contains('unique') ||
          errorStr.contains('duplicate') ||
          errorStr.contains('already exists')) {
        emit(AttributeValueError(
          'Attribute value with this name already exists for this type',
        ));
      } else {
        emit(AttributeValueError(e.toString()));
      }
    }
  }

  Future<void> updateAttributeValue({
    required String id,
    required String name,
    required String arName,
    bool? status,
  }) async {
    emit(AttributeValueUpdating());
    try {
      final currentValues = attributeValues;
      final current = currentValues.firstWhere((v) => v.id == id);

      final updated = current.copyWith(
        name: name,
        arName: arName,
        status: status ?? current.status,
      );

      await _repository.updateAttributeValue(id, updated);
      await loadAttributeValues(_currentAttributeTypeId);
      emit(AttributeValueUpdated('Attribute value updated successfully'));
    } catch (e) {
      final errorStr = e.toString();
      // Check for unique constraint violation
      if (errorStr.contains('unique') ||
          errorStr.contains('duplicate') ||
          errorStr.contains('already exists')) {
        emit(AttributeValueError(
          'Attribute value with this name already exists for this type',
        ));
      } else {
        emit(AttributeValueError(e.toString()));
      }
    }
  }

  Future<void> deleteAttributeValue(String id) async {
    emit(AttributeValueDeleting());
    try {
      await _repository.deleteAttributeValue(id);
      await loadAttributeValues(_currentAttributeTypeId);
      emit(AttributeValueDeleted('Attribute value deleted successfully'));
    } catch (e) {
      final errorStr = e.toString();
      // Check for foreign key violation errors
      if (errorStr.contains('foreign key') ||
          errorStr.contains('violates') ||
          errorStr.contains('constraint') ||
          errorStr.contains('referenced')) {
        emit(AttributeValueError(
          'Cannot delete attribute value: it is linked to products',
        ));
      } else {
        emit(AttributeValueError(e.toString()));
      }
    }
  }
}
