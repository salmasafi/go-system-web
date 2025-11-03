import 'package:systego/features/admin/brands/model/get_brand_by_id_model.dart';

abstract class BrandsState {}

class BrandsInitial extends BrandsState {}

// Get Brands States
class GetBrandsLoading extends BrandsState {}

class GetBrandsSuccess extends BrandsState {
  final List<dynamic> brands;
  GetBrandsSuccess(this.brands);
}

class GetBrandsError extends BrandsState {
  final String error;
  GetBrandsError(this.error);
}

// Create Brand States
class CreateBrandLoading extends BrandsState {}

class CreateBrandSuccess extends BrandsState {
  final String message;
  CreateBrandSuccess(this.message);
}

class CreateBrandError extends BrandsState {
  final String error;
  CreateBrandError(this.error);
}

// Delete Brand States
class DeleteBrandLoading extends BrandsState {}

class DeleteBrandSuccess extends BrandsState {
  final String message;
  DeleteBrandSuccess(this.message);
}

class DeleteBrandError extends BrandsState {
  final String error;
  DeleteBrandError(this.error);
}
class GetBrandByIdLoading extends BrandsState {}

class GetBrandByIdSuccess extends BrandsState {
  final BrandById brand;

  GetBrandByIdSuccess(this.brand);
}

class GetBrandByIdError extends BrandsState {
  final String error;

  GetBrandByIdError(this.error);
}

class UpdateBrandLoading extends BrandsState {}

class UpdateBrandSuccess extends BrandsState {
  final String message;

  UpdateBrandSuccess(this.message);
}

class UpdateBrandError extends BrandsState {
  final String error;

  UpdateBrandError(this.error);
}