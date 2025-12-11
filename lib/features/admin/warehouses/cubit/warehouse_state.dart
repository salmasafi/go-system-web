import 'package:systego/features/admin/warehouses/model/ware_house_model.dart';

abstract class WarehousesState {}

class WarehousesInitial extends WarehousesState {}

class WarehousesLoaded extends WarehousesState {
  final List<Warehouses> warehouses;
  WarehousesLoaded(this.warehouses);
}
class WarehousesError extends WarehousesState {
  final String message;
  WarehousesError(this.message);
}

class WarehousesLoading extends WarehousesState {}

class WarehousesSuccess extends WarehousesState {}

// Create States
class WarehouseCreating extends WarehousesState {}
class WarehouseCreated extends WarehousesState {}

// Update States
class WarehouseUpdating extends WarehousesState {}
class WarehouseUpdated extends WarehousesState {}

// Delete States
class WarehouseDeleting extends WarehousesState {}
class WarehouseDeleted extends WarehousesState {}