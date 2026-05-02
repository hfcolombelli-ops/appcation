<?php

return [

    /*
    | Janelas padrão (dias após conclusão) quando o treino não define metadata.follow_up.days.
    | Com lista vazia, só há reavaliações se o treino tiver days explícitos em metadata.
    */
    'default_days' => array_values(array_filter(array_map(
        static fn (string $v): int => (int) trim($v),
        explode(',', (string) env('FOLLOW_UP_DEFAULT_DAYS', ''))
    ), static fn (int $v): bool => $v > 0)),

    /*
    | Perguntas do mini questionário (podem ser substituídas por treino em metadata.follow_up.questions).
    */
    'default_questions' => [
        [
            'key' => 'confidence',
            'prompt' => 'Quão confiante se sente em aplicar o que aprendeu? (1 = pouco, 5 = muito)',
            'type' => 'likert_5',
        ],
        [
            'key' => 'applied',
            'prompt' => 'Já utilizou o procedimento em contexto real desde o treino?',
            'type' => 'choice',
            'options' => [
                ['value' => 'yes', 'label' => 'Sim'],
                ['value' => 'no', 'label' => 'Ainda não'],
                ['value' => 'na', 'label' => 'Não aplicável'],
            ],
        ],
        [
            'key' => 'comment',
            'prompt' => 'Comentários ou dificuldades (opcional)',
            'type' => 'text',
            'optional' => true,
        ],
    ],

];
