<?php

$rawCors = trim((string) env('CORS_ALLOWED_ORIGINS', ''));
$parsedOrigins = array_values(array_filter(
    array_map('trim', explode(',', $rawCors)),
    fn (string $o) => $o !== ''
));

// Em produção, evita cair em '*' se a variável não chegar ao PHP (Railway / cache).
if ($parsedOrigins === [] || $parsedOrigins === ['*']) {
    $parsedOrigins = env('APP_ENV') === 'local'
        ? ['*']
        : [
            'https://appcation.web.app',
            'https://appcation.firebaseapp.com',
        ];
}

return [

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => $parsedOrigins,

    'allowed_origins_patterns' => [
        '#^https?://localhost(:\d+)?$#',
        '#^https?://127\.0\.0\.1(:\d+)?$#',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => (bool) env('CORS_SUPPORTS_CREDENTIALS', false),

];
