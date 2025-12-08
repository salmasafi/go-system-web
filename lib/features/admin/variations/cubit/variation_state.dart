part of 'variation_cubit.dart';

@immutable
sealed class VariationState {}

final class VariationInitial extends VariationState {}

// Fetch all variations
final class GetVariationsLoading extends VariationState {}

final class GetVariationsSuccess extends VariationState {
  final List<VariationModel> variations;
  GetVariationsSuccess(this.variations);
}

final class GetVariationsError extends VariationState {
  final String error;
  GetVariationsError(this.error);
}

// Fetch variation by ID
final class GetVariationByIdLoading extends VariationState {}

final class GetVariationByIdSuccess extends VariationState {
  final VariationModel variation;
  GetVariationByIdSuccess(this.variation);
}

final class GetVariationByIdError extends VariationState {
  final String error;
  GetVariationByIdError(this.error);
}

// Create variation
final class CreateVariationLoading extends VariationState {}

final class CreateVariationSuccess extends VariationState {
  final String message;
  CreateVariationSuccess(this.message);
}

final class CreateVariationError extends VariationState {
  final String error;
  CreateVariationError(this.error);
}

// Update variation
final class UpdateVariationLoading extends VariationState {}

final class UpdateVariationSuccess extends VariationState {
  final String message;
  UpdateVariationSuccess(this.message);
}

final class UpdateVariationError extends VariationState {
  final String error;
  UpdateVariationError(this.error);
}

// Delete variation
final class DeleteVariationLoading extends VariationState {}

final class DeleteVariationSuccess extends VariationState {
  final String message;
  DeleteVariationSuccess(this.message);
}

final class DeleteVariationError extends VariationState {
  final String error;
  DeleteVariationError(this.error);
}


final class DeleteOptionLoading extends VariationState {}

final class DeleteOptionSuccess extends VariationState {
  final String message;
  DeleteOptionSuccess(this.message);
}

final class DeleteOptionError extends VariationState {
  final String error;
  DeleteOptionError(this.error);
}
