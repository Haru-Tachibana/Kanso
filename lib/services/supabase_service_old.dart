import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart' as kanso_user;
import '../models/declutter_item.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");
      
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      if (url == null || anonKey == null) {
        throw Exception('Supabase environment variables not found');
      }
      
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      
      print('Supabase initialized successfully with URL: $url');
    } catch (e) {
      print('Supabase initialization failed: $e');
      rethrow;
    }
  }

  // User operations
  static Future<void> saveUser(kanso_user.User user) async {
    try {
      await client.from('users').upsert(user.toJson());
      print('User saved to Supabase: ${user.name}');
    } catch (e) {
      print('Error saving user: $e');
      throw e;
    }
  }

  static bool _isSupabaseConfigured() {
    try {
      // Check if Supabase is properly initialized
      return Supabase.instance.client != null;
    } catch (e) {
      return false;
    }
  }

  static Future<kanso_user.User?> getUser(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return kanso_user.User.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(kanso_user.User user) async {
    try {
      await client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
      print('User updated in Supabase: ${user.name}');
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  // Declutter item operations
  static Future<void> saveDeclutterItem(DeclutterItem item, String userId) async {
    try {
      final itemData = item.toJson();
      itemData['user_id'] = userId;
      await client.from('declutter_items').upsert(itemData);
      print('Item saved to Supabase: ${item.title}');
    } catch (e) {
      print('Error saving declutter item: $e');
      throw e;
    }
  }

  static Future<List<DeclutterItem>> getDeclutterItems(String userId) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - returning empty list');
        return [];
      }
      final response = await client
          .from('declutter_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response
          .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting declutter items: $e');
      return [];
    }
  }

  static Future<List<DeclutterItem>> getDiscardedItems(String userId) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - returning empty list');
        return [];
      }
      final response = await client
          .from('declutter_items')
          .select()
          .eq('user_id', userId)
          .eq('is_discarded', true)
          .order('created_at', ascending: false);
      
      return response
          .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting discarded items: $e');
      return [];
    }
  }

  static Future<List<DeclutterItem>> getKeptItems(String userId) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - returning empty list');
        return [];
      }
      final response = await client
          .from('declutter_items')
          .select()
          .eq('user_id', userId)
          .eq('is_kept', true)
          .order('created_at', ascending: false);
      
      return response
          .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting kept items: $e');
      return [];
    }
  }

  static Future<void> updateDeclutterItem(DeclutterItem item, String userId) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - item updated locally');
        return;
      }
      final itemData = item.toJson();
      itemData['user_id'] = userId;
      await client
          .from('declutter_items')
          .update(itemData)
          .eq('id', item.id);
    } catch (e) {
      print('Error updating declutter item: $e');
      throw e;
    }
  }

  static Future<void> deleteDeclutterItem(String itemId, String userId) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - item deleted locally');
        return;
      }
      await client
          .from('declutter_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleting declutter item: $e');
      throw e;
    }
  }

  // Authentication
  static Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - using mock authentication');
        // Return a mock response for local testing
        return AuthResponse(
          user: null,
          session: null,
        );
      }
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return response;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - using mock authentication');
        // Return a mock response for local testing
        return AuthResponse(
          user: null,
          session: null,
        );
      }
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      if (!_isSupabaseConfigured()) {
        print('Supabase not configured - signed out locally');
        return;
      }
      await client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static kanso_user.User? getCurrentUser() {
    if (!_isSupabaseConfigured()) {
      print('Supabase not configured - no current user');
      return null;
    }
    final session = client.auth.currentSession;
    if (session?.user != null) {
      return kanso_user.User(
        id: session!.user.id,
        email: session.user.email ?? '',
        name: session.user.userMetadata?['name'] ?? 'User',
        createdAt: DateTime.parse(session.user.createdAt),
      );
    }
    return null;
  }
}
