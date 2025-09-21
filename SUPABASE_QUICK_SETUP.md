# 🚀 Quick Supabase Setup for Kanso

## **✅ Your Supabase is Ready!**

Your app is now configured to use your Supabase database:
- **URL**: `https://bhouzasdujvzlwrgttmm.supabase.co`
- **Environment variables**: Loaded from `.env` file
- **No fallback**: Direct Supabase integration

## **🗄️ Run This SQL in Supabase**

1. **Go to your Supabase dashboard**: [supabase.com/dashboard](https://supabase.com/dashboard)
2. **Select your project**: `kanso-app`
3. **Go to SQL Editor** (left sidebar)
4. **Click "New Query"**
5. **Copy and paste this SQL**:

```sql
-- =============================================
-- KANSO APP DATABASE SETUP
-- =============================================

-- 1. Create users table
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

-- 2. Create declutter_items table
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

-- 3. Create indexes for better performance
CREATE INDEX idx_declutter_items_user_id ON declutter_items(user_id);
CREATE INDEX idx_declutter_items_kept ON declutter_items(user_id, is_kept);
CREATE INDEX idx_declutter_items_discarded ON declutter_items(user_id, is_discarded);
CREATE INDEX idx_declutter_items_created_at ON declutter_items(created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE declutter_items ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policies for users table
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 6. Create RLS policies for declutter_items table
CREATE POLICY "Users can view own items" ON declutter_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items" ON declutter_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items" ON declutter_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items" ON declutter_items
  FOR DELETE USING (auth.uid() = user_id);

-- 7. Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 8. Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at 
  BEFORE UPDATE ON users 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_declutter_items_updated_at 
  BEFORE UPDATE ON declutter_items 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

6. **Click "Run"** to execute the SQL
7. **Verify tables created**: Check the "Table Editor" tab

## **🔐 Enable Authentication**

1. **Go to Authentication** → **Settings**
2. **Enable Email** provider
3. **Configure email templates** (optional)
4. **Set up redirect URLs** (for web)

## **🧪 Test Your App**

1. **Open**: `http://localhost:8080`
2. **Sign up** with any email
3. **Add items** and complete a session
4. **Add memories** with photos
5. **Check Supabase dashboard** to see your data!

## **🎉 What's Working Now**

✅ **Real-time database** - Data syncs instantly  
✅ **User authentication** - Secure login/signup  
✅ **Row Level Security** - Users only see their data  
✅ **Memory persistence** - Photos and notes saved  
✅ **Cloud sync** - Data shared between devices  
✅ **Automatic backups** - Data never lost  

## **🔧 Troubleshooting**

- **Connection issues**: Check your `.env` file
- **Permission errors**: Verify RLS policies are created
- **Data not saving**: Check browser console for errors
- **Authentication fails**: Verify email provider is enabled

Your Kanso app now has **real cloud database storage**! 🌊✨

**Next step**: Run the SQL above in your Supabase dashboard, then test your app!
