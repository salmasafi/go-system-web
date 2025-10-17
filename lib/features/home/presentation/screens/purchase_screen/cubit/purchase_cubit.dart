import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/purchase_screen/cubit/purchase_state.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());
}