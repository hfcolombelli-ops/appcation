<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Digesto semanal por e-mail (gestor instituição / admin fabricante)
    |--------------------------------------------------------------------------
    |
    | Comando: reports:send-weekly-dashboard-digests (agendado às segundas 07:00).
    | Desative em ambientes de teste ou se não quiser envio automático.
    |
    */
    'dashboard_digest_enabled' => env('DASHBOARD_DIGEST_ENABLED', true),

    /*
    | URL da app Web (Flutter) para o link no e-mail. Por defeito = APP_URL.
    */
    'frontend_url' => rtrim((string) env('FRONTEND_APP_URL', env('APP_URL', 'http://localhost')), '/'),

];
