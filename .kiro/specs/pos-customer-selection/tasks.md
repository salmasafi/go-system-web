# Tasks: POS Customer Selection

## Task List

- [x] 1. Add POS customer endpoints to EndPoint class
  - [x] 1.1 Add `getPosCustomers` constant (`/api/admin/pos_customer/customers`)
  - [x] 1.2 Add `createPosCustomer` constant (`/api/admin/pos_customer/customer`)

- [x] 2. Create PosCustomer model
  - [x] 2.1 Create `lib/features/POS/customer/model/pos_customer_model.dart`
  - [x] 2.2 Implement `PosCustomer` with all fields: `_id`, `name`, `email`, `phoneNumber`, `address`, `country`, `city`, `customerGroupId`, `totalPointsEarned`, `amountDue`, `isDue`
  - [x] 2.3 Implement `PosCustomer.fromJson` factory
  - [x] 2.4 Implement `toCreateJson()` method for POST body

- [x] 3. Create PosCustomerCubit and states
  - [x] 3.1 Create `lib/features/POS/customer/cubit/pos_customer_state.dart` with all states: `PosCustomerInitial`, `PosCustomerLoading`, `PosCustomerLoaded`, `PosCustomerError`, `PosCustomerCreating`, `PosCustomerCreateSuccess`, `PosCustomerCreateError`
  - [x] 3.2 Create `lib/features/POS/customer/cubit/pos_customer_cubit.dart`
  - [x] 3.3 Implement `fetchCustomers()` — GET `/api/admin/pos_customer/customers`, emit Loading → Loaded or Error
  - [x] 3.4 Implement `selectCustomer(PosCustomer customer)` — update `selectedCustomer`, re-emit `PosCustomerLoaded`
  - [x] 3.5 Implement `createCustomer({required String name, required String phone, String? email, String? address})` — POST, on success add to list + set as selected + emit `PosCustomerCreateSuccess`, on failure emit `PosCustomerCreateError`
  - [x] 3.6 Implement `clearSelectedCustomer()` — set `selectedCustomer = null`, re-emit `PosCustomerLoaded`
  - [x] 3.7 Implement `clearAll()` — clear both `customers` and `selectedCustomer`, emit `PosCustomerInitial`

- [x] 4. Provide PosCustomerCubit in the widget tree
  - [x] 4.1 Add `BlocProvider<PosCustomerCubit>` in the appropriate ancestor widget (same level as `PosCubit` and `CheckoutCubit`)
  - [x] 4.2 Call `context.read<PosCustomerCubit>().fetchCustomers()` in `POSHomeScreen.initState` when shift is open

- [x] 5. Build CustomerSelectorWidget
  - [x] 5.1 Create `lib/features/POS/customer/presentation/widgets/customer_selector_widget.dart`
  - [x] 5.2 Use `BlocBuilder<PosCustomerCubit, PosCustomerState>` to show placeholder ("Select Customer" + chevron-down) when `selectedCustomer` is null
  - [x] 5.3 Show selected customer's name and phone number when `selectedCustomer` is non-null
  - [x] 5.4 Add "+" `IconButton` to the right; wire `onTap` to open `CustomerCreateDialog`
  - [x] 5.5 Wire selector `onTap` to open `CustomerPickerSheet`

- [x] 6. Integrate CustomerSelectorWidget into POSHeaderSection
  - [x] 6.1 Add `CustomerSelectorWidget` to `POSHeaderSection` build method, above the product grid area

- [x] 7. Build CustomerPickerSheet
  - [x] 7.1 Create `lib/features/POS/customer/presentation/widgets/customer_picker_sheet.dart`
  - [x] 7.2 Add `TextField` with placeholder "Search by name or phone"
  - [x] 7.3 Implement in-memory case-insensitive filter on name and phone number
  - [x] 7.4 Build `ListView` of customer tiles, each showing name and phone
  - [x] 7.5 On tile tap: call `cubit.selectCustomer(customer)` then `Navigator.pop`
  - [x] 7.6 Show empty-state widget when list is empty or search yields no results

- [x] 8. Build CustomerCreateDialog
  - [x] 8.1 Create `lib/features/POS/customer/presentation/widgets/customer_create_dialog.dart`
  - [x] 8.2 Add form fields: name (required), phone (required), email (optional), address (optional)
  - [x] 8.3 Implement client-side validation — reject blank/whitespace-only name or phone, show inline error
  - [x] 8.4 On valid submit: call `PosCustomerCubit.createCustomer(...)`, show loading indicator
  - [x] 8.5 On `PosCustomerCreateSuccess`: close dialog
  - [x] 8.6 On `PosCustomerCreateError`: display error message inside dialog without closing

- [x] 9. Implement checkout guard
  - [x] 9.1 In `POSHomeScreen`, before opening the checkout sheet/dialog, read `PosCustomerCubit.selectedCustomer`
  - [x] 9.2 If null: show `CustomSnackbar.showError("Please select a customer before checkout")` and abort
  - [x] 9.3 If non-null: pass `selectedCustomer!.id` as `customer_id` to `CheckoutCubit.createSale`

- [x] 10. Update CheckoutCubit.createSale to accept customer_id
  - [x] 10.1 Add `required String customerId` parameter to `createSale`
  - [x] 10.2 Include `"customer_id": customerId` in the sale payload body

- [x] 11. Clear customer state after sale and on shift end
  - [x] 11.1 In `POSHomeScreen` `BlocListener` for `CheckoutCubit`, on `CheckoutSuccess`: call `context.read<PosCustomerCubit>().clearSelectedCustomer()`
  - [x] 11.2 In `POSHomeScreen` `BlocListener` for `PosShiftCubit`, on `PosShiftEnded`: call `context.read<PosCustomerCubit>().clearAll()`

- [x] 12. Write tests
  - [x] 12.1 Unit test `PosCustomer.fromJson` maps all fields correctly
  - [x] 12.2 Unit test `PosCustomer.toCreateJson` produces correct POST body keys
  - [x] 12.3 Property test (P3): search filter returns correct subset for any list + query
  - [x] 12.4 Property test (P5): `selectCustomer` updates cubit state for any customer
  - [x] 12.5 Property test (P9): create customer round-trip — new customer in list and selected
  - [x] 12.6 Property test (P10): blank/whitespace name or phone rejected by form validation
  - [x] 12.7 Property test (P11): `selectedCustomer` is null after successful sale
  - [x] 12.8 Property test (P12): `customers` and `selectedCustomer` both cleared after `clearAll()`
  - [x] 12.9 Widget test: `CustomerSelectorWidget` shows placeholder when no customer selected
  - [x] 12.10 Widget test: `CustomerSelectorWidget` shows name + phone when customer selected
  - [x] 12.11 Widget test: "+" button always present in both states
