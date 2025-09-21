# 🗄️ Supabase Database Setup Guide

## **Step 1: Create Supabase Project (5 minutes)**

1. **Go to [Supabase](https://supabase.com)**
2. **Sign up** with GitHub/Google (free)
3. **Click "New Project"**
4. **Choose organization** (or create one)
5. **Project name**: `kanso-app`
6. **Database password**: Create a strong password
7. **Region**: Choose closest to your users
8. **Click "Create new project"**

## **Step 2: Get API Keys**

1. **Go to Project Settings** → **API**
2. **Copy these values**:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## **Step 3: Update Your App**

Replace the placeholder values in `lib/services/supabase_service.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL', // Replace with your Project URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your Anon Key
);
```

## **Step 4: Create Database Tables**

Run this SQL in **Supabase SQL Editor**:

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  total_sessions INTEGER DEFAULT 0,
  total_items_let_go INTEGER DEFAULT 0,
  total_items_evaluated INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create declutter_items table
CREATE TABLE declutter_items (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  photo_path TEXT,
  memo TEXT,
  is_kept BOOLEAN DEFAULT FALSE,
  is_discarded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_declutter_items_user_id ON declutter_items(user_id);
CREATE INDEX idx_declutter_items_kept ON declutter_items(user_id, is_kept);
CREATE INDEX idx_declutter_items_discarded ON declutter_items(user_id, is_discarded);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE declutter_items ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policies for declutter_items table
CREATE POLICY "Users can view own items" ON declutter_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items" ON declutter_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items" ON declutter_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items" ON declutter_items
  FOR DELETE USING (auth.uid() = user_id);
```

## **Step 5: Enable Authentication**

1. **Go to Authentication** → **Settings**
2. **Enable Email** provider
3. **Configure email templates** (optional)
4. **Set up redirect URLs** (for web)

## **Step 6: Test Your Setup**

1. **Update your app** with the API keys
2. **Run the app**: `flutter run -d web-server --web-port 8080`
3. **Test sign up/sign in**
4. **Add items and memories**
5. **Check Supabase dashboard** to see data!

## **🎉 Benefits of Supabase**

✅ **Real-time database** - Data syncs instantly  
✅ **User authentication** - Secure login/signup  
✅ **Row Level Security** - Users only see their data  
✅ **Free tier** - 500MB database, 50,000 monthly active users  
✅ **Web & Mobile** - Works on all platforms  
✅ **Auto-generated APIs** - No backend code needed  

## **🔧 Troubleshooting**

- **Connection issues**: Check your API keys
- **Permission errors**: Verify RLS policies
- **Data not saving**: Check browser console for errors
- **Authentication fails**: Verify email provider is enabled

Your Kanso app will now have persistent storage! 🌊✨
