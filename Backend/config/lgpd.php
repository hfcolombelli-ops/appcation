<?php

/**
 * Referência: DOCUMENTO DE SEGURANÇA E CONFORMIDADE LGPD (App²cation).
 * Versão do termo deve mudar quando a política for atualizada.
 */
return [

    'privacy_policy_version' => env('LGPD_PRIVACY_POLICY_VERSION', 'v1.0_20260502'),

    'dpo_email' => env('DPO_EMAIL'),

    'dpo_phone' => env('DPO_PHONE'),

    /*
    |--------------------------------------------------------------------------
    | Texto do consentimento — Treinando (Art. 7º, I LGPD)
    |--------------------------------------------------------------------------
    */
    'trainee_consent_summary' => <<<'TXT'
Finalidade: seus dados serão utilizados para identificação em treinamentos, emissão de certificados e relatórios agregados de desempenho da sua instituição.
Compartilhamento: dados individuais apenas com o instrutor durante a sessão de treinamento; à instituição, em forma agregada (não individual).
Retenção: até 5 anos após o último treinamento, para auditoria e comprovação de capacitação, salvo exclusão ou anonimização a pedido.
Direitos: você pode solicitar exclusão, correção, portabilidade e informações pelo aplicativo (Privacidade e dados).
O Google também trata dados conforme a política deles, quando usar “Entrar com Google”.
TXT,

];
