# Requirements Document

## Introduction

This feature adds a customer selection component to the POS home screen in the Flutter POS application. Cashiers can browse and add items to the cart freely, but must select a customer before completing checkout. A quick-create flow allows adding new customers inline without leaving the POS screen. The feature integrates with the existing `PosCubit` state management and the dedicated POS customer API endpoints.

## Glossary

- **POS_Screen**: The main point-of-sale home screen (`POSHomeScreen`) where cashiers manage the active cart.
- **Customer_Selector**: The rounded picker widget displayed on the POS home screen that shows the currently selected customer or a placeholder prompt.
- **Customer_Picker_Sheet**: The bottom sheet or modal that opens when the cashier taps the Customer_Selector, containing a search field and a scrollable customer list.
- **Customer_Create_Dialog**: The inline dialog that opens when the cashier taps the "+" button next to the Customer_Selector, allowing quick creation of a new POS customer.
- **POS_Customer**: A customer record returned by or submitted to the POS customer API (`/api/admin/pos_customer/customers`).
- **POS_Customer_Cubit**: The BLoC cubit responsible for fetching the customer list and creating new POS customers.
- **Checkout_Cubit**: The existing BLoC cubit (`CheckoutCubit`) that manages the cart and sale creation.
- **Checkout_Guard**: The validation logic that prevents the cashier from proceeding to payment unless a customer is selected.

---

## Requirements

### Requirement 1: Display Customer Selector on POS Home Screen

**User Story:** As a cashier, I want to see a customer selector on the POS home screen, so that I can identify which customer the sale belongs to.

#### Acceptance Criteria

1. THE POS_Screen SHALL display the Customer_Selector widget in the header section, above the product grid.
2. WHEN no customer has been selected, THE Customer_Selector SHALL display the placeholder text "Select Customer" with a chevron-down icon.
3. WHEN a customer has been selected, THE Customer_Selector SHALL display the selected POS_Customer's name and phone number.
4. THE Customer_Selector SHALL display a "+" button to its right at all times.

---

### Requirement 2: Load and Display Customer List

**User Story:** As a cashier, I want to see a searchable list of existing customers, so that I can quickly find and select the right customer.

#### Acceptance Criteria

1. WHEN the POS_Screen initialises with an open shift, THE POS_Customer_Cubit SHALL fetch the customer list from `GET /api/admin/pos_customer/customers`.
2. WHEN the cashier taps the Customer_Selector, THE POS_Screen SHALL open the Customer_Picker_Sheet.
3. THE Customer_Picker_Sheet SHALL display a search field with the placeholder "Search by name or phone".
4. THE Customer_Picker_Sheet SHALL display a scrollable list of POS_Customer records, each showing the customer's name and phone number.
5. WHEN the cashier types in the search field, THE Customer_Picker_Sheet SHALL filter the displayed list to only show POS_Customer records whose name or phone number contains the entered text (case-insensitive).
6. IF the customer list is empty, THEN THE Customer_Picker_Sheet SHALL display an empty-state message indicating no customers are available.
7. IF the API call to fetch customers fails, THEN THE POS_Customer_Cubit SHALL emit an error state and THE POS_Screen SHALL display an error message to the cashier.

---

### Requirement 3: Select a Customer

**User Story:** As a cashier, I want to select a customer from the list, so that the sale is associated with that customer.

#### Acceptance Criteria

1. WHEN the cashier taps a POS_Customer entry in the Customer_Picker_Sheet, THE POS_Customer_Cubit SHALL set that customer as the selected customer.
2. WHEN a customer is selected, THE Customer_Picker_Sheet SHALL close automatically.
3. WHEN a customer is selected, THE Customer_Selector SHALL update to display the selected POS_Customer's name and phone number.
4. WHEN the cashier taps the Customer_Selector while a customer is already selected, THE Customer_Picker_Sheet SHALL open and allow the cashier to change the selection.

---

### Requirement 4: Add Items to Cart Without a Customer

**User Story:** As a cashier, I want to add products to the cart before selecting a customer, so that I can build the order freely without being forced to pick a customer first.

#### Acceptance Criteria

1. THE POS_Screen SHALL allow the cashier to add products to the cart regardless of whether a customer has been selected.
2. WHILE no customer is selected, THE Checkout_Cubit SHALL permit all cart operations (add, remove, update quantity).

---

### Requirement 5: Block Checkout Without a Customer

**User Story:** As a cashier, I want the system to prevent me from completing a sale without selecting a customer, so that every sale is properly attributed.

#### Acceptance Criteria

1. WHEN the cashier attempts to initiate checkout and no customer is selected, THE Checkout_Guard SHALL prevent the checkout flow from opening.
2. WHEN the cashier attempts to initiate checkout and no customer is selected, THE POS_Screen SHALL display an error message stating that a customer must be selected before checkout.
3. WHEN a customer is selected, THE Checkout_Guard SHALL permit the checkout flow to proceed normally.
4. WHEN a sale is successfully created, THE Checkout_Cubit SHALL include the selected POS_Customer's `_id` as `customer_id` in the sale payload.

---

### Requirement 6: Create a New Customer Inline

**User Story:** As a cashier, I want to create a new customer directly from the POS screen, so that I can register first-time customers without navigating away.

#### Acceptance Criteria

1. WHEN the cashier taps the "+" button next to the Customer_Selector, THE POS_Screen SHALL open the Customer_Create_Dialog.
2. THE Customer_Create_Dialog SHALL contain input fields for: name (required), phone number (required), email (optional), address (optional).
3. WHEN the cashier submits the Customer_Create_Dialog with valid required fields, THE POS_Customer_Cubit SHALL send a `POST /api/admin/pos_customer/customer` request with the provided data.
4. IF the create customer API call succeeds, THEN THE POS_Customer_Cubit SHALL add the new POS_Customer to the customer list, set the new customer as the selected customer, and close the Customer_Create_Dialog.
5. IF the create customer API call fails, THEN THE POS_Customer_Cubit SHALL emit an error state and THE Customer_Create_Dialog SHALL display the error message without closing.
6. WHEN the cashier submits the Customer_Create_Dialog with the name or phone number field empty, THE Customer_Create_Dialog SHALL display a validation error and SHALL NOT submit the request.

---

### Requirement 7: Customer State Persistence Within a Shift Session

**User Story:** As a cashier, I want the selected customer to be cleared after a sale is completed, so that the next transaction starts fresh.

#### Acceptance Criteria

1. WHEN a sale is successfully created via the Checkout_Cubit, THE POS_Customer_Cubit SHALL clear the selected customer.
2. WHEN the cashier's shift ends, THE POS_Customer_Cubit SHALL clear the selected customer and the customer list.
3. WHILE a shift is active and no sale has been completed, THE POS_Customer_Cubit SHALL retain the selected customer across product browsing and cart updates.
