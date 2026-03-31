# Requirements Document

## Introduction

تضيف هذه الميزة وظيفة إرجاع المبيعات (Return Sale) إلى شاشة POS الرئيسية في تطبيق Flutter. يتمكن الكاشير من البحث عن فاتورة بيع سابقة عبر رقم المرجع، ثم مراجعة تفاصيلها وتحديد الكميات المراد إرجاعها لكل منتج، وإرسال طلب الإرجاع إلى الـ API. تتكامل الميزة مع البنية الحالية لـ `PosCubit` وتتبع نمط الـ BLoC المستخدم في المشروع.

---

## Glossary

- **POS_Screen**: شاشة نقطة البيع الرئيسية (`POSHomeScreen`) حيث يدير الكاشير عمليات البيع.
- **Return_Button**: زر "RETURN" المضاف في شريط التنقل العلوي بجانب أزرار POS وORDERS.
- **Return_Search_Dialog**: نافذة البحث عن الفاتورة التي تحتوي على حقل رقم المرجع وزر "Search Sale".
- **Return_Details_Screen**: شاشة تفاصيل الإرجاع التي تعرض معلومات الفاتورة وجدول المنتجات القابلة للإرجاع.
- **Return_Cubit**: كيوبت BLoC مستقل مسؤول عن البحث عن الفاتورة وإرسال طلب الإرجاع.
- **ReturnSaleModel**: موديل البيانات الذي يمثل الفاتورة المُسترجعة من الـ API بما فيها معلومات البيع والمنتجات.
- **ReturnItemModel**: موديل يمثل منتجاً واحداً في قائمة الإرجاع، يتضمن الكمية المتاحة للإرجاع والكمية المطلوب إرجاعها.
- **API_Return_Endpoint**: نقطة النهاية `POST /api/admin/return-sale/create-return` المسؤولة عن إنشاء طلب الإرجاع.
- **Reference_Number**: رقم مرجع الفاتورة المستخدم للبحث عنها (مثال: "03125043").

---

## Requirements

### Requirement 1: زر الإرجاع في شريط التنقل

**User Story:** As a cashier, I want to see a RETURN button in the POS navigation bar, so that I can quickly access the return sale flow without leaving the POS screen.

#### Acceptance Criteria

1. THE POS_Screen SHALL display a Return_Button labeled "RETURN" in the top navigation bar alongside the existing POS and ONLINE ORDERS buttons.
2. WHEN the Return_Button is active (selected), THE Return_Button SHALL display with a purple background color (`AppColors.categoryPurple`) and a circular icon indicator.
3. WHEN the Return_Button is inactive, THE Return_Button SHALL display with the same inactive style as other navigation buttons.
4. WHEN the cashier taps the Return_Button, THE POS_Screen SHALL open the Return_Search_Dialog.

---

### Requirement 2: البحث عن الفاتورة

**User Story:** As a cashier, I want to search for a sale by its reference number, so that I can find the correct invoice to process a return.

#### Acceptance Criteria

1. THE Return_Search_Dialog SHALL display a text input field with the placeholder "Reference Number".
2. THE Return_Search_Dialog SHALL display a "Search Sale" button styled with purple color (`AppColors.categoryPurple`).
3. THE Return_Search_Dialog SHALL display a "Cancel" button that closes the dialog without any action.
4. WHEN the cashier taps "Search Sale" with an empty reference field, THE Return_Search_Dialog SHALL display a validation error message and SHALL NOT call the API.
5. WHEN the cashier taps "Search Sale" with a non-empty reference number, THE Return_Cubit SHALL call `GET /api/admin/pos/sales` filtered by the reference number to fetch the sale details.
6. WHILE the API call is in progress, THE Return_Search_Dialog SHALL display a loading indicator and disable the "Search Sale" button.
7. IF the API call succeeds and a matching sale is found, THEN THE Return_Cubit SHALL emit a loaded state and THE POS_Screen SHALL navigate to the Return_Details_Screen.
8. IF the API call fails or no sale is found, THEN THE Return_Cubit SHALL emit an error state and THE Return_Search_Dialog SHALL display the error message without closing.

---

### Requirement 3: عرض تفاصيل الفاتورة

**User Story:** As a cashier, I want to see the full details of the found invoice, so that I can verify it is the correct sale before processing the return.

#### Acceptance Criteria

1. THE Return_Details_Screen SHALL display the following sale information: Reference, Date, Customer name (or "Walk-in Customer" if null), Warehouse name, Cashier name, and Cashier Manager name.
2. WHEN the customer field in the API response is null, THE Return_Details_Screen SHALL display "Walk-in Customer" as the customer name.
3. THE Return_Details_Screen SHALL display a scrollable products table with the following columns: Product name, Code, Quantity (original), Available to Return, and Return Quantity.
4. THE Return_Details_Screen SHALL display a "Return Note" text input field that is optional.
5. THE Return_Details_Screen SHALL display a "Submit Return" button styled with purple color (`AppColors.categoryPurple`).
6. THE Return_Details_Screen SHALL display a "Cancel" button that navigates back to the POS_Screen.

---

### Requirement 4: تعديل كميات الإرجاع

**User Story:** As a cashier, I want to set the return quantity for each product, so that I can process partial or full returns accurately.

#### Acceptance Criteria

1. THE Return_Details_Screen SHALL display a quantity input (stepper or text field) for each ReturnItemModel in the Return Quantity column.
2. WHEN the Return Quantity for an item is 0, THE Return_Details_Screen SHALL display 0 as the default value.
3. WHEN the cashier increases the Return Quantity for an item, THE Return_Details_Screen SHALL not allow the value to exceed the `available_to_return` value for that item.
4. WHEN the cashier decreases the Return Quantity for an item, THE Return_Details_Screen SHALL not allow the value to go below 0.
5. IF the cashier attempts to set a Return Quantity greater than `available_to_return`, THEN THE Return_Details_Screen SHALL cap the value at `available_to_return` and display a warning message.

---

### Requirement 5: إرسال طلب الإرجاع

**User Story:** As a cashier, I want to submit the return request, so that the system records the returned items and processes the refund.

#### Acceptance Criteria

1. WHEN the cashier taps "Submit Return" and all Return Quantities are 0, THE Return_Details_Screen SHALL display a validation error stating that at least one item must have a return quantity greater than 0, and SHALL NOT call the API.
2. WHEN the cashier taps "Submit Return" with at least one item having a Return Quantity greater than 0, THE Return_Cubit SHALL call `POST /api/admin/return-sale/create-return` with the correct request body.
3. THE Return_Cubit SHALL construct the request body with: `sale_id` (from the fetched sale), `items` array (only items with quantity > 0, each containing `product_price_id`, `quantity`, and `reason`), `refund_account_id` (from the POS selections), and `note` (from the Return Note field, or empty string if blank).
4. WHILE the submit API call is in progress, THE Return_Details_Screen SHALL display a loading indicator and disable the "Submit Return" button.
5. IF the submit API call succeeds, THEN THE Return_Cubit SHALL emit a success state, THE POS_Screen SHALL display a success message, and THE Return_Details_Screen SHALL close and return to the POS_Screen.
6. IF the submit API call fails, THEN THE Return_Cubit SHALL emit an error state and THE Return_Details_Screen SHALL display the error message without closing.

---

### Requirement 6: موديلات البيانات

**User Story:** As a developer, I want well-defined data models for the return sale API response, so that the data is correctly parsed and displayed throughout the return flow.

#### Acceptance Criteria

1. THE ReturnSaleModel SHALL parse the `sale` object from the API response including: `_id`, `reference`, `date`, `customer` (nullable), `warehouse.name`, `created_by.email`, `shift.cashier.name`, and `shift.cashierman.username`.
2. THE ReturnItemModel SHALL parse each item from the `items` array including: `_id`, `sale_id`, `product.name`, `product.code`, `product_price._id` (nullable, falls back to product `_id`), `quantity`, `already_returned`, and `available_to_return`.
3. FOR ALL valid API responses, parsing the JSON into ReturnSaleModel and ReturnItemModel SHALL produce objects with all required fields populated without throwing exceptions (round-trip property).
4. WHEN `product_price` is null in an item, THE ReturnItemModel SHALL use the `product._id` as the `product_price_id` for the return request body.

---

### Requirement 7: إدارة الحالة والـ Cubit

**User Story:** As a developer, I want a dedicated Return_Cubit that manages the return flow state independently, so that the return logic is isolated and testable.

#### Acceptance Criteria

1. THE Return_Cubit SHALL manage the following states: `ReturnInitial`, `ReturnSearchLoading`, `ReturnSaleLoaded`, `ReturnSearchError`, `ReturnSubmitting`, `ReturnSubmitSuccess`, and `ReturnSubmitError`.
2. WHEN the Return_Details_Screen is closed or the cashier cancels, THE Return_Cubit SHALL reset to `ReturnInitial` state.
3. THE Return_Cubit SHALL be provided at the POS_Screen level so it persists across the search and details screens within the return flow.
4. WHEN the return is submitted successfully, THE Return_Cubit SHALL clear the current ReturnSaleModel and reset the return quantities to 0.

---

### Requirement 8: التوطين (Localization)

**User Story:** As a user, I want the return sale UI to support both Arabic and English languages, so that the interface is consistent with the rest of the application.

#### Acceptance Criteria

1. THE Return_Search_Dialog SHALL display all labels, placeholders, and button texts using `easy_localization` translation keys.
2. THE Return_Details_Screen SHALL display all column headers, labels, and button texts using `easy_localization` translation keys.
3. THE POS_Screen SHALL add the translation keys for the return feature to both `assets/translations/en.json` and `assets/translations/ar.json`.
4. WHEN the application language is Arabic, THE Return_Details_Screen SHALL display all text in Arabic using the defined translation keys.
