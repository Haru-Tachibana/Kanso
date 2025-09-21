import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/declutter_item.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<DeclutterItem> _items = [];
  List<DeclutterItem> _keptItems = [];
  List<DeclutterItem> _discardedItems = [];
  bool _isChinese = false;
  bool _sessionCompleted = false;

  // Getters
  User? get currentUser => _currentUser;
  List<DeclutterItem> get items => _items;
  List<DeclutterItem> get keptItems => _keptItems;
  List<DeclutterItem> get discardedItems => _discardedItems;
  bool get isChinese => _isChinese;

  // User management
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _items.clear();
    _keptItems.clear();
    _discardedItems.clear();
    notifyListeners();
  }

  // Language management
  void toggleLanguage() {
    _isChinese = !_isChinese;
    notifyListeners();
  }

  // Item management
  void addItem(DeclutterItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateItem(DeclutterItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  // Declutter process
  void keepItem(DeclutterItem item) {
    final keptItem = item.copyWith(isKept: true);
    _keptItems.add(keptItem);
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  void discardItem(DeclutterItem item) {
    final discardedItem = item.copyWith(isDiscarded: true);
    _discardedItems.add(discardedItem);
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  void completeSession() {
    if (_currentUser != null && !_sessionCompleted) {
      final currentDiscardedCount = _discardedItems.length;
      final currentKeptCount = _keptItems.length;
      final totalItemsInSession = currentDiscardedCount + currentKeptCount;
      
      _currentUser = _currentUser!.copyWith(
        totalSessions: _currentUser!.totalSessions + 1,
        totalItemsLetGo: _currentUser!.totalItemsLetGo + currentDiscardedCount,
        totalItemsEvaluated: _currentUser!.totalItemsEvaluated + totalItemsInSession,
      );
      _sessionCompleted = true;
    }
    notifyListeners();
  }

  void clearSession() {
    _items.clear();
    _keptItems.clear();
    _discardedItems.clear();
    _sessionCompleted = false;
    notifyListeners();
  }

  void startNewSession() {
    _sessionCompleted = false;
    notifyListeners();
  }

  // Statistics
  int get totalSessions => _currentUser?.totalSessions ?? 0;
  int get totalItemsLetGo => _currentUser?.totalItemsLetGo ?? 0;
  int get totalItemsEvaluated => _currentUser?.totalItemsEvaluated ?? 0;
}
