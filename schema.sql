-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- Trigger function to automatically insert profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, email)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'last_name', ''),
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- 2. Inventory Items Table
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id text PRIMARY KEY,
  name text NOT NULL,
  sku text NOT NULL,
  stock integer NOT NULL DEFAULT 0,
  threshold integer NOT NULL DEFAULT 10,
  image_url text,
  retail_price numeric,
  supplier text,
  low_stock_alert boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read for everyone" ON public.inventory_items;
CREATE POLICY "Allow read for everyone" ON public.inventory_items
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow write for authenticated users" ON public.inventory_items;
CREATE POLICY "Allow write for authenticated users" ON public.inventory_items
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 3. Sales Table
CREATE TABLE IF NOT EXISTS public.sales (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users ON DELETE CASCADE,
  customer_name text NOT NULL,
  invoice_number text NOT NULL,
  amount numeric NOT NULL,
  date_paid timestamp with time zone NOT NULL,
  status text NOT NULL,
  category text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow sales access for authenticated users" ON public.sales;
CREATE POLICY "Allow sales access for authenticated users" ON public.sales
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 4. Invoices Table
CREATE TABLE IF NOT EXISTS public.invoices (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users ON DELETE CASCADE,
  amount numeric NOT NULL,
  status text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow invoices access for authenticated users" ON public.invoices;
CREATE POLICY "Allow invoices access for authenticated users" ON public.invoices
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 5. Expenses Table
CREATE TABLE IF NOT EXISTS public.expenses (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users ON DELETE CASCADE,
  amount numeric NOT NULL,
  status text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow expenses access for authenticated users" ON public.expenses;
CREATE POLICY "Allow expenses access for authenticated users" ON public.expenses
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 6. Service Requests Table (LOGISTICS & CAC REGISTRATION)
CREATE TABLE IF NOT EXISTS public.service_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users ON DELETE CASCADE,
  service_type text NOT NULL,
  form_data jsonb NOT NULL,
  payment_status text DEFAULT 'pending_quote',
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow service_requests access for authenticated users" ON public.service_requests;
CREATE POLICY "Allow service_requests access for authenticated users" ON public.service_requests
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 7. Tasks & Reminders Table (Cloud Backup for Tasks)
CREATE TABLE IF NOT EXISTS public.tasks (
  id text PRIMARY KEY,
  user_id uuid REFERENCES auth.users ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  due_date timestamp with time zone NOT NULL,
  is_completed boolean NOT NULL DEFAULT false,
  type text NOT NULL DEFAULT 'manual',
  related_item_id text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow tasks access for authenticated users" ON public.tasks;
CREATE POLICY "Allow tasks access for authenticated users" ON public.tasks
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);


-- 8. User Settings Table (Cloud Backup for Notification Toggles & App Preferences)
CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow user_settings access for authenticated users" ON public.user_settings;
CREATE POLICY "Allow user_settings access for authenticated users" ON public.user_settings
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
