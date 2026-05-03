<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Categorias de equipamento (lista fechada — fabricante / catálogo).
    |--------------------------------------------------------------------------
    |
    | IDs em minúsculas (slug). Alinhado ao fluxo operacional hospitalar.
    |
    */
    'categories' => [
        ['id' => 'ventilacao_pulmonar', 'label' => 'Ventilação pulmonar'],
        ['id' => 'monitorizacao', 'label' => 'Monitorização'],
        ['id' => 'cme', 'label' => 'CME / Central de materiais de esterilização'],
        ['id' => 'radiologia', 'label' => 'Radiologia'],
        ['id' => 'bomba_infusao', 'label' => 'Bomba de infusão'],
        ['id' => 'desfibrilador', 'label' => 'Desfibrilador'],
        ['id' => 'uti', 'label' => 'UTI'],
        ['id' => 'emergencia', 'label' => 'Emergência'],
        ['id' => 'cardiologia', 'label' => 'Cardiologia / hemodinâmica'],
        ['id' => 'laboratorio', 'label' => 'Laboratório'],
        ['id' => 'uti_neonatal', 'label' => 'UTI neonatal'],
        ['id' => 'outro', 'label' => 'Outro'],
    ],

];
