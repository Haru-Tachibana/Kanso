# 🚨 URGENT: Fix Supabase Authentication Error

## **❌ Current Error:**
```
AuthUnknownException: Failed to decode error response
FormatException: SyntaxError: Unexpected token '<, "‹!DOCTYPE ... is not valid JSON
```

## **🔍 Root Cause:**
The Supabase database tables haven't been created yet. The app is trying to authenticate but the database structure doesn't exist.

## **✅ QUICK FIX (5 minutes):**

### **Step 1: Go to Supabase Dashboard**
1. **Open [supabase.com](https://supabase.com)**
2. **Sign in** to your account
3. **Find your project** (bhouzasdujvzlwrgttmm)

### **Step 2: Create Database Tables**
1. **Go to SQL Editor** (left sidebar)
2. **Click "New Query"**
3. **Copy and paste this SQL:**

```sql
-- Create users table
CREATE TABLE IF NOT EXISTS users (
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
CREATE TABLE IF NOT EXISTS declutter_items (
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_declutter_items_user_id ON declutter_items(user_id);
CREATE INDEX IF NOT EXISTS idx_declutter_items_kept ON declutter_items(user_id, is_kept);
CREATE INDEX IF NOT EXISTS idx_declutter_items_discarded ON declutter_items(user_id, is_discarded);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE declutter_items ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY IF NOT EXISTS "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policies for declutter_items table
CREATE POLICY IF NOT EXISTS "Users can view own items" ON declutter_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can insert own items" ON declutter_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can update own items" ON declutter_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Users can delete own items" ON declutter_items
  FOR DELETE USING (auth.uid() = user_id);
```

4. **Click "Run"** to execute the SQL

### **Step 3: Enable Authentication**
1. **Go to Authentication** → **Settings**
2. **Make sure "Enable email confirmations" is OFF** (for testing)
3. **Save changes**

### **Step 4: Test Your App**
1. **Go to your Netlify site**
2. **Try signing up** with a real email
3. **Should work now!**

## **🎯 What This Fixes:**

- ✅ **Creates database tables** - Users and items can be stored
- ✅ **Sets up security policies** - Users only see their own data
- ✅ **Enables authentication** - Sign up/sign in will work
- ✅ **Fixes JSON error** - API will return proper responses

## **🔧 Alternative: Use Local Storage (Temporary)**

If you want to test the app immediately without Supabase setup:

1. **Comment out Supabase calls** in the code
2. **Use local storage** for testing
3. **Set up Supabase later**

## **📞 Need Help?**

If you're still having issues:
1. **Check Supabase project status** - Make sure it's not paused
2. **Verify API keys** - Make sure they're correct
3. **Check browser console** - Look for more detailed error messages

**This should fix the authentication error immediately!** 🌊✨
