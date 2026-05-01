import '../../models/attribute_value_model.dart';

abstract class AttributeValueState {}

class AttributeValueInitial extends AttributeValueState {}

class AttributeValueLoading extends AttributeValueState {}

class AttributeValueLoaded extends AttributeValueState {
  final List<AttributeValue> attributeValues;

  AttributeValueLoaded(this.attributeValues);
}

class AttributeValueError extends AttributeValueState {
  final String message;

  AttributeValueError(this.message);
}

class AttributeValueCreating extends AttributeValueState {}

class AttributeValueCreated extends AttributeValueState {
  final String message;

  AttributeValueCreated(this.message);
}

class AttributeValueUpdating extends AttributeValueState {}

class AttributeValueUpdated extends AttributeValueState {
  final String message;

  AttributeValueUpdated(this.message);
}

class AttributeValueDeleting extends AttributeValueState {}

class AttributeValueDeleted extends AttributeValueState {
  final String message;

  AttributeValueDeleted(this.message);
}
