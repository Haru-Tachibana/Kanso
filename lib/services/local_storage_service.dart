import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/declutter_item.dart';

class LocalStorageService {
  static const String _userKey = 'kanso_user';
  static const String _itemsKey = 'kanso_items';
  static const String _keptItemsKey = 'kanso_kept_items';
  static const String _discardedItemsKey = 'kanso_discarded_items';

  // User operations
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      print('User saved locally: ${user.name}');
    } catch (e) {
      print('Error saving user locally: $e');
    }
  }

  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user locally: $e');
      return null;
    }
  }

  static Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  static Future<void> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('User deleted locally');
    } catch (e) {
      print('Error deleting user locally: $e');
    }
  }

  // Item operations
  static Future<void> saveDeclutterItem(DeclutterItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getDeclutterItems();
      items.add(item);
      await prefs.setString(_itemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
      print('Item saved locally: ${item.title}');
    } catch (e) {
      print('Error saving item locally: $e');
    }
  }

  static Future<List<DeclutterItem>> getDeclutterItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_itemsKey);
      if (itemsJson != null) {
        final itemsData = jsonDecode(itemsJson) as List<dynamic>;
        return itemsData.map((item) => DeclutterItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting items locally: $e');
      return [];
    }
  }

  static Future<void> updateDeclutterItem(DeclutterItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getDeclutterItems();
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
        await prefs.setString(_itemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
        print('Item updated locally: ${item.title}');
      }
    } catch (e) {
      print('Error updating item locally: $e');
    }
  }

  static Future<void> deleteDeclutterItem(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getDeclutterItems();
      items.removeWhere((item) => item.id == itemId);
      await prefs.setString(_itemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
      print('Item deleted locally: $itemId');
    } catch (e) {
      print('Error deleting item locally: $e');
    }
  }

  // Kept items operations
  static Future<void> saveKeptItem(DeclutterItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getKeptItems();
      items.add(item);
      await prefs.setString(_keptItemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
      print('Kept item saved locally: ${item.title}');
    } catch (e) {
      print('Error saving kept item locally: $e');
    }
  }

  static Future<List<DeclutterItem>> getKeptItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_keptItemsKey);
      if (itemsJson != null) {
        final itemsData = jsonDecode(itemsJson) as List<dynamic>;
        return itemsData.map((item) => DeclutterItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting kept items locally: $e');
      return [];
    }
  }

  // Discarded items operations
  static Future<void> saveDiscardedItem(DeclutterItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getDiscardedItems();
      items.add(item);
      await prefs.setString(_discardedItemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
      print('Discarded item saved locally: ${item.title}');
    } catch (e) {
      print('Error saving discarded item locally: $e');
    }
  }

  static Future<List<DeclutterItem>> getDiscardedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_discardedItemsKey);
      if (itemsJson != null) {
        final itemsData = jsonDecode(itemsJson) as List<dynamic>;
        return itemsData.map((item) => DeclutterItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting discarded items locally: $e');
      return [];
    }
  }

  static Future<void> updateDiscardedItem(DeclutterItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await getDiscardedItems();
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
        await prefs.setString(_discardedItemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
        print('Discarded item updated locally: ${item.title}');
      }
    } catch (e) {
      print('Error updating discarded item locally: $e');
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_itemsKey);
      await prefs.remove(_keptItemsKey);
      await prefs.remove(_discardedItemsKey);
      print('All data cleared locally');
    } catch (e) {
      print('Error clearing data locally: $e');
    }
  }
}
