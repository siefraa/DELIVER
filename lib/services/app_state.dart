import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // Theme
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Language
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // Auth
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Selected bottom nav index
  int _clientNavIndex = 0;
  int get clientNavIndex => _clientNavIndex;
  int _adminNavIndex = 0;
  int get adminNavIndex => _adminNavIndex;

  // Orders
  List<DeliveryOrder> _orders = SampleData.orders;
  List<DeliveryOrder> get orders => _orders;

  // Drivers
  List<Driver> _drivers = SampleData.drivers;
  List<Driver> get drivers => _drivers;

  // Notifications count
  int _unreadNotifications = 3;
  int get unreadNotifications => _unreadNotifications;

  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    final lang = prefs.getString('language') ?? 'en';
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

  void loginAsClient() {
    _currentUser = AppUser(
      id: 'c1', name: 'Amina Hassan', email: 'amina@example.com',
      phone: '+255 712 345 678', isAdmin: false,
      createdAt: DateTime(2023, 1, 15), totalOrders: 12,
      preferredLanguage: 'en',
    );
    notifyListeners();
  }

  void loginAsAdmin() {
    _currentUser = AppUser(
      id: 'a1', name: 'Admin User', email: 'admin@delivereasy.com',
      phone: '+255 800 000 001', isAdmin: true,
      createdAt: DateTime(2022, 6, 1), totalOrders: 0,
      preferredLanguage: 'en',
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _clientNavIndex = 0;
    _adminNavIndex = 0;
    notifyListeners();
  }

  void setClientNavIndex(int index) {
    _clientNavIndex = index;
    notifyListeners();
  }

  void setAdminNavIndex(int index) {
    _adminNavIndex = index;
    notifyListeners();
  }

  void markNotificationsRead() {
    _unreadNotifications = 0;
    notifyListeners();
  }

  void addOrder(DeliveryOrder order) {
    _orders = [order, ..._orders];
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    _orders = _orders.map((o) {
      if (o.id == orderId) {
        return DeliveryOrder(
          id: o.id, trackingNumber: o.trackingNumber,
          clientName: o.clientName, clientPhone: o.clientPhone,
          pickupAddress: o.pickupAddress, deliveryAddress: o.deliveryAddress,
          packageDescription: o.packageDescription, packageWeight: o.packageWeight,
          amount: o.amount, status: status, createdAt: o.createdAt,
          estimatedDelivery: o.estimatedDelivery, driverName: o.driverName,
          driverPhone: o.driverPhone, deliveryType: o.deliveryType,
          paymentMethod: o.paymentMethod, timeline: o.timeline,
        );
      }
      return o;
    }).toList();
    notifyListeners();
  }
}
