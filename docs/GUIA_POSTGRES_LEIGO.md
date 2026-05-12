# Ver a base de dados do Laravel (Postgres) — guia simples

## O que é cada coisa

| Coisa | O que faz |
|--------|-----------|
| **Laravel** | Programa da API: lê e grava dados. |
| **Postgres** | Onde os dados ficam (tabelas: `users`, etc.). |
| **Railway** | Onde na internet o Postgres e a API estão a correr. |

“Mostrar a base” = abrir um **sítio onde vês tabelas e podes correr SQL**. Podes fazer isso **no browser** ou **no teu Mac**.

---

## Opção A — Só no browser (Railway, sem instalar programas)

1. Entra em [railway.app](https://railway.app) e abre **o teu projecto**.
2. Clica no **cartão do Postgres** (ex.: **Postgres-u4Od**).
3. Abre o separador **Data**, **Query** ou **Database** (o nome muda conforme a versão do painel).
4. Se existir **SQL** / **Query**, cola isto e executa:

```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

Vês a lista de tabelas que o Laravel criou (migrations).

Para ver os últimos utilizadores:

```sql
SELECT id, email, role, created_at
FROM users
ORDER BY id DESC
LIMIT 20;
```

Se **não** aparecer nenhum sítio para correr SQL: no mesmo serviço Postgres vai a **Settings** → **Networking** → activa **Public networking** / **TCP Proxy**; depois usa a **Opção B** ou **C**.

---

## Opção B — No Mac, um comando (script deste repositório)

Precisas de instalar **uma vez**:

```bash
brew install railway libpq
brew link --force libpq
```

Depois, na pasta do repositório **Appcation**:

```bash
railway login
railway link
```

O `railway link` pergunta qual projecto e qual ambiente — escolhe o mesmo onde está o Postgres.

Abre o Postgres no terminal:

```bash
./scripts/railway_psql.sh Postgres-u4Od
```

Troca **Postgres-u4Od** pelo nome **exacto** do cartão Postgres no canvas da Railway.

Dentro do `psql`:

| Teclas / comando | O que faz |
|------------------|-----------|
| `\dt` | Lista tabelas |
| `\d users` | Mostra colunas da tabela `users` |
| `\q` | Sair |

---

## Opção C — Postgres só no teu Mac (para testar, sem Railway)

Não mostra a base **de produção**; mostra uma cópia local. Útil para aprender.

```bash
cd Backend
docker compose up -d
```

Depois abre o **pgAdmin** em `http://localhost:5050` (login no `docker-compose.yml`). Passo a passo: [POSTGRES_E_UTILIZADORES.md](POSTGRES_E_UTILIZADORES.md) → secção **A**.

---

## A API tem de estar ligada ao mesmo Postgres

Se as tabelas estão vazias mas a app em produção “funciona”, a API pode estar noutra base. Configuração: [POSTGRES_E_UTILIZADORES.md](POSTGRES_E_UTILIZADORES.md) → secção **C** (`DATABASE_URL` no serviço da API).

---

## Mais ajuda no repositório

- Detalhe técnico e limpeza de utilizadores: [POSTGRES_E_UTILIZADORES.md](POSTGRES_E_UTILIZADORES.md)
- CLI Railway: [documentação oficial](https://docs.railway.com/develop/cli)
