# مستند المتطلبات: الهجرة من Dio إلى Supabase

## المقدمة

هذا المستند يحدد متطلبات الهجرة الكاملة من استخدام Dio للتواصل مع REST API (https://Bcknd.systego.net) إلى استخدام Supabase كخلفية كاملة (Backend-as-a-Service) في تطبيق Flutter لنظام إدارة المبيعات والمخزون Systego.

المشروع الحالي يحتوي على:
- 50+ جدول في قاعدة البيانات (products, sales, purchases, customers, suppliers, warehouses, admins, roles, permissions, financial_transactions, bank_accounts, expenses, revenues, shifts, cashiers, notifications, categories, brands, units, taxes, discounts, coupons, countries, cities, zones, bundles, variations, وغيرها)
- 100+ endpoint في ملف endpoints.dart
- نظام مصادقة قائم على JWT tokens
- نظام صلاحيات معقد (roles & permissions)
- إدارة الصور والملفات
- معاملات مالية وتقارير

الهدف من الهجرة هو:
1. استبدال جميع استدعاءات Dio بـ Supabase Client
2. الاستفادة من ميزات Supabase (Real-time, RLS, Storage, Auth)
3. تحسين الأداء والأمان
4. تبسيط الكود وتقليل التعقيد

## المصطلحات (Glossary)

- **Supabase_Client**: عميل Supabase الذي يوفر واجهة للتفاعل مع قاعدة البيانات والمصادقة والتخزين
- **DioHelper**: الكلاس الحالي المسؤول عن إجراء طلبات HTTP باستخدام مكتبة Dio
- **REST_API**: واجهة برمجة التطبيقات الحالية على https://Bcknd.systego.net
- **RLS**: Row Level Security - نظام أمان على مستوى الصفوف في Supabase
- **Repository**: طبقة الوصول للبيانات التي تتعامل مع مصادر البيانات
- **Data_Source**: المصدر الفعلي للبيانات (حالياً Dio، مستقبلاً Supabase)
- **Auth_Service**: خدمة المصادقة المسؤولة عن تسجيل الدخول والخروج وإدارة الجلسات
- **Storage_Service**: خدمة تخزين الملفات والصور
- **Real_Time_Service**: خدمة الاشتراك في التحديثات الفورية من قاعدة البيانات
- **Migration_Service**: خدمة مساعدة للهجرة التدريجية من Dio إلى Supabase
- **Error_Handler**: معالج الأخطاء الموحد للتعامل مع أخطاء Supabase
- **Session_Manager**: مدير الجلسات المسؤول عن إدارة حالة المستخدم
- **Cache_Helper**: مساعد التخزين المؤقت للبيانات المحلية
- **Product_Repository**: مستودع المنتجات
- **Sale_Repository**: مستودع المبيعات
- **Purchase_Repository**: مستودع المشتريات
- **Customer_Repository**: مستودع العملاء
- **Warehouse_Repository**: مستودع المستودعات
- **Admin_Repository**: مستودع المسؤولين
- **Financial_Repository**: مستودع المعاملات المالية
- **Shift_Repository**: مستودع الورديات
- **Notification_Repository**: مستودع الإشعارات

## المتطلبات

### المتطلب 1: إعداد Supabase Client

**قصة المستخدم:** كمطور، أريد إعداد Supabase Client في التطبيق، حتى أتمكن من الاتصال بقاعدة بيانات Supabase.

#### معايير القبول

1. THE Supabase_Client SHALL be initialized with project URL and anon key
2. THE Supabase_Client SHALL be configured as a singleton instance
3. THE Supabase_Client SHALL be accessible throughout the application
4. THE Supabase_Client SHALL support custom headers for API requests
5. THE Supabase_Client SHALL log all requests and responses in debug mode

### المتطلب 2: استبدال نظام المصادقة

**قصة المستخدم:** كمسؤول نظام، أريد تسجيل الدخول باستخدام Supabase Auth، حتى أتمكن من الوصول إلى النظام بشكل آمن.

#### معايير القبول

1. WHEN an admin provides valid credentials, THE Auth_Service SHALL authenticate using Supabase Auth
2. WHEN authentication succeeds, THE Auth_Service SHALL store the session token securely
3. WHEN authentication fails, THE Auth_Service SHALL return a descriptive error message
4. WHEN a session expires, THE Auth_Service SHALL notify the Session_Manager
5. THE Auth_Service SHALL support automatic token refresh
6. THE Auth_Service SHALL clear local cache on logout
7. WHEN an admin logs out, THE Auth_Service SHALL revoke the Supabase session

### المتطلب 3: تحويل Product Repository

**قصة المستخدم:** كمستخدم، أريد إدارة المنتجات (عرض، إضافة، تعديل، حذف)، حتى أتمكن من إدارة المخزون.

#### معايير القبول

1. WHEN fetching all products, THE Product_Repository SHALL query the products table using Supabase_Client
2. WHEN fetching a product by ID, THE Product_Repository SHALL use Supabase select with eq filter
3. WHEN creating a product, THE Product_Repository SHALL insert into products table
4. WHEN updating a product, THE Product_Repository SHALL use Supabase update with eq filter
5. WHEN deleting a product, THE Product_Repository SHALL use Supabase delete with eq filter
6. WHEN searching products by code, THE Product_Repository SHALL use Supabase ilike filter
7. THE Product_Repository SHALL handle product images using Storage_Service
8. THE Product_Repository SHALL support pagination using range queries
9. THE Product_Repository SHALL include related data (brand, category, unit) using joins
10. WHEN a product has variations, THE Product_Repository SHALL fetch product_prices with variation_options

### المتطلب 4: تحويل Sale Repository

**قصة المستخدم:** كبائع، أريد إنشاء وإدارة المبيعات، حتى أتمكن من تسجيل عمليات البيع.

#### معايير القبول

1. WHEN creating a sale, THE Sale_Repository SHALL insert into sales table using Supabase transaction
2. WHEN creating a sale, THE Sale_Repository SHALL insert sale_items in the same transaction
3. WHEN creating a sale, THE Sale_Repository SHALL insert sale_payments in the same transaction
4. WHEN creating a sale, THE Sale_Repository SHALL update product_warehouses quantities
5. WHEN fetching sales, THE Sale_Repository SHALL include customer, warehouse, and items data
6. WHEN searching sales by reference, THE Sale_Repository SHALL use Supabase ilike filter
7. WHEN fetching pending sales, THE Sale_Repository SHALL filter by is_pending equals true
8. WHEN fetching due sales, THE Sale_Repository SHALL filter by is_due equals true
9. THE Sale_Repository SHALL support real-time updates for new sales
10. WHEN applying a coupon, THE Sale_Repository SHALL validate and update coupon usage_count

### المتطلب 5: تحويل Purchase Repository

**قصة المستخدم:** كمدير مشتريات، أريد إدارة المشتريات، حتى أتمكن من تسجيل عمليات الشراء من الموردين.

#### معايير القبول

1. WHEN creating a purchase, THE Purchase_Repository SHALL insert into purchases table using Supabase transaction
2. WHEN creating a purchase, THE Purchase_Repository SHALL insert purchase_items in the same transaction
3. WHEN creating a purchase, THE Purchase_Repository SHALL update product_warehouses quantities
4. WHEN fetching purchases, THE Purchase_Repository SHALL include supplier, warehouse, and items data
5. WHEN searching purchases by reference, THE Purchase_Repository SHALL use Supabase ilike filter
6. THE Purchase_Repository SHALL handle purchase invoices and due payments
7. THE Purchase_Repository SHALL support purchase returns with quantity adjustments

### المتطلب 6: تحويل Customer Repository

**قصة المستخدم:** كبائع، أريد إدارة بيانات العملاء، حتى أتمكن من تتبع مشترياتهم ونقاطهم.

#### معايير القبول

1. WHEN fetching all customers, THE Customer_Repository SHALL query customers table
2. WHEN creating a customer, THE Customer_Repository SHALL insert into customers table
3. WHEN updating a customer, THE Customer_Repository SHALL use Supabase update
4. WHEN deleting a customer, THE Customer_Repository SHALL use Supabase delete
5. THE Customer_Repository SHALL include customer_group, city, and country data
6. WHEN fetching customer due amounts, THE Customer_Repository SHALL calculate from sales
7. THE Customer_Repository SHALL support customer groups management

### المتطلب 7: تحويل Warehouse Repository

**قصة المستخدم:** كمدير مستودع، أريد إدارة المستودعات والمخزون، حتى أتمكن من تتبع الكميات المتاحة.

#### معايير القبول

1. WHEN fetching all warehouses, THE Warehouse_Repository SHALL query warehouses table
2. WHEN fetching warehouse products, THE Warehouse_Repository SHALL query product_warehouses
3. WHEN adding product to warehouse, THE Warehouse_Repository SHALL insert into product_warehouses
4. WHEN updating product quantity, THE Warehouse_Repository SHALL update product_warehouses
5. THE Warehouse_Repository SHALL support low stock notifications
6. THE Warehouse_Repository SHALL handle product transfers between warehouses

### المتطلب 8: تحويل Admin & Roles Repository

**قصة المستخدم:** كمدير نظام، أريد إدارة المسؤولين والصلاحيات، حتى أتمكن من التحكم في الوصول.

#### معايير القبول

1. WHEN fetching all admins, THE Admin_Repository SHALL query admins table
2. WHEN creating an admin, THE Admin_Repository SHALL hash password and insert into admins table
3. WHEN updating an admin, THE Admin_Repository SHALL use Supabase update
4. THE Admin_Repository SHALL include role and department data
5. WHEN fetching roles, THE Admin_Repository SHALL query roles table with permissions
6. WHEN creating a role, THE Admin_Repository SHALL insert into roles table
7. WHEN updating role permissions, THE Admin_Repository SHALL update permissions jsonb field
8. THE Admin_Repository SHALL validate permissions before granting access

### المتطلب 9: تحويل Financial Repository

**قصة المستخدم:** كمحاسب، أريد إدارة المعاملات المالية، حتى أتمكن من تتبع الإيرادات والمصروفات.

#### معايير القبول

1. WHEN recording an expense, THE Financial_Repository SHALL insert into expenses table
2. WHEN recording an expense, THE Financial_Repository SHALL update bank_account balance
3. WHEN recording a revenue, THE Financial_Repository SHALL insert into revenues table
4. WHEN recording a revenue, THE Financial_Repository SHALL update bank_account balance
5. THE Financial_Repository SHALL create financial_transactions for all money movements
6. THE Financial_Repository SHALL support expense and revenue categories
7. THE Financial_Repository SHALL include bank account data in queries

### المتطلب 10: تحويل Shift & Cashier Repository

**قصة المستخدم:** كصراف، أريد إدارة الورديات، حتى أتمكن من تتبع المبيعات والمصروفات في وردية العمل.

#### معايير القبول

1. WHEN starting a shift, THE Shift_Repository SHALL insert into shifts table
2. WHEN starting a shift, THE Shift_Repository SHALL set cashier status to active
3. WHEN ending a shift, THE Shift_Repository SHALL update shift end_time and totals
4. WHEN ending a shift, THE Shift_Repository SHALL set cashier status to inactive
5. THE Shift_Repository SHALL calculate total_sale_amount from sales in shift
6. THE Shift_Repository SHALL calculate total_expenses from expenses in shift
7. THE Shift_Repository SHALL include cashier and bank_account data

### المتطلب 11: تحويل Notification Repository

**قصة المستخدم:** كمستخدم، أريد استقبال الإشعارات الفورية، حتى أتمكن من معرفة التحديثات المهمة.

#### معايير القبول

1. WHEN fetching notifications, THE Notification_Repository SHALL query notifications table
2. WHEN marking notification as read, THE Notification_Repository SHALL update is_read field
3. THE Notification_Repository SHALL subscribe to real-time notifications using Supabase channels
4. WHEN a new notification is created, THE Real_Time_Service SHALL notify the user
5. THE Notification_Repository SHALL filter notifications by admin_id
6. THE Notification_Repository SHALL support notification types and severity levels

### المتطلب 12: تحويل Category, Brand, Unit Repositories

**قصة المستخدم:** كمدير، أريد إدارة التصنيفات والعلامات التجارية والوحدات، حتى أتمكن من تنظيم المنتجات.

#### معايير القبول

1. WHEN fetching categories, THE Category_Repository SHALL query categories table
2. THE Category_Repository SHALL support hierarchical categories using parent_id
3. WHEN creating a brand, THE Brand_Repository SHALL insert into brands table
4. THE Brand_Repository SHALL handle brand logos using Storage_Service
5. WHEN fetching units, THE Unit_Repository SHALL query units table
6. THE Category_Repository SHALL support category images using Storage_Service

### المتطلب 13: تحويل Tax, Discount, Coupon Repositories

**قصة المستخدم:** كمدير، أريد إدارة الضرائب والخصومات والكوبونات، حتى أتمكن من تطبيق العروض.

#### معايير القبول

1. WHEN fetching taxes, THE Tax_Repository SHALL query taxes table
2. WHEN creating a discount, THE Discount_Repository SHALL insert into discounts table
3. WHEN creating a coupon, THE Coupon_Repository SHALL insert into coupons table
4. WHEN validating a coupon, THE Coupon_Repository SHALL check start_date, end_date, and usage_limit
5. WHEN applying a coupon, THE Coupon_Repository SHALL increment usage_count
6. THE Discount_Repository SHALL support percentage and fixed amount types

### المتطلب 14: تحويل Location Repositories (Country, City, Zone)

**قصة المستخدم:** كمدير، أريد إدارة المواقع الجغرافية، حتى أتمكن من تحديد مواقع العملاء والموردين.

#### معايير القبول

1. WHEN fetching countries, THE Country_Repository SHALL query countries table
2. WHEN fetching cities, THE City_Repository SHALL query cities table with country data
3. WHEN fetching zones, THE Zone_Repository SHALL query zones table with city data
4. THE City_Repository SHALL include shipping_cost in city data
5. THE Country_Repository SHALL support default country selection

### المتطلب 15: تحويل Variation & Bundle Repositories

**قصة المستخدم:** كمدير منتجات، أريد إدارة تنويعات المنتجات والباقات، حتى أتمكن من بيع منتجات متعددة الخيارات.

#### معايير القبول

1. WHEN fetching variations, THE Variation_Repository SHALL query variations table with options
2. WHEN creating a variation, THE Variation_Repository SHALL insert into variations table
3. WHEN adding variation options, THE Variation_Repository SHALL insert into variation_options table
4. WHEN creating a bundle, THE Bundle_Repository SHALL insert into bundles table
5. WHEN creating a bundle, THE Bundle_Repository SHALL insert bundle_products
6. THE Bundle_Repository SHALL validate bundle dates and availability
7. THE Bundle_Repository SHALL support bundle warehouses assignment

### المتطلب 16: تحويل Adjustment & Transfer Repositories

**قصة المستخدم:** كمدير مستودع، أريد إدارة التعديلات والتحويلات، حتى أتمكن من تصحيح المخزون ونقل المنتجات.

#### معايير القبول

1. WHEN creating an adjustment, THE Adjustment_Repository SHALL insert into adjustments table
2. WHEN creating an adjustment, THE Adjustment_Repository SHALL update product_warehouses quantity
3. WHEN creating a transfer, THE Transfer_Repository SHALL insert into transfers table
4. WHEN approving a transfer, THE Transfer_Repository SHALL update quantities in both warehouses
5. THE Adjustment_Repository SHALL support adjustment types (increase, decrease)
6. THE Transfer_Repository SHALL validate source warehouse has sufficient quantity

### المتطلب 17: تحويل Return Repositories (Sale & Purchase Returns)

**قصة المستخدم:** كبائع، أريد إدارة مرتجعات المبيعات والمشتريات، حتى أتمكن من معالجة المرتجعات.

#### معايير القبول

1. WHEN creating a sale return, THE Sale_Return_Repository SHALL insert into sale_returns table
2. WHEN creating a sale return, THE Sale_Return_Repository SHALL insert sale_return_items
3. WHEN creating a sale return, THE Sale_Return_Repository SHALL update product_warehouses quantities
4. WHEN creating a sale return, THE Sale_Return_Repository SHALL update customer balance
5. WHEN creating a purchase return, THE Purchase_Return_Repository SHALL insert into purchase_returns table
6. WHEN creating a purchase return, THE Purchase_Return_Repository SHALL update product_warehouses quantities
7. THE Sale_Return_Repository SHALL validate return quantities against original sale

### المتطلب 18: تحويل Payment Method & Bank Account Repositories

**قصة المستخدم:** كمحاسب، أريد إدارة طرق الدفع والحسابات البنكية، حتى أتمكن من تتبع المدفوعات.

#### معايير القبول

1. WHEN fetching payment methods, THE Payment_Method_Repository SHALL query payment_methods table
2. WHEN creating a bank account, THE Bank_Account_Repository SHALL insert into bank_accounts table
3. WHEN updating bank balance, THE Bank_Account_Repository SHALL use Supabase update
4. THE Bank_Account_Repository SHALL support default bank account selection
5. THE Bank_Account_Repository SHALL include warehouse assignment for POS accounts

### المتطلب 19: إعداد Storage Service للصور

**قصة المستخدم:** كمستخدم، أريد رفع وإدارة الصور، حتى أتمكن من إضافة صور للمنتجات والعلامات التجارية.

#### معايير القبول

1. WHEN uploading an image, THE Storage_Service SHALL upload to Supabase Storage bucket
2. WHEN uploading an image, THE Storage_Service SHALL generate a unique filename
3. WHEN uploading an image, THE Storage_Service SHALL return the public URL
4. WHEN deleting an image, THE Storage_Service SHALL remove from Supabase Storage
5. THE Storage_Service SHALL support multiple image formats (jpg, png, webp)
6. THE Storage_Service SHALL validate image size before upload
7. THE Storage_Service SHALL organize images in folders by type (products, brands, categories)
8. THE Storage_Service SHALL support image compression before upload

### المتطلب 20: إعداد Real-Time Service

**قصة المستخدم:** كمستخدم، أريد استقبال التحديثات الفورية، حتى أتمكن من رؤية التغييرات في الوقت الفعلي.

#### معايير القبول

1. THE Real_Time_Service SHALL subscribe to Supabase channels for specified tables
2. WHEN a record is inserted, THE Real_Time_Service SHALL notify subscribers
3. WHEN a record is updated, THE Real_Time_Service SHALL notify subscribers
4. WHEN a record is deleted, THE Real_Time_Service SHALL notify subscribers
5. THE Real_Time_Service SHALL support filtering by specific conditions
6. THE Real_Time_Service SHALL handle connection errors and reconnection
7. THE Real_Time_Service SHALL unsubscribe when no longer needed

### المتطلب 21: إعداد Row Level Security (RLS) Policies

**قصة المستخدم:** كمدير نظام، أريد تطبيق سياسات الأمان، حتى أتمكن من حماية البيانات من الوصول غير المصرح.

#### معايير القبول

1. THE RLS SHALL be enabled on all tables
2. THE RLS SHALL allow admins to access only their warehouse data
3. THE RLS SHALL allow admins to access only data permitted by their role
4. THE RLS SHALL prevent unauthorized access to sensitive tables (admins, roles, permissions)
5. THE RLS SHALL allow read access to reference tables (categories, brands, units)
6. THE RLS SHALL validate user authentication before granting access
7. THE RLS SHALL support super admin role with full access

### المتطلب 22: تحديث Error Handling

**قصة المستخدم:** كمطور، أريد معالجة موحدة للأخطاء، حتى أتمكن من عرض رسائل خطأ واضحة للمستخدم.

#### معايير القبول

1. WHEN a Supabase error occurs, THE Error_Handler SHALL parse the error response
2. WHEN a network error occurs, THE Error_Handler SHALL return a user-friendly message
3. WHEN an authentication error occurs, THE Error_Handler SHALL trigger session expiry
4. WHEN a permission error occurs, THE Error_Handler SHALL return access denied message
5. THE Error_Handler SHALL log all errors for debugging
6. THE Error_Handler SHALL support error messages in Arabic and English
7. THE Error_Handler SHALL handle PostgreSQL constraint violations

### المتطلب 23: تحديث Dependencies

**قصة المستخدم:** كمطور، أريد تحديث التبعيات، حتى أتمكن من استخدام Supabase في المشروع.

#### معايير القبول

1. THE pubspec.yaml SHALL include supabase_flutter package
2. THE pubspec.yaml SHALL remove dio package dependency
3. THE pubspec.yaml SHALL include required Supabase dependencies
4. THE pubspec.yaml SHALL maintain compatibility with existing packages
5. THE pubspec.yaml SHALL use stable versions of all packages

### المتطلب 24: إعداد Environment Configuration

**قصة المستخدم:** كمطور، أريد إعداد متغيرات البيئة، حتى أتمكن من تكوين Supabase بشكل آمن.

#### معايير القبول

1. THE application SHALL load Supabase URL from environment variables
2. THE application SHALL load Supabase anon key from environment variables
3. THE application SHALL support multiple environments (development, production)
4. THE application SHALL not expose sensitive keys in source code
5. THE application SHALL validate environment variables on startup

### المتطلب 25: Migration Service للهجرة التدريجية

**قصة المستخدم:** كمطور، أريد خدمة هجرة تدريجية، حتى أتمكن من الانتقال بشكل آمن من Dio إلى Supabase.

#### معايير القبول

1. THE Migration_Service SHALL support feature flags for gradual migration
2. THE Migration_Service SHALL allow switching between Dio and Supabase per repository
3. THE Migration_Service SHALL log all migration activities
4. THE Migration_Service SHALL support rollback to Dio if issues occur
5. THE Migration_Service SHALL validate data consistency between old and new systems

### المتطلب 26: تحديث Models للتوافق مع Supabase

**قصة المستخدم:** كمطور، أريد تحديث نماذج البيانات، حتى تتوافق مع استجابات Supabase.

#### معايير القبول

1. THE models SHALL support JSON serialization from Supabase responses
2. THE models SHALL handle UUID fields correctly
3. THE models SHALL support nullable fields as per database schema
4. THE models SHALL include fromJson and toJson methods
5. THE models SHALL handle timestamp fields with timezone
6. THE models SHALL support nested objects for joined data

### المتطلب 27: تحديث POS Features

**قصة المستخدم:** كصراف، أريد استخدام نقطة البيع، حتى أتمكن من إتمام عمليات البيع بسرعة.

#### معايير القبول

1. WHEN fetching POS selections, THE POS_Repository SHALL query products with filters
2. WHEN fetching featured products, THE POS_Repository SHALL filter by is_featured
3. WHEN fetching category products, THE POS_Repository SHALL join with product_categories
4. WHEN fetching brand products, THE POS_Repository SHALL filter by brand_id
5. THE POS_Repository SHALL include product prices and warehouse quantities
6. THE POS_Repository SHALL support bundle products in POS
7. THE POS_Repository SHALL validate cashier shift before allowing sales

### المتطلب 28: تحديث Online Orders

**قصة المستخدم:** كمدير، أريد إدارة الطلبات الإلكترونية، حتى أتمكن من معالجة طلبات العملاء عبر الإنترنت.

#### معايير القبول

1. WHEN fetching online orders, THE Online_Order_Repository SHALL query online_orders table
2. WHEN creating an online order, THE Online_Order_Repository SHALL insert order and items
3. THE Online_Order_Repository SHALL include customer and branch data
4. THE Online_Order_Repository SHALL support order status updates
5. THE Online_Order_Repository SHALL handle currency conversion

### المتطلب 29: تحديث Points & Rewards System

**قصة المستخدم:** كعميل، أريد كسب واستخدام النقاط، حتى أتمكن من الحصول على مكافآت.

#### معايير القبول

1. WHEN a customer makes a purchase, THE Points_Service SHALL calculate earned points
2. WHEN a customer makes a purchase, THE Points_Service SHALL update customer total_points_earned
3. WHEN redeeming points, THE Points_Service SHALL validate available points
4. WHEN redeeming points, THE Points_Service SHALL deduct points from customer balance
5. THE Points_Service SHALL support configurable points rules

### المتطلب 30: Testing & Validation

**قصة المستخدم:** كمطور، أريد اختبار الهجرة، حتى أتأكد من عمل جميع الميزات بشكل صحيح.

#### معايير القبول

1. THE application SHALL pass all existing unit tests after migration
2. THE application SHALL pass integration tests for all repositories
3. THE application SHALL validate data integrity after migration
4. THE application SHALL perform load testing on Supabase queries
5. THE application SHALL test RLS policies for all user roles
6. THE application SHALL test real-time subscriptions
7. THE application SHALL test image upload and retrieval
8. THE application SHALL test authentication flow end-to-end
