# Convites fabricante-first — requisitos fechados (MVP)

## Objectivo

O **fabricante** (`manufacturer_admin`) provisiona **instituições** e envia **convites** por e-mail para **gestor de instituição** (`institution_admin`) e **instrutor / applicator** (`instructor`), com aceitação por link seguro (definição de palavra-passe). O treinando por link/QR fica na [fase 2](trainee-link-qr-phase2.md).

## Estados do convite

| Estado        | Condição                                      | Acções permitidas                          |
|---------------|-----------------------------------------------|--------------------------------------------|
| `pending`     | `accepted_at` e `revoked_at` nulos, não expirado | Revogar (fabricante); aceitar (público)   |
| `accepted`    | `accepted_at` preenchido                    | Nenhuma (imutável)                         |
| `revoked`     | `revoked_at` preenchido                       | Nenhuma                                    |
| `expirado`    | `expires_at` &lt; agora e ainda `pending`     | Tratado como inválido na API (como revogado) |

## Campos do convite

- **E-mail** do convidado (normalizado minúsculas), obrigatório.
- **Nome** opcional (pré-preenche o registo na aceitação).
- **CPF** opcional no convite: usado para confirmação na aceitação e gravado no `users.cpf` após aceite (ver LGPD).
- **Papel**: `institution_admin` ou `instructor`.
- **Instituição**: obrigatória para `institution_admin`; obrigatória para `instructor` neste MVP (vínculo duplo fabricante + instituição).
- **Token**: opaco, enviado só por e-mail; na BD guarda-se **hash** (SHA-256).

## Conflito de e-mail

- **Criação do convite**: se já existir `users.email` igual ao do convite → **422** com mensagem a indicar que a conta já existe (deve iniciar sessão; suporte pode vincular manualmente se for política futura).
- **Aceitação**: se entre o envio e o aceite alguém registar o mesmo e-mail → **409** na aceitação.

## LGPD — CPF

- Finalidade: identificação do representante/gestor ou instrutor conforme processo clínico do cliente.
- O CPF é opcional no convite; na aceitação, se o convite tiver CPF, o utilizador deve **confirmar o mesmo CPF** (dígitos normalizados) para concluir.
- Retenção: segue a política geral de dados da conta; exportação/apagamento via fluxos LGPD já previstos na API.

## Quem pode revogar

- Apenas utilizadores `manufacturer_admin` do **mesmo** `manufacturer_id` que criou o convite.

## E-mail transaccional

- Envio assíncrono (fila Laravel quando configurada); em desenvolvimento pode usar `log`.
- Link base: `{APP_URL}/#/invite?token=` + token (Flutter Web) ou documentação da API `GET /api/public/invitations/{token}` para metadados e formulário noutra página.

## Coexistência com fluxo actual

- Registo Google / `PATCH /me/role` mantêm-se para contas que não entram por convite.
- `POST /institutions` genérico mantém-se; o fabricante usa `POST /api/manufacturer/institutions` para gravar `manufacturer_id`.
