import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/delivery_address.dart';

class AddressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  String? _userId;
  List<DeliveryAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  AddressProvider() {
    _initDemoAddresses();
  }

  List<DeliveryAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DeliveryAddress? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
  }

  void _initDemoAddresses() {
    _addresses = [
      DeliveryAddress(
        id: 'addr_demo_01',
        label: 'Home',
        recipientName: 'Lady Catherine de Bourgh',
        phoneNumber: '+66 81 234 5678',
        streetAddress: '88/12 Sukhumvit 55 (Thonglor Soi 10)',
        subDistrict: 'Khlong Tan Nuea',
        district: 'Watthana',
        province: 'Bangkok',
        postalCode: '10110',
        note: 'Leave with reception at tower concierge',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      DeliveryAddress(
        id: 'addr_demo_02',
        label: 'Office',
        recipientName: 'Catherine de Bourgh (Executive Suite)',
        phoneNumber: '+66 82 987 6543',
        streetAddress: 'Park Ventures Ecoplex, 24th Floor, Wireless Road',
        subDistrict: 'Lumphini',
        district: 'Pathum Wan',
        province: 'Bangkok',
        postalCode: '10330',
        note: 'Drop off at VIP reception desk',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();

    if (_userId == null) {
      _initDemoAddresses();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _listenToUserAddresses();
  }

  void _listenToUserAddresses() {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    final collection = _firestore.collection('users').doc(_userId).collection('addresses');

    _subscription = collection.orderBy('createdAt', descending: true).snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _addresses = snapshot.docs.map((doc) => DeliveryAddress.fromFirestore(doc)).toList();
          // Sort default first
          _addresses.sort((a, b) {
            if (a.isDefault && !b.isDefault) return -1;
            if (!a.isDefault && b.isDefault) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });
        } else {
          // If Firestore is empty, seed demo addresses
          _seedInitialAddressesToFirestore();
        }
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Address sync error: $err');
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _seedInitialAddressesToFirestore() async {
    if (_userId == null) return;
    final collection = _firestore.collection('users').doc(_userId).collection('addresses');
    for (final addr in _addresses) {
      await collection.doc(addr.id).set(addr.toMap());
    }
  }

  Future<bool> addAddress(DeliveryAddress address) async {
    try {
      final newId = address.id.isEmpty ? _uuid.v4() : address.id;
      final newAddress = address.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_userId != null) {
        final collection = _firestore.collection('users').doc(_userId).collection('addresses');
        // If set as default, unset others
        if (newAddress.isDefault) {
          await _unsetOtherDefaultsInFirestore(newId);
        }
        await collection.doc(newId).set(newAddress.toMap());
      } else {
        // Guest mode in-memory
        if (newAddress.isDefault) {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
        }
        _addresses.insert(0, newAddress);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding address: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(DeliveryAddress address) async {
    try {
      final updated = address.copyWith(updatedAt: DateTime.now());

      if (_userId != null) {
        final collection = _firestore.collection('users').doc(_userId).collection('addresses');
        if (updated.isDefault) {
          await _unsetOtherDefaultsInFirestore(updated.id);
        }
        await collection.doc(updated.id).update(updated.toMap());
      } else {
        if (updated.isDefault) {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
        }
        final idx = _addresses.indexWhere((a) => a.id == updated.id);
        if (idx != -1) {
          _addresses[idx] = updated;
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating address: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      if (_userId != null) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('addresses')
            .doc(addressId)
            .delete();
      } else {
        _addresses.removeWhere((a) => a.id == addressId);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      if (_userId != null) {
        await _unsetOtherDefaultsInFirestore(addressId);
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('addresses')
            .doc(addressId)
            .update({'isDefault': true, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
      } else {
        _addresses = _addresses.map((a) {
          return a.copyWith(isDefault: a.id == addressId);
        }).toList();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error setting default address: $e');
      return false;
    }
  }

  Future<void> _unsetOtherDefaultsInFirestore(String keepId) async {
    if (_userId == null) return;
    final collection = _firestore.collection('users').doc(_userId).collection('addresses');
    final snap = await collection.where('isDefault', isEqualTo: true).get();
    for (final doc in snap.docs) {
      if (doc.id != keepId) {
        await doc.reference.update({'isDefault': false});
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
