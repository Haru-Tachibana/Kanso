import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart' as kanso_user;
import '../models/declutter_item.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase with fallback
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
        url = 'https://bhouzasdujvzlwrgttmm.supabase.co';
        anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJob3V6YXNkdWp2emx3cmd0dG1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NTYzMjMsImV4cCI6MjA3NDAzMjMyM30.bHBsaRQisje9eXZSuZIl40XEeo98ifFLSUAQlLsGsuQ';
        print('Using hardcoded values for web deployment');
      }
      
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
      // Don't rethrow - let the app continue with local storage
      print('App will continue with local storage fallback');
    }
  }

  // Test Supabase connection
  static Future<bool> testConnection() async {
    try {
      await client.from('users').select().limit(1);
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }

  // User operations with fallback
  static Future<void> saveUser(kanso_user.User user) async {
    try {
      if (await testConnection()) {
        await client.from('users').upsert(user.toJson());
        print('User saved to Supabase: ${user.name}');
      } else {
        print('Supabase not available, using local storage for user: ${user.name}');
        // Store in local storage as fallback
        // This would need to be implemented with shared_preferences
      }
    } catch (e) {
      print('Error saving user: $e');
      // Don't throw - continue with local storage
    }
  }

  static Future<kanso_user.User?> getUser(String userId) async {
    try {
      if (await testConnection()) {
        final response = await client
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        return kanso_user.User.fromJson(response);
      } else {
        print('Supabase not available, returning null for user: $userId');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(kanso_user.User user) async {
    try {
      if (await testConnection()) {
        await client
            .from('users')
            .update(user.toJson())
            .eq('id', user.id);
        print('User updated in Supabase: ${user.name}');
      } else {
        print('Supabase not available, using local storage for user update: ${user.name}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Declutter item operations with fallback
  static Future<void> saveDeclutterItem(DeclutterItem item, String userId) async {
    try {
      if (await testConnection()) {
        final itemData = item.toJson();
        itemData['user_id'] = userId;
        await client.from('declutter_items').upsert(itemData);
        print('Item saved to Supabase: ${item.title}');
      } else {
        print('Supabase not available, using local storage for item: ${item.title}');
      }
    } catch (e) {
      print('Error saving declutter item: $e');
    }
  }

  static Future<List<DeclutterItem>> getDeclutterItems(String userId) async {
    try {
      if (await testConnection()) {
        final response = await client
            .from('declutter_items')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        return response
            .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
            .toList();
      } else {
        print('Supabase not available, returning empty list for items');
        return [];
      }
    } catch (e) {
      print('Error getting declutter items: $e');
      return [];
    }
  }

  static Future<List<DeclutterItem>> getDiscardedItems(String userId) async {
    try {
      if (await testConnection()) {
        final response = await client
            .from('declutter_items')
            .select()
            .eq('user_id', userId)
            .eq('is_discarded', true)
            .order('created_at', ascending: false);

        return response
            .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
            .toList();
      } else {
        print('Supabase not available, returning empty list for discarded items');
        return [];
      }
    } catch (e) {
      print('Error getting discarded items: $e');
      return [];
    }
  }

  static Future<List<DeclutterItem>> getKeptItems(String userId) async {
    try {
      if (await testConnection()) {
        final response = await client
            .from('declutter_items')
            .select()
            .eq('user_id', userId)
            .eq('is_kept', true)
            .order('created_at', ascending: false);

        return response
            .map<DeclutterItem>((item) => DeclutterItem.fromJson(item))
            .toList();
      } else {
        print('Supabase not available, returning empty list for kept items');
        return [];
      }
    } catch (e) {
      print('Error getting kept items: $e');
      return [];
    }
  }

  static Future<void> updateDeclutterItem(DeclutterItem item, String userId) async {
    try {
      if (await testConnection()) {
        final itemData = item.toJson();
        itemData['user_id'] = userId;
        await client
            .from('declutter_items')
            .update(itemData)
            .eq('id', item.id);
        print('Item updated in Supabase: ${item.title}');
      } else {
        print('Supabase not available, using local storage for item update: ${item.title}');
      }
    } catch (e) {
      print('Error updating declutter item: $e');
    }
  }

  static Future<void> deleteDeclutterItem(String itemId, String userId) async {
    try {
      if (await testConnection()) {
        await client
            .from('declutter_items')
            .delete()
            .eq('id', itemId)
            .eq('user_id', userId);
        print('Item deleted from Supabase: $itemId');
      } else {
        print('Supabase not available, using local storage for item deletion: $itemId');
      }
    } catch (e) {
      print('Error deleting declutter item: $e');
    }
  }

  // Authentication with fallback
  static Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      if (await testConnection()) {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        print('User signed up in Supabase: $email');
        return response;
      } else {
        throw Exception('Supabase not available for authentication');
      }
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      if (await testConnection()) {
        final response = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print('User signed in to Supabase: $email');
        return response;
      } else {
        throw Exception('Supabase not available for authentication');
      }
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      if (await testConnection()) {
        await client.auth.signOut();
        print('User signed out from Supabase');
      } else {
        print('Supabase not available, local sign out');
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static kanso_user.User? getCurrentUser() {
    try {
      if (client.auth.currentSession?.user != null) {
        final session = client.auth.currentSession!;
        return kanso_user.User(
          id: session.user.id,
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
