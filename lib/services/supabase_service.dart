import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart' as kanso_user;
import '../models/declutter_item.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    if (_client == null) {
      _client = Supabase.instance.client;
    }
    return _client!;
  }
  
  static bool get isInitialized => _client != null;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      String? url;
      String? anonKey;
      
      // Try to load from .env file first
      try {
        await dotenv.load(fileName: ".env");
        url = dotenv.env['SUPABASE_URL'];
        anonKey = dotenv.env['SUPABASE_ANON_KEY'];
        print('Loaded from .env file');
      } catch (e) {
        print('Could not load .env file, trying environment variables: $e');
      }
      
      // If .env failed, try environment variables (for web deployment)
      if (url == null || anonKey == null) {
        url = const String.fromEnvironment('SUPABASE_URL');
        anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
        print('Using environment variables');
      }
      
      // Fallback to hardcoded values for web deployment
      if (url == null || anonKey == null) {
        url = 'https://iyvzsyvwczoprjmcjclq.supabase.co';
        anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5dnpzeXZ3Y3pvcHJqbWNqY2xxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NjYxMjQsImV4cCI6MjA3NDA0MjEyNH0.bI3fZFrcapzKNeyTCDw0E0VVSVxq0D_baMgcQo1A_wA';
        print('Using hardcoded values for web deployment');
      }
      
      if (url == null || anonKey == null) {
        throw Exception('Supabase environment variables not found');
      }
      
      print('Initializing Supabase with URL: $url');
      print('Anon Key: ${anonKey.length > 20 ? anonKey.substring(0, 20) + '...' : anonKey}');
      
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      
      // Set the client after initialization
      _client = Supabase.instance.client;
      
      // Test the connection (optional - don't fail initialization if this fails)
      try {
        await client.from('users').select().limit(1);
        print('Supabase connection test successful');
      } catch (e) {
        print('Supabase connection test failed: $e');
        print('Continuing with initialization - connection will be tested during first use');
      }
      
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
      final itemData = item.toJson();
      itemData['user_id'] = userId;
      await client
          .from('declutter_items')
          .update(itemData)
          .eq('id', item.id);
      print('Item updated in Supabase: ${item.title}');
    } catch (e) {
      print('Error updating declutter item: $e');
      throw e;
    }
  }

  static Future<void> deleteDeclutterItem(String itemId, String userId) async {
    try {
      await client
          .from('declutter_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
      print('Item deleted from Supabase: $itemId');
    } catch (e) {
      print('Error deleting declutter item: $e');
      throw e;
    }
  }

  // Authentication
  static Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized. Please restart the app.');
      }
      
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      print('User signed up in Supabase: $email');
      return response;
    } catch (e) {
      print('Error signing up: $e');
      if (e.toString().contains('DOCTYPE') || e.toString().contains('HTML')) {
        throw Exception('Database not set up. Please run the SQL setup in Supabase dashboard.');
      }
      rethrow;
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      if (!isInitialized) {
        throw Exception('Supabase not initialized. Please restart the app.');
      }
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('User signed in to Supabase: $email');
      return response;
    } catch (e) {
      print('Error signing in: $e');
      if (e.toString().contains('DOCTYPE') || e.toString().contains('HTML')) {
        throw Exception('Database not set up. Please run the SQL setup in Supabase dashboard.');
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('User signed out from Supabase');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static kanso_user.User? getCurrentUser() {
    try {
      if (!isInitialized) {
        print('Supabase not initialized');
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
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
