-- M2: only authenticated adults can read or write their own profile.
-- Apply with the Supabase CLI to a project configured for Fuori.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table public.adult_declarations (
  user_id uuid primary key references auth.users (id) on delete cascade,
  confirmed_adult boolean not null check (confirmed_adult),
  statement_version text not null default '18plus-v1'
    check (statement_version = '18plus-v1'),
  declared_at timestamptz not null default now()
);

alter table public.adult_declarations enable row level security;
revoke all on public.adult_declarations from anon, authenticated;
grant select on public.adult_declarations to authenticated;
grant insert (user_id, confirmed_adult)
  on public.adult_declarations to authenticated;

create policy "Read own adult declaration"
  on public.adult_declarations for select to authenticated
  using (user_id = (select auth.uid()));

create policy "Record own adult declaration once"
  on public.adult_declarations for insert to authenticated
  with check (
    user_id = (select auth.uid()) and confirmed_adult = true
  );

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null
    check (char_length(trim(display_name)) between 2 and 30),
  avatar_preferences jsonb not null default '{}'::jsonb
    check (jsonb_typeof(avatar_preferences) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant insert (id, display_name) on public.profiles to authenticated;
grant update (display_name, avatar_preferences)
  on public.profiles to authenticated;

create policy "Read own profile after adult declaration"
  on public.profiles for select to authenticated
  using (
    id = (select auth.uid()) and exists (
      select 1 from public.adult_declarations as declaration
      where declaration.user_id = (select auth.uid())
    )
  );

create policy "Create own profile after adult declaration"
  on public.profiles for insert to authenticated
  with check (
    id = (select auth.uid()) and exists (
      select 1 from public.adult_declarations as declaration
      where declaration.user_id = (select auth.uid())
    )
  );

create policy "Update own profile after adult declaration"
  on public.profiles for update to authenticated
  using (
    id = (select auth.uid()) and exists (
      select 1 from public.adult_declarations as declaration
      where declaration.user_id = (select auth.uid())
    )
  )
  with check (
    id = (select auth.uid()) and exists (
      select 1 from public.adult_declarations as declaration
      where declaration.user_id = (select auth.uid())
    )
  );

create function private.touch_profile_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.touch_profile_updated_at()
  from public, anon, authenticated;

create trigger touch_profile_updated_at
  before update on public.profiles
  for each row execute function private.touch_profile_updated_at();

create table public.user_roles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'user' check (role in ('user', 'admin')),
  assigned_at timestamptz not null default now()
);

alter table public.user_roles enable row level security;
revoke all on public.user_roles from anon, authenticated;

create function private.assign_default_user_role()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_roles (user_id, role) values (new.id, 'user');
  return new;
end;
$$;

revoke all on function private.assign_default_user_role()
  from public, anon, authenticated;

create trigger assign_default_user_role
  after insert on auth.users
  for each row execute function private.assign_default_user_role();

insert into public.user_roles (user_id, role)
select id, 'user' from auth.users
on conflict (user_id) do nothing;
