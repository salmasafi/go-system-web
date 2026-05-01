import '../../models/attribute_type_model.dart';

abstract class AttributeTypeState {}

class AttributeTypeInitial extends AttributeTypeState {}

class AttributeTypeLoading extends AttributeTypeState {}

class AttributeTypeLoaded extends AttributeTypeState {
  final List<AttributeType> attributeTypes;

  AttributeTypeLoaded(this.attributeTypes);
}

class AttributeTypeError extends AttributeTypeState {
  final String message;

  AttributeTypeError(this.message);
}

class AttributeTypeCreating extends AttributeTypeState {}

class AttributeTypeCreated extends AttributeTypeState {
  final String message;

  AttributeTypeCreated(this.message);
}

class AttributeTypeUpdating extends AttributeTypeState {}

class AttributeTypeUpdated extends AttributeTypeState {
  final String message;

  AttributeTypeUpdated(this.message);
}

class AttributeTypeDeleting extends AttributeTypeState {}

class AttributeTypeDeleted extends AttributeTypeState {
  final String message;

  AttributeTypeDeleted(this.message);
}
