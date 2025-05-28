import { serve } from "https://deno.land/std@0.131.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

// Your Supabase project URL and anon key (preferably use environment variables)
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    const { user, eventType } = await req.json();

    if (eventType === "USER_CREATED") {
      // Insert new user into your 'users' table with default role 'teacher' (or as needed)
      const { error } = await supabase.from('users').insert({
        id: user.id,
        email: user.email,
        role: 'teacher'  // Default role, change as needed
      });

      if (error) {
        console.error('Failed to insert user:', error);
        return new Response(JSON.stringify({ error: error.message }), { status: 500 });
      }

      return new Response(JSON.stringify({ message: 'User added successfully' }), { status: 200 });
    }

    return new Response('Event ignored', { status: 200 });
  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: 'Internal server error' }), { status: 500 });
  }
});
