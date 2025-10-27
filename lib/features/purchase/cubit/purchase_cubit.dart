import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/purchase/cubit/purchase_state.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());
}