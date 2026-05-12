# PostgreSQL e gestão de utilizadores (App²cation)

> **Primeira vez / passo a passo simples:** [GUIA_POSTGRES_LEIGO.md](GUIA_POSTGRES_LEIGO.md) (browser, terminal com `./scripts/railway_psql.sh`, ou Docker local).

## 1. Limpar **todos** os utilizadores (`users`)

O backend já inclui o comando Artisan `app:purge-all-users`, que remove linhas em `users`, tokens Sanctum ligados a utilizadores, `sessions` e `password_reset_tokens`. Tabelas com `ON DELETE CASCADE` para `users` (ex.: `enrollments`, `trainee_profiles`) são limpas pela base.

### Produção (Railway)

1. No serviço **API (Laravel)**, em **Variables**, define temporariamente:
   - `ALLOW_PURGE_ALL_USERS=true`
2. No terminal (com [Railway CLI](https://docs.railway.com/develop/cli) ligado ao projecto e ao serviço da API), ou no separador **Shell** do serviço:

   ```bash
   php artisan app:purge-all-users --force
   ```

3. Remove ou volta a `false` a variável `ALLOW_PURGE_ALL_USERS` — **não** deixes `true` em produção por defeito.

Sem `ALLOW_PURGE_ALL_USERS=true` em `APP_ENV=production`, o comando recusa-se a correr (protecção contra apagamento acidental).

### Local (SQLite ou Postgres em Docker)

```bash
cd Backend
php artisan app:purge-all-users --force
```

Em `APP_ENV=local`, não é obrigatório `ALLOW_PURGE_ALL_USERS`.

### Nota sobre fabricantes e dados

O purge remove **só utilizadores**. Registos em `manufacturers`, `institutions`, `trainings` (sem instrutor válido), etc., podem ficar órfãos ou inconsistentes para um MVP “zerado”. Se precisares de **base totalmente limpa**, usa `php artisan migrate:fresh` **apenas** em ambiente descartável (nunca em produção sem backup).

---

## 2. Acesso fácil ao PostgreSQL

### A) Local — **pgAdmin** no Docker (recomendado)

Com o Postgres do repositório a correr:

```bash
cd Backend
docker compose up -d
```

- **Postgres:** `localhost:5432`  
  - Utilizador: `appcation`  
  - Palavra-passe: `appcation`  
  - Base de dados: `appcation`
- **pgAdmin Web:** http://localhost:5050  
  - E-mail de login e palavra-passe: vê `Backend/docker-compose.yml` (variáveis `PGADMIN_DEFAULT_*`).

No pgAdmin: **Register → Server** → separador **Connection**:

| Campo    | Valor (Docker na mesma rede) |
|----------|------------------------------|
| Host     | `postgres`                   |
| Port     | `5432`                       |
| Database | `appcation`                  |
| Username | `appcation`                  |
| Password | `appcation`                  |

> Em máquina **host** (TablePlus/psql no macOS sem Docker network), usa **Host** `127.0.0.1` em vez de `postgres`.

### B) Railway — Postgres gerido

1. Abre o serviço **PostgreSQL** no canvas.
2. Usa o separador **Data** / **Query** (interface web) para SQL rápido.
3. Para **cliente externo** (TablePlus, DBeaver, `psql`):
   - Em **Settings → Networking**, activa **Public URL** / **TCP Proxy** se o plano o permitir.
   - Copia a **connection string** (formato `postgresql://...`) do painel e cola no cliente.

Exemplo com `psql` (substitui a URL pela tua):

```bash
psql "postgresql://usuario:password@host:port/railway"
```

### C) `DATABASE_URL` / `DB_URL` na API (ligar ao Postgres no canvas)

A API Laravel usa `DB_URL`. No contentor da Railway, o [`Backend/docker-entrypoint.sh`](../Backend/docker-entrypoint.sh) copia **`DATABASE_URL` → `DB_URL`** quando `DB_URL` está vazio e força `DB_CONNECTION=pgsql` se a URL for `postgres://` ou `postgresql://`.

**Ligar a API ao serviço PostgreSQL chamado `Postgres-u4Od` (ou outro nome no canvas):**

1. No mesmo **projecto** e **ambiente** (ex.: production), confirma que o cartão da base se chama exactamente **Postgres-u4Od** (Railway mostra o nome no topo do serviço).
2. Abre o serviço **da API** (Laravel / Docker), separador **Variables**.
3. Adiciona (ou edita) uma variável:
   - **Nome:** `DATABASE_URL`
   - **Valor:** referência ao Postgres — sintaxe Railway: `${{ NomeDoServicoPostgres.DATABASE_URL }}`  
     Para o teu caso: **`${{ Postgres-u4Od.DATABASE_URL }}`**  
     O painel Railway tem **Variable Reference** / autocomplete: escolhe o serviço **Postgres-u4Od** e a variável **`DATABASE_URL`** (evita erros de capitalização ou hífens).
4. Se existir **`DB_URL`** antigo (cadeia colada à mão) a apontar para outro sitio, **remove** ou corrige; o entrypoint **não** sobrescreve `DB_URL` se já estiver definido.
5. Opcional: define **`DB_CONNECTION=pgsql`** na API (o entrypoint já deduz a partir da URL).
6. **Deploy** o serviço da API (ou *Deploy* das alterações em variáveis). O `preDeployCommand` em [`Backend/railway.toml`](../Backend/railway.toml) corre `php artisan migrate --force` antes de aceitar tráfego.

**Nota:** O Flutter / Firebase **não** precisa desta URL; só o backend Laravel.

---

## 3. Consultas úteis (SQL)

```sql
-- Listar utilizadores
SELECT id, email, role, manufacturer_id, created_at FROM users ORDER BY id;

-- Contagem
SELECT role, COUNT(*) FROM users GROUP BY role;
```

**Apagar um utilizador pontual** (cuidado com FKs — preferir a app ou cascata já definida):

```sql
DELETE FROM users WHERE email = 'exemplo@dominio.com';
```

Para wipe completo, preferir sempre `php artisan app:purge-all-users --force` (com as variáveis de produção correctas).
