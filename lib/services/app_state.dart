import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/declutter_item.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<DeclutterItem> _items = [];
  List<DeclutterItem> _keptItems = [];
  List<DeclutterItem> _discardedItems = [];
  List<DeclutterItem> _currentSessionKeptItems = [];
  List<DeclutterItem> _currentSessionDiscardedItems = [];
  bool _isChinese = false;
  bool _sessionCompleted = false;

  // Getters
  User? get currentUser => _currentUser;
  List<DeclutterItem> get items => _items;
  List<DeclutterItem> get keptItems => _keptItems;
  List<DeclutterItem> get discardedItems => _discardedItems;
  List<DeclutterItem> get currentSessionKeptItems => _currentSessionKeptItems;
  List<DeclutterItem> get currentSessionDiscardedItems => _currentSessionDiscardedItems;
  bool get isChinese => _isChinese;

  // User management
  Future<void> setUser(User user) async {
    print('Setting user: ${user.name} (${user.id})');
    _currentUser = user;
    
    // Only save to Supabase if not a guest user
    if (!user.id.startsWith('guest_')) {
      try {
        await SupabaseService.saveUser(user);
        print('User saved to Supabase successfully');
      } catch (e) {
        print('Error saving user to Supabase: $e');
      }
      await _loadUserData();
    } else {
      print('Guest user - skipping Supabase save');
    }
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _currentUser = user;
    await SupabaseService.updateUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    _currentUser = null;
    _items.clear();
    _keptItems.clear();
    _discardedItems.clear();
    _sessionCompleted = false;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    
    try {
      _items = await SupabaseService.getDeclutterItems(_currentUser!.id);
      _keptItems = await SupabaseService.getKeptItems(_currentUser!.id);
      _discardedItems = await SupabaseService.getDiscardedItems(_currentUser!.id);
      print('Loaded data from Supabase: ${_items.length} items, ${_keptItems.length} kept, ${_discardedItems.length} discarded');
    } catch (e) {
      print('Error loading user data from Supabase: $e');
      // Initialize empty lists if Supabase fails
      _items = [];
      _keptItems = [];
      _discardedItems = [];
    }
  }

  // Language management
  void toggleLanguage() {
    _isChinese = !_isChinese;
    notifyListeners();
  }

  // Item management
  Future<void> addItem(DeclutterItem item) async {
    print('Adding item: ${item.title}');
    print('Current user: ${_currentUser?.name} (${_currentUser?.id})');
    _items.add(item);
    if (_currentUser != null && !_currentUser!.id.startsWith('guest_')) {
      try {
        await SupabaseService.saveDeclutterItem(item, _currentUser!.id);
        print('Item saved to Supabase successfully');
      } catch (e) {
        print('Error saving item to Supabase: $e');
      }
    } else {
      print('Guest user or no current user - item saved locally only');
    }
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    if (_currentUser != null) {
      await SupabaseService.deleteDeclutterItem(id, _currentUser!.id);
    }
    notifyListeners();
  }

  Future<void> updateItem(DeclutterItem updatedItem) async {
    // Update in current items list
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
    }
    
    // Update in kept items list
    final keptIndex = _keptItems.indexWhere((item) => item.id == updatedItem.id);
    if (keptIndex != -1) {
      _keptItems[keptIndex] = updatedItem;
    }
    
    // Update in discarded items list
    final discardedIndex = _discardedItems.indexWhere((item) => item.id == updatedItem.id);
    if (discardedIndex != -1) {
      _discardedItems[discardedIndex] = updatedItem;
    }
    
    if (_currentUser != null) {
      await SupabaseService.updateDeclutterItem(updatedItem, _currentUser!.id);
    }
    notifyListeners();
  }

  // Declutter process
  Future<void> keepItem(DeclutterItem item) async {
    final keptItem = item.copyWith(isKept: true);
    _keptItems.add(keptItem);
    _currentSessionKeptItems.add(keptItem);
    _items.removeWhere((i) => i.id == item.id);
    if (_currentUser != null && !_currentUser!.id.startsWith('guest_')) {
      await SupabaseService.saveDeclutterItem(keptItem, _currentUser!.id);
    }
    notifyListeners();
  }

  Future<void> discardItem(DeclutterItem item) async {
    final discardedItem = item.copyWith(isDiscarded: true);
    _discardedItems.add(discardedItem);
    _currentSessionDiscardedItems.add(discardedItem);
    _items.removeWhere((i) => i.id == item.id);
    if (_currentUser != null && !_currentUser!.id.startsWith('guest_')) {
      await SupabaseService.saveDeclutterItem(discardedItem, _currentUser!.id);
    }
    notifyListeners();
  }

  void completeSession() {
    if (_currentUser != null && !_sessionCompleted) {
      // Count items from current session only
      final sessionDiscardedCount = _currentSessionDiscardedItems.length;
      final sessionKeptCount = _currentSessionKeptItems.length;
      final totalItemsInSession = sessionDiscardedCount + sessionKeptCount;
      
      _currentUser = _currentUser!.copyWith(
        totalSessions: (_currentUser!.totalSessions ?? 0) + 1,
        totalItemsLetGo: (_currentUser!.totalItemsLetGo ?? 0) + sessionDiscardedCount,
        totalItemsEvaluated: (_currentUser!.totalItemsEvaluated ?? 0) + totalItemsInSession,
      );
      _sessionCompleted = true;
    }
    notifyListeners();
  }

  void clearSession() {
    _items.clear();
    _keptItems.clear();
    _currentSessionKeptItems.clear();
    _currentSessionDiscardedItems.clear();
    // Don't clear discarded items - they contain memories
    // _discardedItems.clear();
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
