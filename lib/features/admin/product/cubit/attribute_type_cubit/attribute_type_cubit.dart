import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/attribute_type_model.dart';
import '../../data/repositories/attribute_repository.dart';
import 'attribute_type_state.dart';

class AttributeTypeCubit extends Cubit<AttributeTypeState> {
  final AttributeTypeRepository _repository;

  AttributeTypeCubit(this._repository) : super(AttributeTypeInitial());

  List<AttributeType> get attributeTypes => state is AttributeTypeLoaded
      ? (state as AttributeTypeLoaded).attributeTypes
      : [];

  static AttributeTypeCubit get(context) => BlocProvider.of(context);

  Future<void> loadAttributeTypes() async {
    emit(AttributeTypeLoading());
    try {
      final types = await _repository.getAllAttributeTypes();
      emit(AttributeTypeLoaded(types));
    } catch (e) {
      emit(AttributeTypeError(e.toString()));
    }
  }

  Future<void> createAttributeType({
    required String name,
    bool status = true,
  }) async {
    emit(AttributeTypeCreating());
    try {
      final attributeType = AttributeType(
        id: '',
        name: name,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createAttributeType(attributeType);
      await loadAttributeTypes();
      emit(AttributeTypeCreated('Attribute type created successfully'));
    } catch (e) {
      emit(AttributeTypeError(e.toString()));
    }
  }

  Future<void> updateAttributeType({
    required String id,
    required String name,
    bool? status,
  }) async {
    emit(AttributeTypeUpdating());
    try {
      final currentTypes = attributeTypes;
      final current = currentTypes.firstWhere((t) => t.id == id);

      final updated = current.copyWith(
        name: name,
        status: status ?? current.status,
      );

      await _repository.updateAttributeType(id, updated);
      await loadAttributeTypes();
      emit(AttributeTypeUpdated('Attribute type updated successfully'));
    } catch (e) {
      emit(AttributeTypeError(e.toString()));
    }
  }

  Future<void> deleteAttributeType(String id) async {
    emit(AttributeTypeDeleting());
    try {
      await _repository.deleteAttributeType(id);
      await loadAttributeTypes();
      emit(AttributeTypeDeleted('Attribute type deleted successfully'));
    } catch (e) {
      final errorStr = e.toString();
      // Check for foreign key violation errors
      if (errorStr.contains('foreign key') ||
          errorStr.contains('violates') ||
          errorStr.contains('constraint') ||
          errorStr.contains('referenced')) {
        emit(AttributeTypeError(
          'Cannot delete attribute type: it is linked to attribute values or products',
        ));
      } else {
        emit(AttributeTypeError(e.toString()));
      }
    }
  }
}
