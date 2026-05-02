import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../services/api_client.dart';

/// Painel “Premium” alinhado ao documento de fluxos App²cation: mostra a jornada
/// esperada por perfil (treinando, instrutor, instituição, fabricante).
/// Não substitui regras no backend — orienta o utilizador entre as várias áreas do app.
class FluxoPremiumPanel extends StatefulWidget {
  const FluxoPremiumPanel({super.key, this.dense = false});

  /// Se true, começa recolhido e ocupa menos altura (ex.: treinando).
  final bool dense;

  @override
  State<FluxoPremiumPanel> createState() => _FluxoPremiumPanelState();
}

class _FluxoPremiumPanelState extends State<FluxoPremiumPanel> {
  @override
  Widget build(BuildContext context) {
    final role = appAuth.role ?? '';
    final l = AppLocalizations.of(context);
    final spec = _fluxoSpecForRole(role, l);
    if (spec == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.04),
                const Color(0xFF0F766E).withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFC5A572).withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: !widget.dense,
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFC5A572), size: 20),
              ),
              title: Text(
                spec.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  spec.subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              children: [
                const Divider(height: 1),
                const SizedBox(height: 10),
                ...spec.steps.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _StepDot(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  if (s.roadmap)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l.fluxPanelRoadmapBadge,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                      ),
                                    ),
                                ],
                              ),
                              if (s.detail != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  s.detail!,
                                  style: TextStyle(fontSize: 12, height: 1.3, color: Colors.grey.shade600),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (role == 'institution_admin' || role == 'manufacturer_admin') ...[
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _WeeklyDigestSwitch(l: l),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyDigestSwitch extends StatefulWidget {
  const _WeeklyDigestSwitch({required this.l});

  final AppLocalizations l;

  @override
  State<_WeeklyDigestSwitch> createState() => _WeeklyDigestSwitchState();
}

class _WeeklyDigestSwitchState extends State<_WeeklyDigestSwitch> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appAuth,
      builder: (context, _) {
        final raw = appAuth.user?['weekly_dashboard_digest'];
        final on = raw is bool ? raw : true;

        final l = widget.l;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.fluxPanelWeeklyTitle,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          subtitle: Text(
            l.fluxPanelWeeklySubtitle,
            style: const TextStyle(fontSize: 12, height: 1.3, color: Color(0xFF64748B)),
          ),
          value: on,
          onChanged: _busy
              ? null
              : (enabled) async {
                  setState(() => _busy = true);
                  try {
                    await appAuth.setWeeklyDashboardDigest(enabled);
                  } on ApiException catch (e) {
                    if (context.mounted) context.showLocalizedApiExceptionSnack(e);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.fluxPanelPrefSaveFailed)),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.radio_button_checked, size: 18, color: Color(0xFF00677D));
  }
}

class _FluxoStep {
  const _FluxoStep({
    required this.label,
    this.detail,
    this.roadmap = false,
  });

  final String label;
  final String? detail;
  final bool roadmap;
}

class _FluxoSpec {
  const _FluxoSpec({
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final List<_FluxoStep> steps;
}

_FluxoSpec? _fluxoSpecForRole(String role, AppLocalizations l) {
  switch (role) {
    case 'trainee':
      return _FluxoSpec(
        title: l.fluxPanelTraineeTitle,
        subtitle: l.fluxPanelTraineeSubtitle,
        steps: [
          _FluxoStep(
            label: l.fluxPanelTraineeS1Label,
            detail: l.fluxPanelTraineeS1Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelTraineeS2Label,
            detail: l.fluxPanelTraineeS2Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelTraineeS3Label,
            detail: l.fluxPanelTraineeS3Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelTraineeS4Label,
            detail: l.fluxPanelTraineeS4Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelTraineeS5Label,
            detail: l.fluxPanelTraineeS5Detail,
            roadmap: false,
          ),
        ],
      );
    case 'instructor':
      return _FluxoSpec(
        title: l.fluxPanelInstructorTitle,
        subtitle: l.fluxPanelInstructorSubtitle,
        steps: [
          _FluxoStep(
            label: l.fluxPanelInstructorS1Label,
            detail: l.fluxPanelInstructorS1Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelInstructorS2Label,
            detail: l.fluxPanelInstructorS2Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelInstructorS3Label,
            detail: l.fluxPanelInstructorS3Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelInstructorS4Label,
            detail: l.fluxPanelInstructorS4Detail,
          ),
        ],
      );
    case 'institution_admin':
      return _FluxoSpec(
        title: l.fluxPanelInstitutionTitle,
        subtitle: l.fluxPanelInstitutionSubtitle,
        steps: [
          _FluxoStep(
            label: l.fluxPanelInstitutionS1Label,
            detail: l.fluxPanelInstitutionS1Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelInstitutionS2Label,
            detail: l.fluxPanelInstitutionS2Detail,
            roadmap: true,
          ),
          _FluxoStep(
            label: l.fluxPanelInstitutionS3Label,
            detail: l.fluxPanelInstitutionS3Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelInstitutionS4Label,
            detail: l.fluxPanelInstitutionS4Detail,
            roadmap: true,
          ),
        ],
      );
    case 'manufacturer_admin':
      return _FluxoSpec(
        title: l.fluxPanelManufacturerTitle,
        subtitle: l.fluxPanelManufacturerSubtitle,
        steps: [
          _FluxoStep(
            label: l.fluxPanelManufacturerS1Label,
            detail: l.fluxPanelManufacturerS1Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelManufacturerS2Label,
            detail: l.fluxPanelManufacturerS2Detail,
          ),
          _FluxoStep(
            label: l.fluxPanelManufacturerS3Label,
            detail: l.fluxPanelManufacturerS3Detail,
            roadmap: true,
          ),
          _FluxoStep(
            label: l.fluxPanelManufacturerS4Label,
            detail: l.fluxPanelManufacturerS4Detail,
            roadmap: true,
          ),
          _FluxoStep(
            label: l.fluxPanelManufacturerS5Label,
            detail: l.fluxPanelManufacturerS5Detail,
            roadmap: true,
          ),
        ],
      );
    default:
      return null;
  }
}
