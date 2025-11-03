import '../model/zone_model.dart';

abstract class ZoneState {}

class ZoneInitial extends ZoneState {}

// Get All Zone
class GetZonesLoading extends ZoneState {}

class GetZonesSuccess extends ZoneState {
  final List<ZoneModel> zones;
  GetZonesSuccess(this.zones);
}

class GetZonesError extends ZoneState {
  final String error;
  GetZonesError(this.error);
}

// Get Zone By ID
class SelectZoneLoading extends ZoneState {}

class SelectZoneSuccess extends ZoneState {
  String message;
  SelectZoneSuccess(this.message);
}

class SelectZoneError extends ZoneState {
  final String error;
  SelectZoneError(this.error);
}

// Create Zone
class CreateZoneLoading extends ZoneState {}

class CreateZoneSuccess extends ZoneState {
  final String message;
  CreateZoneSuccess(this.message);
}

class CreateZoneError extends ZoneState {
  final String error;
  CreateZoneError(this.error);
}

// Update Zone
class UpdateZoneLoading extends ZoneState {}

class UpdateZoneSuccess extends ZoneState {
  final String message;
  UpdateZoneSuccess(this.message);
}

class UpdateZoneError extends ZoneState {
  final String error;
  UpdateZoneError(this.error);
}

// Delete Zone
class DeleteZoneLoading extends ZoneState {}

class DeleteZoneSuccess extends ZoneState {
  final String message;
  DeleteZoneSuccess(this.message);
}

class DeleteZoneError extends ZoneState {
  final String error;
  DeleteZoneError(this.error);
}
