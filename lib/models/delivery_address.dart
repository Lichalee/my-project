import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryAddress {
  final String id;
  final String label; // 'Home', 'Office', 'Apartment', 'Gift Recipient', 'Other'
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String subDistrict;
  final String district;
  final String province;
  final String postalCode;
  final String? note;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryAddress({
    required this.id,
    this.label = 'Home',
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    this.subDistrict = '',
    this.district = '',
    this.province = 'Bangkok',
    required this.postalCode,
    this.note,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress {
    final parts = [
      streetAddress,
      if (subDistrict.isNotEmpty) subDistrict,
      if (district.isNotEmpty) district,
      if (province.isNotEmpty) province,
      postalCode,
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'subDistrict': subDistrict,
      'district': district,
      'province': province,
      'postalCode': postalCode,
      'note': note,
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DeliveryAddress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DeliveryAddress.fromMap(doc.id, data);
  }

  factory DeliveryAddress.fromMap(String id, Map<String, dynamic> map) {
    return DeliveryAddress(
      id: id,
      label: map['label'] ?? 'Home',
      recipientName: map['recipientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      subDistrict: map['subDistrict'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? 'Bangkok',
      postalCode: map['postalCode'] ?? '',
      note: map['note'],
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? subDistrict,
    String? district,
    String? province,
    String? postalCode,
    String? note,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      subDistrict: subDistrict ?? this.subDistrict,
      district: district ?? this.district,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
