abstract class SupplierStates {}

class SupplierInitial extends SupplierStates {}

class SupplierLoading extends SupplierStates {}

class SupplierSuccess extends SupplierStates {}

class SupplierDetailSuccess extends SupplierStates {}

class SupplierError extends SupplierStates {
  final String message;

  SupplierError(this.message);
}