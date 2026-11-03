-- Rode no Supabase: SQL Editor > New query > Run

create table if not exists public.contribuicoes (
  id uuid primary key default gen_random_uuid(),
  nome text not null check (char_length(nome) between 3 and 120),
  valor numeric(10,2) not null check (valor > 0),
  whatsapp text check (whatsapp is null or char_length(whatsapp) between 8 and 15),
  mensagem text check (mensagem is null or char_length(mensagem) <= 500),
  confirmado boolean not null default false,   -- noivos conferiram o PIX
  agradecido boolean not null default false,   -- noivos já agradeceram
  agradecido_em timestamptz,
  created_at timestamptz not null default now()
);

alter table public.contribuicoes enable row level security;

-- Convidados (anônimos): só podem INSERIR. Não existe policy de leitura para eles,
-- então ninguém vê as contribuições dos outros.
drop policy if exists "convidados inserem" on public.contribuicoes;
create policy "convidados inserem" on public.contribuicoes
  for insert to anon
  with check (confirmado = false and agradecido = false);

-- Noivos (usuários autenticados): ler e atualizar.
drop policy if exists "noivos leem" on public.contribuicoes;
create policy "noivos leem" on public.contribuicoes
  for select to authenticated using (true);

drop policy if exists "noivos atualizam" on public.contribuicoes;
create policy "noivos atualizam" on public.contribuicoes
  for update to authenticated using (true) with check (true);
