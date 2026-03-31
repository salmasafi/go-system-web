class PosCustomer {
  final String id;
  final String name;
  final String? email;
  final String phoneNumber;
  final String? address;
  final String? country;
  final String? city;
  final String? customerGroupId;
  final double totalPointsEarned;
  final double amountDue;
  final bool isDue;

  const PosCustomer({
    required this.id,
    required this.name,
    this.email,
    required this.phoneNumber,
    this.address,
    this.country,
    this.city,
    this.customerGroupId,
    this.totalPointsEarned = 0.0,
    this.amountDue = 0.0,
    this.isDue = false,
  });

  factory PosCustomer.fromJson(Map<String, dynamic> json) {
    return PosCustomer(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      customerGroupId: json['customer_group_id']?.toString(),
      totalPointsEarned: (json['total_points_earned'] as num?)?.toDouble() ?? 0.0,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      isDue: json['is_due'] == true || json['is_due'] == 1,
    );
  }

  /// Used as the POST body when creating a new customer.
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (address != null && address!.isNotEmpty) 'address': address,
    };
  }
}
