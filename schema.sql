-- LUC BRICO-TECH : base PostgreSQL / Supabase
-- À exécuter dans Supabase > SQL Editor

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'employee' check (role in ('admin','manager','employee')),
  created_at timestamptz not null default now()
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sale_date date not null default current_date,
  client text not null,
  product text not null,
  category text not null default 'Produit',
  amount numeric(14,2) not null default 0 check (amount >= 0),
  status text not null default 'Payée' check (status in ('Payée','En attente','Annulée')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  purchase_date date not null default current_date,
  supplier text not null,
  item text not null,
  category text not null default 'Autre',
  amount numeric(14,2) not null default 0 check (amount >= 0),
  status text not null default 'Payé' check (status in ('Payé','À payer','Annulé')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.innovation_projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  project text not null,
  owner text not null,
  objective text not null,
  progress integer not null default 0 check (progress between 0 and 100),
  planned_date date,
  status text not null default 'En cours' check (status in ('Planifié','En cours','Terminé','Bloqué')),
  comment text,
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  owner text not null,
  objective text not null,
  progress integer not null default 0 check (progress between 0 and 100),
  due_date date,
  priority text not null default 'Normale' check (priority in ('Normale','Haute','Urgente')),
  status text not null default 'En cours' check (status in ('Planifiée','En cours','Terminée','En retard','Bloquée')),
  comment text,
  created_at timestamptz not null default now()
);

create table if not exists public.settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  company_name text not null default 'Luc Brico-Tech',
  monthly_sales_target numeric(14,2) not null default 0,
  currency text not null default 'FCFA',
  updated_at timestamptz not null default now()
);

-- Active Row Level Security.
alter table public.profiles enable row level security;
alter table public.sales enable row level security;
alter table public.purchases enable row level security;
alter table public.innovation_projects enable row level security;
alter table public.activities enable row level security;
alter table public.settings enable row level security;

-- Users can only access their own business data.
create policy "profiles own" on public.profiles
for all using (id = auth.uid()) with check (id = auth.uid());

create policy "sales own" on public.sales
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "purchases own" on public.purchases
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "innovation own" on public.innovation_projects
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "activities own" on public.activities
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "settings own" on public.settings
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Automatic profile/settings creation after registration.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles(id, full_name) values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''));
  insert into public.settings(user_id) values (new.id);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Useful dashboard views.
create or replace view public.dashboard_monthly_sales as
select date_trunc('month', sale_date)::date as month, sum(amount) as total
from public.sales
where status <> 'Annulée'
group by 1
order by 1;

create or replace view public.dashboard_monthly_purchases as
select date_trunc('month', purchase_date)::date as month, sum(amount) as total
from public.purchases
where status <> 'Annulé'
group by 1
order by 1;
