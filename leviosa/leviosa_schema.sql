-- =========================
-- Table: profiles
-- =========================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  email text,
  bio text,
  avatar_url text
);

-- =========================
-- Table: reviews
-- =========================
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  user_name text,
  avatar_url text,
  laptop_id text,
  rating int4,
  review text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- =========================
-- Table: wishlist
-- =========================
create table if not exists public.wishlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  laptop_id text,
  created_at timestamptz default now()
);

-- =========================
-- Policies for profiles
-- =========================
-- Hanya user yang bisa select/update profilnya sendiri
create policy "User can select own profile"
on profiles
for select
using (auth.uid() = id);

create policy "User can update own profile"
on profiles
for update
using (auth.uid() = id);

-- =========================
-- Policies for reviews
-- =========================
-- Insert hanya untuk user yang sesuai user_id
create policy "Enable insert for users based on user_id"
on reviews
for insert
with check (auth.uid() = user_id);

-- Semua user bisa select (read)
create policy "Enable read access for all users"
on reviews
for select
using (true);

-- =========================
-- Policies for wishlist
-- =========================
-- Hanya user terautentikasi yang bisa insert, select, update, delete wishlist miliknya
create policy "Allow insert for authenticated users"
on wishlist
for insert
with check (auth.uid() = user_id);

create policy "Allow select for authenticated users"
on wishlist
for select
using (auth.uid() = user_id);

create policy "Allow update for authenticated users"
on wishlist
for update
using (auth.uid() = user_id);

create policy "Allow delete for authenticated users"
on wishlist
for delete
using (auth.uid() = user_id);

-- =========================
-- Policies for storage avatars
-- =========================
-- Izinkan insert ke bucket avatars untuk user terautentikasi
create policy "Allow all insert to avatars"
on storage.objects
for insert
using (
  bucket_id = 'avatars' AND auth.role() = 'authenticated'
);

-- Izinkan public download dari bucket avatars
create policy "Allow public download"
on storage.objects
for select
using (
  bucket_id = 'avatars'
); 