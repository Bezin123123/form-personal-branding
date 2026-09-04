-- PROJETO SUPABASE: avitrcjknuphgdgzlmen (producao). Confere o nome no topo
-- do dashboard antes de rodar — script rodado no projeto errado devolve
-- "Success" e nao aplica nada aqui.
--
-- Respostas do formulario de personal branding.
-- Aplicado em 04/09/2026. Idempotente.
--
-- NOTA: a tabela JA EXISTIA quando esta migration foi escrita (criada antes,
-- provavelmente pelo dashboard), com as duas policies abaixo. O arquivo existe
-- pra que um clone novo consiga reconstruir o banco — sem ele, so o Supabase
-- sabe o formato.

create table if not exists public.personal_branding_respostas (
  id uuid primary key default gen_random_uuid(),
  criado_em timestamptz not null default now(),
  nome text,
  o_que_faz text,
  visao_6_meses text,
  diferencial text,
  historia text,
  assunto_dominio text,
  cliente_ideal text,
  duvida_cliente text,
  cliente_indesejado text,
  referencias_positivas text,
  referencias_negativas text,
  mostra_vida_pessoal text,
  disponibilidade text,
  estrutura_gravacao text,
  o_que_travou text,
  assuntos_proibidos text,
  objetivo text,
  ja_testou text,
  redes text
);

alter table public.personal_branding_respostas enable row level security;

-- INSERT liberado pra anon: e formulario publico, o navegador de quem preenche
-- usa a chave anon, que e publica por design. O preco e spam — qualquer um com
-- a chave pode gravar direto na API, sem passar pelo formulario. Risco aceito
-- em 04/09/2026: o link vai pra poucas pessoas, o dado nao e sensivel, e lixo
-- se apaga. Se um dia incomodar, as saidas sao BotID/firewall da Vercel,
-- captcha, ou mover o insert pra uma function com checagem.
drop policy if exists "form publico insere" on public.personal_branding_respostas;
create policy "form publico insere"
  on public.personal_branding_respostas
  for insert to anon with check (true);

-- LEITURA so pra quem esta logado. Quem preenche NAO le o que os outros
-- mandaram — e a diferenca entre "formulario publico" e "dado publico".
drop policy if exists "time le" on public.personal_branding_respostas;
create policy "time le"
  on public.personal_branding_respostas
  for select to authenticated using (true);

-- Sem policy de UPDATE nem DELETE, e revogado explicitamente: resposta enviada
-- nao se altera nem some pela API. Correcao, se precisar, e no SQL Editor.
revoke update, delete on public.personal_branding_respostas from anon, authenticated;

-- Verificacao: tem que voltar rls = true e 2 policies.
select c.relrowsecurity as rls,
       (select count(*) from pg_policies p
        where p.schemaname='public' and p.tablename='personal_branding_respostas') as policies
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname='personal_branding_respostas';
