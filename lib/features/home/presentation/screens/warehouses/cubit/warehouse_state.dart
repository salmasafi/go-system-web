abstract class WarehousesState {}

class WarehousesInitial extends WarehousesState {}

class WarehousesLoaded extends WarehousesState {}

class WarehousesError extends WarehousesState {
  final String message;
  WarehousesError(this.message);
}

class WarehousesLoading extends WarehousesState {}

class WarehousesSuccess extends WarehousesState {}

