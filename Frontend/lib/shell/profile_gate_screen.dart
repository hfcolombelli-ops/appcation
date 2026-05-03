import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../theme/clinical_precision_tokens.dart';
import '../widgets/version_badge.dart';

/// Quando `role` da API não mapeia para um shell (evita mostrar o login com sessão ainda válida).
/// Alinhado ao nó «Sem Perfil» / falha de identificação do fluxograma em `docs/product/fluxo_app2cation.mermaid`.
class ProfileGateScreen extends StatefulWidget {
  const ProfileGateScreen({super.key});

  @override
  State<ProfileGateScreen> createState() => _ProfileGateScreenState();
}

class _ProfileGateScreenState extends State<ProfileGateScreen> {
  bool _refreshing = false;
  bool _claiming = false;
  String? _claimRole;
  final TextEditingController _mfgName = TextEditingController();
  final TextEditingController _mfgCnpj = TextEditingController();

  @override
  void dispose() {
    _mfgName.dispose();
    _mfgCnpj.dispose();
    super.dispose();
  }

  Future<void> _refreshSession() async {
    setState(() => _refreshing = true);
    try {
      await appAuth.restore();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _submitClaim(AppLocalizations l) async {
    final role = _claimRole;
    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.profileGatePickRoleFirst)));
      return;
    }
    if (role == 'manufacturer_admin' && _mfgName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.valCompanyNameRequired)));
      return;
    }
    setState(() => _claiming = true);
    try {
      await appAuth.claimInitialRole(
        role,
        manufacturerName: role == 'manufacturer_admin' ? _mfgName.text : null,
        manufacturerCnpj: role == 'manufacturer_admin' ? _mfgCnpj.text : null,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = e.message.trim().isNotEmpty ? e.message : l.errApiConnection;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errApiConnection)));
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final u = appAuth.user;
    final name = u?['name']?.toString().trim();
    final email = u?['email']?.toString().trim();
    final roleRaw = appAuth.role?.trim();
    final roleLabel = roleRaw != null && roleRaw.isNotEmpty ? roleRaw : '—';

    return Scaffold(
      backgroundColor: ClinicalPrecisionColors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: RefreshIndicator(
                  onRefresh: _refreshSession,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.manage_accounts_outlined, size: 48, color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.85)),
                      const SizedBox(height: 18),
                      Text(
                        l.profileGateTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ClinicalPrecisionColors.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.profileGateBody,
                        style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.45, fontSize: 15),
                      ),
                      if (u != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ClinicalPrecisionColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.profileGateYourAccount,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: ClinicalPrecisionColors.secondary),
                              ),
                              if (name != null && name.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ClinicalPrecisionColors.onSurface)),
                              ],
                              if (email != null && email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(email, style: const TextStyle(fontSize: 14, color: ClinicalPrecisionColors.onSurfaceVariant)),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                l.profileGateRoleFromApi(roleLabel),
                                style: const TextStyle(fontSize: 13, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l.profileGateClaimSectionTitle,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: ClinicalPrecisionColors.secondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.profileGateClaimIntro,
                          style: const TextStyle(fontSize: 13, height: 1.4, color: ClinicalPrecisionColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.profileGateClaimHint,
                          style: TextStyle(fontSize: 12, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(height: 14),
                        Text(l.profileGateChooseRole, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ClinicalPrecisionColors.onSurface)),
                        const SizedBox(height: 4),
                        RadioGroup<String>(
                          groupValue: _claimRole,
                          onChanged: (v) {
                            if (_claiming || _refreshing) return;
                            setState(() => _claimRole = v);
                          },
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                value: 'trainee',
                                title: Text(l.googleRoleTrainee),
                              ),
                              RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                value: 'instructor',
                                title: Text(l.googleRoleInstructor),
                              ),
                              RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                value: 'manufacturer_admin',
                                title: Text(l.googleRoleManufacturerAdmin),
                              ),
                            ],
                          ),
                        ),
                        if (_claimRole == 'manufacturer_admin') ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _mfgName,
                            enabled: !_claiming && !_refreshing,
                            decoration: InputDecoration(
                              labelText: l.fieldCompanyName,
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _mfgCnpj,
                            enabled: !_claiming && !_refreshing,
                            decoration: InputDecoration(
                              labelText: l.mfgCnpjOptionalLabel,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.registerMfgCompanyOptionalDomain,
                            style: TextStyle(fontSize: 12, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.88)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: (_claiming || _refreshing || _claimRole == null)
                              ? null
                              : () => _submitClaim(l),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _claiming
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l.profileGateConfirmProfile),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        l.profileGateDocHint,
                        style: TextStyle(fontSize: 12, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.85), height: 1.35),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.profileGateRefreshHint,
                        style: const TextStyle(fontSize: 12.5, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _refreshing ? null : _refreshSession,
                        icon: _refreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, size: 20),
                        label: Text(l.profileGateRefreshSession),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => appAuth.logout(),
                        style: FilledButton.styleFrom(
                          backgroundColor: ClinicalPrecisionColors.secondary,
                          foregroundColor: ClinicalPrecisionColors.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l.actionSignOut),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
          const Positioned(left: 16, bottom: 16, child: VersionBadge()),
        ],
      ),
    );
  }
}
