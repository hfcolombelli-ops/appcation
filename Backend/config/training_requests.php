<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Motivos padronizados (pedido de treino — Fluxxo)
    |--------------------------------------------------------------------------
    */
    'reason_codes' => [
        ['id' => 'recertification', 'label' => 'Recertificação obrigatória'],
        ['id' => 'new_staff', 'label' => 'Integração de novos profissionais'],
        ['id' => 'regulatory', 'label' => 'Exigência regulamentar / auditoria'],
        ['id' => 'new_equipment', 'label' => 'Novo equipamento no serviço'],
        ['id' => 'competency_refresh', 'label' => 'Atualização de competências'],
        ['id' => 'incident_followup', 'label' => 'Seguimento pós-incidente'],
        ['id' => 'other', 'label' => 'Outro (detalhar nas notas)'],
    ],

    /*
    |--------------------------------------------------------------------------
    | Prioridade operacional
    |--------------------------------------------------------------------------
    */
    'priorities' => [
        ['id' => 'low', 'label' => 'Baixa'],
        ['id' => 'normal', 'label' => 'Normal'],
        ['id' => 'high', 'label' => 'Alta'],
        ['id' => 'urgent', 'label' => 'Urgente'],
    ],

];
