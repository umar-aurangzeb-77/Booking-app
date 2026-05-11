-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- 1. Create Profiles Table (extends supabase auth.users)
create table public.profiles (
  id uuid references auth.users not null primary key,
  first_name text,
  last_name text,
  role text default 'user' check (role in ('user', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create Rooms Table
create table public.rooms (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  capacity integer not null default 1,
  metadata jsonb default '{}'::jsonb, -- To store extra info like amenities (projector, whiteboard)
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Create Bookings Table
create table public.bookings (
  id uuid default uuid_generate_v4() primary key,
  room_id uuid references public.rooms on delete cascade not null,
  user_id uuid references public.profiles on delete cascade not null,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  status text default 'confirmed' check (status in ('pending', 'confirmed', 'cancelled')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  -- Prevent overlapping bookings at database level via constraints or triggers (basic check here, more complex overlapping needs triggers)
  constraint end_time_after_start_time check (end_time > start_time)
);

-- ==============================================================================
-- Row Level Security (RLS) Policies
-- ==============================================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.bookings enable row level security;

-- Profiles: Users can view their own profile and edit it
create policy "Users can view own profile" on public.profiles for select using ( auth.uid() = id );
create policy "Users can update own profile" on public.profiles for update using ( auth.uid() = id );

-- Rooms: Anyone can view active rooms. Only admins could edit (Assuming admin role logic later, for now just read-only for public/auth)
create policy "Anyone can view rooms" on public.rooms for select using ( is_active = true );

-- Bookings: Users can view all bookings (to see availability) but can only insert/update their own
create policy "Anyone can view bookings" on public.bookings for select using ( true );
create policy "Users can create bookings for themselves" on public.bookings for insert with check ( auth.uid() = user_id );
create policy "Users can update their own bookings" on public.bookings for update using ( auth.uid() = user_id );
create policy "Users can delete their own bookings" on public.bookings for delete using ( auth.uid() = user_id );

-- Create an trigger to automatically insert a profile when a new user signs up
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, first_name, last_name)
  values (new.id, new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
