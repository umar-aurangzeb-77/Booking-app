# Backend Setup for Supabase

Because Supabase acts as a Backend-as-a-Service (BaaS), your backend is composed of PostgreSQL schemas, Row Level Security (RLS) policies, and Edge Functions (if needed).

## Getting Started

Since the `supabase` CLI does not appear to be installed locally along your path, the most straightforward approach right now is to execute these configuration definitions directly in your remote project.

1. Navigate to your [Supabase Dashboard](https://app.supabase.com/).
2. Select your project and navigate to the **SQL Editor** on the left menu rail.
3. Open `schema.sql` from this directory. Copy the entirety of its content. 
4. Paste the content into a new SQL query tab in the dashboard and hit **Run**. 
   - *This will automatically set up your User Profiles (linked to `auth.users`), your `rooms`, and your `bookings` structure.*
   - *It also locks down permissions using Row Level Security (RLS) so users can only ever tamper with their own bookings.*
5. Open `seed.sql`, copy the contents, paste into another new SQL query tab, and execute it. 
   - *This will populate your database with initial rooms so your Flutter frontend instantly has data to fetch.*

Once configured, your Flutter app will seamlessly interact with the backend via the `supabase_flutter` sdk instantiated in `lib/main.dart`!
