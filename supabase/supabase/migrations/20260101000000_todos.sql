create table public.todos (
  id bigint generated always as identity primary key,
  title text not null,
  done boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.todos enable row level security;
create policy "anyone can read todos" on public.todos for select using (true);
