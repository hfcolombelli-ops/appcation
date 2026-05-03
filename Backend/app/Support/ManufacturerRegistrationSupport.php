<?php

namespace App\Support;

use App\Models\Manufacturer;
use Illuminate\Support\Facades\DB;

class ManufacturerRegistrationSupport
{
    /**
     * Domínio normalizado para registo (ex.: artmed.ind.br).
     */
    public static function domainFromEmail(string $email): ?string
    {
        $email = strtolower(trim($email));
        $pos = strrpos($email, '@');
        if ($pos === false) {
            return null;
        }

        $domain = substr($email, $pos + 1);

        return $domain !== '' ? $domain : null;
    }

    /**
     * Próximo protocolo FAB-YYYYMMDD-NNNN (único por dia).
     */
    public static function nextValidationProtocol(): string
    {
        return DB::transaction(function () {
            $prefix = 'FAB-'.now()->format('Ymd').'-';
            $last = Manufacturer::query()
                ->where('validation_protocol', 'like', $prefix.'%')
                ->lockForUpdate()
                ->orderByDesc('validation_protocol')
                ->value('validation_protocol');

            $n = 1;
            if (is_string($last) && preg_match('/-(\d{4})$/', $last, $m)) {
                $n = (int) $m[1] + 1;
            }

            return $prefix.str_pad((string) $n, 4, '0', STR_PAD_LEFT);
        });
    }

    /** @var list<string> */
    public const REQUIRED_DOCUMENT_KINDS = [
        'cnpj_proof',
        'articles_of_incorporation',
        'address_proof',
    ];

    /**
     * @return list<string> Chaves i18n-friendly ou nomes de campo em falta.
     */
    public static function onboardingBlockingReasons(Manufacturer $m): array
    {
        $reasons = [];

        $requiredStrings = [
            'corporate_name' => $m->name,
            'trade_name' => $m->trade_name,
            'cnpj' => $m->cnpj,
            'commercial_phone' => $m->commercial_phone,
            'support_email' => $m->support_email,
            'address_postal_code' => $m->address_postal_code,
            'address_street' => $m->address_street,
            'address_neighborhood' => $m->address_neighborhood,
            'address_city' => $m->address_city,
            'address_state' => $m->address_state,
            'legal_rep_full_name' => $m->legal_rep_full_name,
            'legal_rep_cpf' => $m->legal_rep_cpf,
            'legal_rep_role' => $m->legal_rep_role,
            'legal_rep_phone' => $m->legal_rep_phone,
        ];

        foreach ($requiredStrings as $key => $val) {
            if ($val === null || trim((string) $val) === '') {
                $reasons[] = $key;
            }
        }

        $cnpjDigits = preg_replace('/\D+/', '', (string) $m->cnpj);
        if ($cnpjDigits === null || strlen($cnpjDigits) !== 14) {
            $reasons[] = 'cnpj_invalid';
        }

        $cpfDigits = preg_replace('/\D+/', '', (string) $m->legal_rep_cpf);
        if ($cpfDigits === null || strlen($cpfDigits) !== 11) {
            $reasons[] = 'legal_rep_cpf_invalid';
        }

        $uf = strtoupper(trim((string) $m->address_state));
        if (strlen($uf) !== 2) {
            $reasons[] = 'address_state_invalid';
        }

        if ($m->declaration_accepted_at === null) {
            $reasons[] = 'declaration_required';
        }

        $presentKinds = $m->documents()
            ->whereIn('document_kind', self::REQUIRED_DOCUMENT_KINDS)
            ->pluck('document_kind')
            ->unique()
            ->all();

        foreach (self::REQUIRED_DOCUMENT_KINDS as $kind) {
            if (! in_array($kind, $presentKinds, true)) {
                $reasons[] = 'document_missing:'.$kind;
            }
        }

        return array_values(array_unique($reasons));
    }
}
