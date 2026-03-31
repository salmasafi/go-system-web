# Tasks: POS Return Sale

## Task List

- [x] 1. ����� API endpoints �������
  - [x] 1.1 ����� `posSearchSaleByRef` �� `EndPoint` � `static String posSearchSaleByRef(String ref) => '/api/admin/pos/sales?reference=$ref';`
  - [x] 1.2 ����� `createReturn` �� `EndPoint` � `static const String createReturn = '/api/admin/return-sale/create-return';`

- [x] 2. ����� ������� ��������
  - [x] 2.1 ����� `lib/features/POS/return/models/return_item_model.dart`
  - [x] 2.2 ����� `ReturnItemModel` �������: `id`, `saleId`, `productName`, `productCode`, `productPriceId`, `quantity`, `alreadyReturned`, `availableToReturn`, `returnQuantity` (mutable, default 0)
  - [x] 2.3 ����� `ReturnItemModel.fromJson` �� fallback: `productPriceId = product_price?._id ?? product._id`
  - [x] 2.4 ����� `lib/features/POS/return/models/return_sale_model.dart`
  - [x] 2.5 ����� `ReturnSaleModel` �������: `id`, `reference`, `date`, `customerName` (nullable), `warehouseName`, `cashierEmail`, `cashierName`, `cashierManName`, `items`
  - [x] 2.6 ����� `ReturnSaleModel.fromJson` �� parsing ������ ���������
  - [x] 2.7 ����� getter `displayCustomerName` ����� `customerName ?? 'Walk-in Customer'`

- [x] 3. ����� ReturnCubit ���� States
  - [x] 3.1 ����� `lib/features/POS/return/cubit/return_state.dart` ��������: `ReturnInitial`, `ReturnSearchLoading`, `ReturnSaleLoaded`, `ReturnSearchError`, `ReturnSubmitting`, `ReturnSubmitSuccess`, `ReturnSubmitError`
  - [x] 3.2 ����� `lib/features/POS/return/cubit/return_cubit.dart`
  - [x] 3.3 ����� `searchSale(String reference)` � ������ �� ��� �����ۡ emit Loading� GET `/api/admin/pos/sales?reference=...`� emit Loaded �� Error
  - [x] 3.4 ����� `updateReturnQuantity(int index, int quantity)` � clamp ������ ��� 0 � `availableToReturn`� re-emit `ReturnSaleLoaded`
  - [x] 3.5 ����� `submitReturn({required String refundAccountId, required String note})` � ������ �� ���� ���� > 0� ���� request body� POST� emit Success �� Error
  - [x] 3.6 ����� `reset()` � emit `ReturnInitial`

- [x] 4. ����� ReturnCubit �� ���� ��� Widgets
  - [x] 4.1 ����� `BlocProvider<ReturnCubit>` �� ��� ����� `PosCubit` � `CheckoutCubit` �� `main.dart`

- [x] 5. ����� �� RETURN �� ���� ������
  - [x] 5.1 ����� AppBar �� `POSHomeScreen` ������ �� "RETURN"
  - [x] 5.2 ����� ��� `AppColors.categoryPurple` ��� ��������
  - [x] 5.3 ��� `onTap` ���� `ReturnSearchDialog`

- [x] 6. ���� ReturnSearchDialog
  - [x] 6.1 ����� `lib/features/POS/return/widgets/return_search_dialog.dart`
  - [x] 6.2 ����� `TextField` �� placeholder "Reference Number"
  - [x] 6.3 ����� �� "Search Sale" ���� `AppColors.categoryPurple`
  - [x] 6.4 ����� �� "Cancel" ���� ��� dialog
  - [x] 6.5 ������� `BlocConsumer<ReturnCubit, ReturnState>` ���� loading indicator ������ ���� ����� `ReturnSearchLoading`
  - [x] 6.6 ��� ����� ����� ���� ��� dialog ��� `ReturnSearchError`
  - [x] 6.7 ��� `ReturnSaleLoaded`: ����� ��� dialog ��������� ��� `ReturnDetailsScreen`

- [x] 7. ���� ReturnItemsTable
  - [x] 7.1 ����� `lib/features/POS/return/widgets/return_items_table.dart`
  - [x] 7.2 ���� ���� ��������: Product, Code, Qty, Available, Return Qty
  - [x] 7.3 �� �� ����� ��� stepper (�� + ��� -) �� clamp ��� 0 � `availableToReturn`
  - [x] 7.4 ��� ����� ���� ������: ��� ����� ����� ����� (SnackBar)
  - [x] 7.5 ������� `ReturnCubit.updateReturnQuantity` ��� ����� ������

- [x] 8. ���� ReturnDetailsScreen
  - [x] 8.1 ����� `lib/features/POS/return/screens/return_details_screen.dart`
  - [x] 8.2 ��� ������� ��������: Reference, Date, Customer (`displayCustomerName`), Warehouse, Cashier, Manager
  - [x] 8.3 ����� `ReturnItemsTable` �� `SingleChildScrollView`
  - [x] 8.4 ����� `TextField` �� "Return Note" (�������)
  - [x] 8.5 ����� �� "Submit Return" ���� `AppColors.categoryPurple`
  - [x] 8.6 ����� �� "Cancel" ����� ��� `POSHomeScreen` ������� `ReturnCubit.reset()`
  - [x] 8.7 ������� `BlocConsumer<ReturnCubit, ReturnState>` ���� loading ������ ���� ����� `ReturnSubmitting`
  - [x] 8.8 ��� `ReturnSubmitSuccess`: pop ������ ���� success SnackBar
  - [x] 8.9 ��� `ReturnSubmitError`: ��� ����� ����� ���� ������ ��� �������

- [x] 9. ����� ������ �������
  - [x] 9.1 ����� ������ ������� ��� `assets/translations/en.json`
  - [x] 9.2 ����� ��� �������� ��� `assets/translations/ar.json` �������� ������� ��������
  - [x] 9.3 ������� `.tr()` �� ��� widgets

- [x] 10. ����� ����������
  - [x] 10.1 Unit test: `ReturnSaleModel.fromJson` ����� ������ ������� �� JSON ����
  - [x] 10.2 Unit test: `ReturnItemModel.fromJson` �� `product_price = null` ������ `product._id`
  - [x] 10.3 Unit test: `ReturnSaleModel.displayCustomerName` ����� "Walk-in Customer" ��� customer = null
  - [x] 10.4 [PBT] Property 1: ��� string ���� �� ���� �� �����ʡ `searchSale` �� ����� `ReturnSearchLoading`
  - [x] 10.5 [PBT] Property 2: ��� reference ��� ���ۡ `searchSale` ����� `ReturnSearchLoading` �����
  - [x] 10.6 [PBT] Property 5: ��� `ReturnItemModel` ��� ����� �� ������ increment/decrement� `returnQuantity` ������ �� ������ `[0, availableToReturn]`
  - [x] 10.7 [PBT] Property 6: ��� ����� ����� ���� ��ѡ `submitReturn` �� ����� `ReturnSubmitting`
  - [x] 10.8 [PBT] Property 7: ��� ����� ����� ��� ���� ���� ��� ����� > 0� ��� request body ����� ��� ��� ������� ���� ������ > 0 ������� �������
  - [x] 10.9 [PBT] Property 8: ��� JSON ���͡ parsing ��� `ReturnSaleModel` �� ����� exception ����� ������ �������� ������
  - [x] 10.10 [PBT] Property 11: ��� `reset()` �� �� ���ɡ ��� cubit ������ �� `ReturnInitial`
  - [x] 10.11 Widget test: �� RETURN ����� �� `POSHomeScreen`
  - [x] 10.12 Widget test: ����� ��� RETURN ���� `ReturnSearchDialog`


