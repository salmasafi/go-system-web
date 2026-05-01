part of 'label_cubit.dart';

abstract class LabelState {}

class LabelInitial extends LabelState {}

// Triggered when quantity or toggle changes to rebuild UI
class LabelDataUpdated extends LabelState {}

class GenerateLabelsLoading extends LabelState {}

class GenerateLabelsSuccess extends LabelState {
  final String message;
  GenerateLabelsSuccess(this.message);
}

class GenerateLabelsError extends LabelState {
  final String error;
  GenerateLabelsError(this.error);
}
