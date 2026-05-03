<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Revisores de validação Fluxxo (fabricante)
    |--------------------------------------------------------------------------
    |
    | E-mails (conta já registada na app) autorizados a alterar validation_status
    | via PATCH /api/manufacturer/reviews/{manufacturer}. Lista separada por vírgulas.
    |
    | Quando um fabricante submete para validação, é enviado um e-mail (em fila;
    | configure QUEUE_CONNECTION e execute um worker em produção).
    |
    | Opcional: e-mail no registo inicial da conta fabricante (antes de submeter validação).
    |
    */
    'reviewer_emails' => array_values(array_filter(array_map(
        static fn (string $e): string => strtolower(trim($e)),
        explode(',', (string) env('MANUFACTURER_REVIEWER_EMAILS', ''))
    ))),

    'notify_reviewers_on_registration' => filter_var(
        env('MANUFACTURER_NOTIFY_ON_REGISTRATION', false),
        FILTER_VALIDATE_BOOLEAN
    ),

    /*
    |--------------------------------------------------------------------------
    | Saltar revisão humana (homologação documental)
    |--------------------------------------------------------------------------
    |
    | Quando true: após o fabricante cumprir onboarding e chamar
    | POST /api/manufacturer/request-validation, o estado passa directamente
    | a «active» em vez de «pending_validation» (útil para testes antes da
    | plataforma de revisão). Em produção mantenha false ou omita a variável.
    |
    */
    'skip_validation_review' => filter_var(
        env('MANUFACTURER_SKIP_VALIDATION_REVIEW', false),
        FILTER_VALIDATE_BOOLEAN
    ),

];
