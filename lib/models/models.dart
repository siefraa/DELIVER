import 'package:flutter/material.dart';

// ─── Order Model ───────────────────────────────────────────────
enum OrderStatus { pending, pickup, inTransit, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.pickup: return 'Pickup';
      case OrderStatus.inTransit: return 'In Transit';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending: return const Color(0xFFF39C12);
      case OrderStatus.pickup: return const Color(0xFF3498DB);
      case OrderStatus.inTransit: return const Color(0xFF9B59B6);
      case OrderStatus.delivered: return const Color(0xFF2ECC71);
      case OrderStatus.cancelled: return const Color(0xFFE74C3C);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending: return Icons.hourglass_empty_rounded;
      case OrderStatus.pickup: return Icons.inventory_2_rounded;
      case OrderStatus.inTransit: return Icons.local_shipping_rounded;
      case OrderStatus.delivered: return Icons.check_circle_rounded;
      case OrderStatus.cancelled: return Icons.cancel_rounded;
    }
  }
}

class DeliveryOrder {
  final String id;
  final String trackingNumber;
  final String clientName;
  final String clientPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final String packageDescription;
  final double packageWeight;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? driverName;
  final String? driverPhone;
  final String deliveryType;
  final String paymentMethod;
  final List<OrderTimeline> timeline;

  DeliveryOrder({
    required this.id,
    required this.trackingNumber,
    required this.clientName,
    required this.clientPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.packageDescription,
    required this.packageWeight,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.driverName,
    this.driverPhone,
    required this.deliveryType,
    required this.paymentMethod,
    required this.timeline,
  });
}

class OrderTimeline {
  final String title;
  final String description;
  final DateTime time;
  final bool isCompleted;
  final bool isCurrent;

  OrderTimeline({
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    required this.isCurrent,
  });
}

// ─── Driver Model ──────────────────────────────────────────────
enum DriverStatus { available, busy, offline }

class Driver {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleType;
  final String licenseNumber;
  final DriverStatus status;
  final double rating;
  final int totalDeliveries;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.licenseNumber,
    required this.status,
    required this.rating,
    required this.totalDeliveries,
    this.photoUrl,
    this.latitude,
    this.longitude,
  });

  Color get statusColor {
    switch (status) {
      case DriverStatus.available: return const Color(0xFF2ECC71);
      case DriverStatus.busy: return const Color(0xFFF39C12);
      case DriverStatus.offline: return const Color(0xFF95A5A6);
    }
  }

  String get statusLabel {
    switch (status) {
      case DriverStatus.available: return 'Available';
      case DriverStatus.busy: return 'Busy';
      case DriverStatus.offline: return 'Offline';
    }
  }
}

// ─── Client / User Model ──────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final int totalOrders;
  final String preferredLanguage;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.isAdmin,
    required this.createdAt,
    required this.totalOrders,
    required this.preferredLanguage,
  });
}

// ─── Notification Model ───────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime time;
  final String type; // order, system, promo

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.time,
    required this.type,
  });
}

// ─── Dashboard Stats ──────────────────────────────────────────
class DashboardStats {
  final int totalOrders;
  final int activeDeliveries;
  final int completedToday;
  final double totalRevenue;
  final int availableDrivers;
  final int totalClients;

  DashboardStats({
    required this.totalOrders,
    required this.activeDeliveries,
    required this.completedToday,
    required this.totalRevenue,
    required this.availableDrivers,
    required this.totalClients,
  });
}

// ─── Sample Data ──────────────────────────────────────────────
class SampleData {
  static List<DeliveryOrder> get orders => [
    DeliveryOrder(
      id: '1', trackingNumber: 'DEL-2024-001',
      clientName: 'Amina Hassan', clientPhone: '+255 712 345 678',
      pickupAddress: 'Kariakoo Market, Dar es Salaam',
      deliveryAddress: 'Masaki Peninsula, Dar es Salaam',
      packageDescription: 'Electronics - Laptop',
      packageWeight: 2.5, amount: 15000,
      status: OrderStatus.inTransit,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
      driverName: 'John Mwangi', driverPhone: '+255 765 432 109',
      deliveryType: 'Express', paymentMethod: 'Mobile Money',
      timeline: [
        OrderTimeline(title: 'Order Placed', description: 'Your order has been received', time: DateTime.now().subtract(const Duration(hours: 3)), isCompleted: true, isCurrent: false),
        OrderTimeline(title: 'Picked Up', description: 'Package collected from sender', time: DateTime.now().subtract(const Duration(hours: 2)), isCompleted: true, isCurrent: false),
        OrderTimeline(title: 'In Transit', description: 'On the way to destination', time: DateTime.now().subtract(const Duration(minutes: 30)), isCompleted: false, isCurrent: true),
        OrderTimeline(title: 'Delivered', description: 'Package delivered successfully', time: DateTime.now().add(const Duration(hours: 2)), isCompleted: false, isCurrent: false),
      ],
    ),
    DeliveryOrder(
      id: '2', trackingNumber: 'DEL-2024-002',
      clientName: 'Peter Kimani', clientPhone: '+255 723 456 789',
      pickupAddress: 'Ilala, Dar es Salaam',
      deliveryAddress: 'Kinondoni, Dar es Salaam',
      packageDescription: 'Documents & Books',
      packageWeight: 0.8, amount: 8000,
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDelivery: DateTime.now().subtract(const Duration(hours: 20)),
      driverName: 'Sarah Odhiambo', driverPhone: '+255 754 321 098',
      deliveryType: 'Standard', paymentMethod: 'Cash on Delivery',
      timeline: [],
    ),
    DeliveryOrder(
      id: '3', trackingNumber: 'DEL-2024-003',
      clientName: 'Grace Mushi', clientPhone: '+255 689 234 567',
      pickupAddress: 'Mbezi Beach, Dar es Salaam',
      deliveryAddress: 'Temeke, Dar es Salaam',
      packageDescription: 'Clothing & Accessories',
      packageWeight: 1.2, amount: 10000,
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 5)),
      deliveryType: 'Standard', paymentMethod: 'Mobile Money',
      timeline: [],
    ),
    DeliveryOrder(
      id: '4', trackingNumber: 'DEL-2024-004',
      clientName: 'Mohamed Ali', clientPhone: '+255 700 111 222',
      pickupAddress: 'Posta, Dar es Salaam',
      deliveryAddress: 'Mwenge, Dar es Salaam',
      packageDescription: 'Food & Groceries',
      packageWeight: 3.0, amount: 12000,
      status: OrderStatus.pickup,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 3)),
      driverName: 'Felix Omondi', driverPhone: '+255 756 789 012',
      deliveryType: 'Express', paymentMethod: 'Cash on Delivery',
      timeline: [],
    ),
  ];

  static List<Driver> get drivers => [
    Driver(id: '1', name: 'John Mwangi', phone: '+255 765 432 109', email: 'john@driver.com', vehicleType: 'Motorcycle', licenseNumber: 'TZ-MC-001', status: DriverStatus.busy, rating: 4.8, totalDeliveries: 342),
    Driver(id: '2', name: 'Sarah Odhiambo', phone: '+255 754 321 098', email: 'sarah@driver.com', vehicleType: 'Bicycle', licenseNumber: 'TZ-BC-002', status: DriverStatus.available, rating: 4.9, totalDeliveries: 218),
    Driver(id: '3', name: 'Felix Omondi', phone: '+255 756 789 012', email: 'felix@driver.com', vehicleType: 'Car', licenseNumber: 'TZ-CA-003', status: DriverStatus.available, rating: 4.6, totalDeliveries: 156),
    Driver(id: '4', name: 'Zara Msomi', phone: '+255 745 678 901', email: 'zara@driver.com', vehicleType: 'Van', licenseNumber: 'TZ-VN-004', status: DriverStatus.offline, rating: 4.7, totalDeliveries: 89),
  ];

  static DashboardStats get stats => DashboardStats(
    totalOrders: 1247,
    activeDeliveries: 23,
    completedToday: 45,
    totalRevenue: 3850000,
    availableDrivers: 8,
    totalClients: 342,
  );
}
