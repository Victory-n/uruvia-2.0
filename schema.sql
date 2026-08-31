-- 1. Profiles Table (Base user record created upon registration)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone_number TEXT,
  profile_image TEXT,
  region TEXT CHECK (region IN ('Africa', 'Europe', 'Asia', 'America', 'Australia')),
  currency TEXT CHECK (currency IN ('NGN', 'USD', 'AUD', 'GBP', 'EUR', 'CAD', 'GHS', 'KES')),
  account_type TEXT CHECK (account_type IN ('individual', 'business')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- 2. Business Accounts Table (Created if account_type = 'business')
CREATE TABLE IF NOT EXISTS public.business_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  business_email TEXT,
  business_phone_number TEXT,
  business_image TEXT,
  certificate_of_registration TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'banned')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.business_accounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Owners can view own business accounts" ON public.business_accounts;
CREATE POLICY "Owners can view own business accounts" ON public.business_accounts
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = owner_id);

DROP POLICY IF EXISTS "Owners can update own business accounts" ON public.business_accounts;
CREATE POLICY "Owners can update own business accounts" ON public.business_accounts
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = owner_id)
  WITH CHECK ((select auth.uid()) = owner_id);

DROP POLICY IF EXISTS "Owners can insert business account" ON public.business_accounts;
CREATE POLICY "Owners can insert business account" ON public.business_accounts
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = owner_id);

-- Foreign Key Index for performance
CREATE INDEX IF NOT EXISTS idx_business_accounts_owner_id ON public.business_accounts(owner_id);

-- Universal trigger function for updating updated_at timestamp automatically
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_business_accounts_updated_at ON public.business_accounts;
CREATE TRIGGER set_business_accounts_updated_at
  BEFORE UPDATE ON public.business_accounts
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger function to automatically insert profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    firstname,
    lastname,
    email,
    phone_number,
    profile_image,
    region,
    currency,
    account_type
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'firstname', new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'lastname', new.raw_user_meta_data->>'last_name', ''),
    new.email,
    new.raw_user_meta_data->>'phone_number',
    new.raw_user_meta_data->>'profile_image',
    COALESCE(new.raw_user_meta_data->>'region', 'Africa'),
    COALESCE(new.raw_user_meta_data->>'currency', 'NGN'),
    COALESCE(new.raw_user_meta_data->>'account_type', 'individual')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
