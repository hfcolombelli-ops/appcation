import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../theme/clinical_precision_tokens.dart';
import '../widgets/version_badge.dart';

/// Quando `role` da API não mapeia para um shell — triagem em 2 passos (tipo de perfil → dados).
class ProfileGateScreen extends StatefulWidget {
  const ProfileGateScreen({super.key});

  @override
  State<ProfileGateScreen> createState() => _ProfileGateScreenState();
}

enum _TriageStep { pickRole, details }

class _ProfileGateScreenState extends State<ProfileGateScreen> {
  bool _refreshing = false;
  bool _claiming = false;
  _TriageStep _step = _TriageStep.pickRole;
  String? _selectedRole;
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
    final role = _selectedRole;
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

  void _goToPickRole() {
    setState(() {
      _step = _TriageStep.pickRole;
      _selectedRole = null;
    });
  }

  Widget _accountCard(AppLocalizations l, String? name, String? email, String roleLabel) {
    return Container(
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: ClinicalPrecisionColors.secondary,
            ),
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
    );
  }

  Widget _rolePickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String roleId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: ClinicalPrecisionColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: (_claiming || _refreshing)
              ? null
              : () {
                  setState(() {
                    _selectedRole = roleId;
                    _step = _TriageStep.details;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: ClinicalPrecisionColors.secondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: ClinicalPrecisionColors.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickRole(AppLocalizations l, String? name, String? email, String roleLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.hub_outlined, size: 44, color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.9)),
        const SizedBox(height: 16),
        Text(
          l.profileTriageTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: ClinicalPrecisionColors.onSurface,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          l.profileTriageSubtitle,
          style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.45, fontSize: 15),
        ),
        if (name != null || email != null) ...[
          const SizedBox(height: 18),
          _accountCard(l, name, email, roleLabel),
        ],
        const SizedBox(height: 22),
        _rolePickCard(
          icon: Icons.school_outlined,
          title: l.googleRoleTrainee,
          subtitle: l.profileTriageTraineeBody,
          roleId: 'trainee',
        ),
        _rolePickCard(
          icon: Icons.verified_user_outlined,
          title: l.googleRoleInstructor,
          subtitle: l.profileTriageInstructorBody,
          roleId: 'instructor',
        ),
        _rolePickCard(
          icon: Icons.precision_manufacturing_outlined,
          title: l.googleRoleManufacturerAdmin,
          subtitle: l.profileTriageManufacturerBody,
          roleId: 'manufacturer_admin',
        ),
        const SizedBox(height: 8),
        Text(
          l.profileGateClaimHint,
          style: TextStyle(fontSize: 12, height: 1.35, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.9)),
        ),
        const SizedBox(height: 16),
        Text(
          l.profileGateDocHint,
          style: TextStyle(fontSize: 12, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.85), height: 1.35),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _refreshing ? null : _refreshSession,
          icon: _refreshing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.sync_rounded, size: 20),
          label: Text(l.profileGateRefreshSession),
        ),
        const SizedBox(height: 10),
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
    );
  }

  String _roleTitle(AppLocalizations l, String? role) {
    return switch (role) {
      'instructor' => l.googleRoleInstructor,
      'manufacturer_admin' => l.googleRoleManufacturerAdmin,
      _ => l.googleRoleTrainee,
    };
  }

  String _roleBody(AppLocalizations l, String? role) {
    return switch (role) {
      'instructor' => l.profileTriageInstructorBody,
      'manufacturer_admin' => l.profileTriageManufacturerBody,
      _ => l.profileTriageTraineeBody,
    };
  }

  Widget _buildDetails(AppLocalizations l) {
    final role = _selectedRole;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: (_claiming || _refreshing) ? null : _goToPickRole,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: Text(l.profileTriageBack),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.profileTriageStep2Title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: ClinicalPrecisionColors.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          _roleTitle(l, role),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ClinicalPrecisionColors.secondary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _roleBody(l, role),
          style: const TextStyle(fontSize: 14, height: 1.45, color: ClinicalPrecisionColors.onSurfaceVariant),
        ),
        if (role == 'manufacturer_admin') ...[
          const SizedBox(height: 18),
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
        const SizedBox(height: 22),
        FilledButton(
          onPressed: (_claiming || _refreshing) ? null : () => _submitClaim(l),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _claiming
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.profileGateConfirmProfile),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _refreshing ? null : _refreshSession,
          icon: _refreshing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.sync_rounded, size: 20),
          label: Text(l.profileGateRefreshSession),
        ),
        const SizedBox(height: 10),
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
    );
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _step == _TriageStep.pickRole
                            ? _buildPickRole(l, name, email, roleLabel)
                            : _buildDetails(l),
                      ),
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
