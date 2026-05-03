import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../l10n/status_labels.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../util/download_bytes.dart';
import '../services/training_reverb_listener.dart';
import '../theme/clinical_precision_tokens.dart';
import '../theme/instructor_page_chrome.dart';
import '../widgets/fluxo_premium_panel.dart';
import '../widgets/version_badge.dart';
import 'fluxxo_manufacturer_review_page.dart';

class _InstructorApiReachability extends InheritedWidget {
  const _InstructorApiReachability({required this.apiOnline, required super.child});

  final bool apiOnline;

  static bool apiOnlineOf(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_InstructorApiReachability>();
    return w?.apiOnline ?? true;
  }

  @override
  bool updateShouldNotify(covariant _InstructorApiReachability oldWidget) => oldWidget.apiOnline != apiOnline;
}

Widget _instrOfflineBanner(AppLocalizations l) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFB91C1C), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.instrOfflineHint,
              style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF7F1D1D)),
            ),
          ),
        ],
      ),
    ),
  );
}

bool _gestorNeedsInstitutionLink() {
  if (appAuth.role != 'institution_admin') {
    return false;
  }
  final v = appAuth.user?['institution_id'];
  if (v == null) {
    return true;
  }
  final n = v is int ? v : int.tryParse(v.toString());
  return n == null || n < 1;
}

/// Shell instrutor: menu lateral + cabeçalho fixos; só o miúdo troca.
class InstructorShell extends StatefulWidget {
  const InstructorShell({super.key});

  @override
  State<InstructorShell> createState() => _InstructorShellState();
}

class _InstructorShellState extends State<InstructorShell> {
  final _navKey = GlobalKey<NavigatorState>();
  String _route = '/instructor/dashboard';

  final _api = ProductionApi(ApiClient());

  static const _bg = Color(0xFFF7F9FB);

  Timer? _healthTimer;
  bool _apiOnline = true;

  @override
  void initState() {
    super.initState();
    _healthTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        await _api.health();
        if (mounted) setState(() => _apiOnline = true);
      } catch (_) {
        if (mounted) setState(() => _apiOnline = false);
      }
    });
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  void _go(String route) {
    setState(() => _route = route);
    _navKey.currentState?.pushReplacementNamed(route);
  }

  /// Navegação interna (ex.: CTA no dashboard gestor) mantendo o item correcto no menu lateral.
  void navigateInShell(String route) => _go(route);

  String _title(BuildContext context, String route) {
    final l = AppLocalizations.of(context);
    switch (route) {
      case '/instructor/comando':
        return l.shellTitleCommandRoom;
      case '/instructor/treinamento':
        return l.shellTitleNewTraining;
      case '/instructor/credenciamento':
        return l.shellTitleCredentialing;
      case '/institution/pedidos':
        return l.shellTitleTrainingRequests;
      case '/institution/parque':
        return l.shellTitleTechPark;
      case '/institution/endorsements':
        return l.shellTitleEndorsements;
      case '/instructor/revisao-fluxxo':
        return l.shellTitleFluxxoReview;
      case '/instructor/resultados':
        return l.shellTitlePostTrainingResults;
      default:
        return l.shellTitleOverview;
    }
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/instructor/comando':
        page = _ComandoPage(api: _api);
        break;
      case '/instructor/resultados':
        page = _PostTrainingResultsPage(api: _api);
        break;
      case '/instructor/treinamento':
        page = _TreinamentoPage(api: _api);
        break;
      case '/instructor/credenciamento':
        page = _CredenciamentoPage(api: _api);
        break;
      case '/institution/pedidos':
        page = _InstitutionPedidosPage(api: _api);
        break;
      case '/institution/parque':
        page = _InstitutionParquePage(api: _api);
        break;
      case '/institution/endorsements':
        page = _InstitutionEndorsementsPage(api: _api);
        break;
      case '/instructor/revisao-fluxxo':
        page = FluxxoManufacturerReviewPage(api: _api);
        break;
      case '/instructor/dashboard':
      default:
        page = _DashboardPage(api: _api);
    }
    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appAuth,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_gestorNeedsInstitutionLink()) _GestorInstitutionBanner(api: _api),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Sidebar(currentRoute: _route, onNavigate: _go),
                        Expanded(
                          child: Column(
                            children: [
                              _TopBar(title: _title(context, _route), apiOnline: _apiOnline),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                                child: FluxoPremiumPanel(dense: true),
                              ),
                              Expanded(
                                child: _InstructorApiReachability(
                                  apiOnline: _apiOnline,
                                  child: Navigator(
                                    key: _navKey,
                                    initialRoute: '/instructor/dashboard',
                                    onGenerateRoute: _onGenerateRoute,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Positioned(left: 16, bottom: 16, child: VersionBadge()),
            ],
          ),
        );
      },
    );
  }
}

class _GestorInstitutionBanner extends StatefulWidget {
  const _GestorInstitutionBanner({required this.api});

  final ProductionApi api;

  @override
  State<_GestorInstitutionBanner> createState() => _GestorInstitutionBannerState();
}

class _GestorInstitutionBannerState extends State<_GestorInstitutionBanner> {
  List<Map<String, dynamic>> _list = [];
  int? _pickedId;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.institutions(t);
      if (mounted) {
        setState(() {
          _list = list;
          _pickedId ??= list.isNotEmpty ? _parseInt(list.first['id']) : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final id = _pickedId;
    if (id == null) {
      setState(() => _error = AppLocalizations.of(context).shellPickInstitution);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await appAuth.linkInstitution(id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Material(
      color: const Color(0xFFFFF7ED),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Color(0xFFC2410C)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.shellLinkInstitutionTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF9A3412)),
                  ),
                  Text(
                    s.shellLinkInstitutionBody,
                    style: TextStyle(fontSize: 12.5, color: Colors.brown.shade800),
                  ),
                  if (_list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(s.shellLinkInstitutionEmpty),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: s.fieldInstitution, isDense: true),
                        initialValue: _pickedId,
                        items: [
                          for (final i in _list)
                            DropdownMenuItem(value: _parseInt(i['id']), child: Text(i['name']?.toString() ?? '')),
                        ],
                        onChanged: (v) => setState(() => _pickedId = v),
                      ),
                    ),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _loading || _list.isEmpty ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA580C)),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(s.shellSaveLink),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentRoute, required this.onNavigate});

  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <(String label, String route, IconData icon)>[
      (l.shellNavDashboard, '/instructor/dashboard', Icons.dashboard_rounded),
      (l.shellNavCommandRoom, '/instructor/comando', Icons.monitor_heart_rounded),
      (l.shellNavTrainings, '/instructor/treinamento', Icons.add_box_rounded),
      if (appAuth.role == 'instructor')
        (l.shellNavPostTrainingResults, '/instructor/resultados', Icons.assessment_outlined),
      if (appAuth.role == 'institution_admin') ...[
        (l.shellNavTrainingRequests, '/institution/pedidos', Icons.playlist_add_check_rounded),
        (l.shellNavTechPark, '/institution/parque', Icons.precision_manufacturing_outlined),
        (l.shellNavEndorsementsShort, '/institution/endorsements', Icons.verified_outlined),
      ],
      if (appAuth.user?['can_review_manufacturers'] == true)
        (l.shellNavFluxxoReview, '/instructor/revisao-fluxxo', Icons.fact_check_outlined),
      (l.shellNavCredentialing, '/instructor/credenciamento', Icons.verified_user_rounded),
    ];

    return Container(
      width: 276,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 28, 14, 24),
        children: [
          Text(
            l.loginBrandTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            appAuth.role == 'institution_admin' ? l.shellAreaManager : l.shellAreaInstructor,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
          ),
          const SizedBox(height: 28),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: item.$2 == currentRoute ? const Color(0x334CD6FB) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                    item.$3,
                    color: item.$2 == currentRoute ? const Color(0xFF50D9FE) : const Color(0xFF94A3B8),
                  ),
                  title: Text(
                    item.$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.$2 == currentRoute ? const Color(0xFF50D9FE) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  onTap: () => onNavigate(item.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.apiOnline});

  final String title;
  final bool apiOnline;

  @override
  Widget build(BuildContext context) {
    final user = appAuth.user;
    final l = AppLocalizations.of(context);
    final name = user?['name']?.toString() ?? l.shellDefaultUserName;

    return Material(
      elevation: 0,
      color: Colors.white,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE0E3E5))),
        ),
        child: Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: apiOnline ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    apiOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                    size: 16,
                    color: apiOnline ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    apiOnline ? l.trnApiOk : l.trnApiOffline,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: apiOnline ? const Color(0xFF047857) : const Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: l.actionSignOut,
              onPressed: () => appAuth.logout(),
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              backgroundColor: const Color(0xFF00677D).withValues(alpha: 0.15),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF00677D))),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage({required this.api});

  final ProductionApi api;

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _institutionDashboard;
  List<Map<String, dynamic>> _seasonRanks = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _error = null;
    });
    try {
      if (appAuth.role == 'institution_admin') {
        if (_gestorNeedsInstitutionLink()) {
          if (mounted) {
            setState(() {
              _summary = null;
              _institutionDashboard = null;
              _seasonRanks = const [];
            });
          }
          return;
        }
        final s = await widget.api.institutionDashboardSummary(t);
        if (mounted) {
          setState(() {
            _institutionDashboard = s;
            _summary = null;
            _seasonRanks = const [];
          });
        }
      } else {
        final s = await widget.api.dashboardSummary(t);
        var ranks = const <Map<String, dynamic>>[];
        if (appAuth.role == 'instructor') {
          try {
            ranks = await widget.api.instructorSeasonRanks(t);
          } catch (_) {
            ranks = const [];
          }
        }
        if (mounted) {
          setState(() {
            _summary = s;
            _institutionDashboard = null;
            _seasonRanks = ranks;
          });
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).errApiConnection);
      }
    }
  }

  Future<void> _exportInstitutionDashboardCsv(BuildContext context) async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final bytes = await widget.api.institutionDashboardExportCsv(t);
      if (!context.mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final l = AppLocalizations.of(context);
      downloadBytesAsFile(bytes, l.dashExportFileInstitutionCsv(stamp));
    } on ApiException catch (e) {
      if (context.mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (context.mounted) context.showErrApiConnectionSnack();
    }
  }

  Future<void> _exportInstitutionDashboardPdf(BuildContext context) async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final bytes = await widget.api.institutionDashboardExportPdf(t);
      if (!context.mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final l = AppLocalizations.of(context);
      downloadBytesAsFile(bytes, l.dashExportFileInstitutionPdf(stamp));
    } on ApiException catch (e) {
      if (context.mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (context.mounted) context.showErrApiConnectionSnack();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final l = AppLocalizations.of(context);
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => _load(),
                            child: Text(l.actionRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    if (appAuth.role == 'institution_admin' && _gestorNeedsInstitutionLink()) {
      return instructorShellScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context).dashLinkInstitutionForKpis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF45464D)),
            ),
          ),
        ),
      );
    }
    if (appAuth.role == 'institution_admin') {
      if (_institutionDashboard == null) {
        return instructorShellScaffold(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              );
            },
          ),
        );
      }
      final online = _InstructorApiReachability.apiOnlineOf(context);
      return _InstitutionDashboardView(
        data: _institutionDashboard!,
        onRefresh: _load,
        apiOnline: online,
        onExportCsv: () => _exportInstitutionDashboardCsv(context),
        onExportPdf: () => _exportInstitutionDashboardPdf(context),
      );
    }
    if (_summary == null) {
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          },
        ),
      );
    }

    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    final trainingCount = _summary!['training_count']?.toString() ?? '0';
    final finishedCount = _summary!['finished_trainings_count']?.toString() ?? '0';
    final participantCount = _summary!['participant_count']?.toString() ?? '0';
    final avg = _summary!['average_score'];
    final avgLabel = avg == null ? l.trainReqDashNone : avg.toString();
    final appr = _summary!['approval_rate_percent'];
    final apprLabel = appr == null ? l.trainReqDashNone : '${appr.toString()} %';
    final recent = (_summary!['recent_trainings'] as List<dynamic>?) ?? [];

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            if (!online) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Color(0xFFB91C1C), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.instrOfflineHint,
                          style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF7F1D1D)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _Kpi(title: l.dashKpiTrainings, value: trainingCount),
                _Kpi(title: l.dashKpiFinished, value: finishedCount),
                _Kpi(title: l.dashKpiUniqueParticipants, value: participantCount),
                _Kpi(title: l.dashKpiAvgCompleted, value: avgLabel),
                _Kpi(title: l.dashKpiApprovalRate, value: apprLabel),
              ],
            ),
            const SizedBox(height: 22),
            if (_seasonRanks.isNotEmpty) ...[
              Text(l.dashSeasonRankingTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l.dashSeasonRankingHint,
                style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
              ),
              const SizedBox(height: 12),
              instructorShellCard(
                child: Column(
                  children: [
                    for (final raw in _seasonRanks) _SeasonRankRow(Map<String, dynamic>.from(raw)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
            Text(l.dashRecentTrainings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            instructorShellCard(
              child: recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l.dashNoTrainingsYet),
                    )
                  : Column(
                      children: [
                        for (final raw in recent)
                          _TrainingRow(Map<String, dynamic>.from(raw as Map)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonRankRow extends StatelessWidget {
  const _SeasonRankRow(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final season = row['season'];
    String seasonName = l.trainReqDashNone;
    String fabName = '';
    if (season is Map) {
      final sm = Map<String, dynamic>.from(season);
      seasonName = sm['name']?.toString() ?? l.trainReqDashNone;
      final m = sm['manufacturer'];
      if (m is Map) {
        fabName = Map<String, dynamic>.from(m)['name']?.toString() ?? '';
      }
    }
    final rank = row['rank'];
    final points = row['points'];
    final rNum = rank is num ? rank.toInt() : int.tryParse(rank?.toString() ?? '');
    final avatarText = (rNum != null && rNum > 0) ? '$rNum' : '?';
    final pointsLabel = points == null ? l.trainReqDashNone : points.toString();

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          avatarText,
          style: const TextStyle(fontSize: 13),
        ),
      ),
      title: Text(seasonName),
      subtitle: fabName.isEmpty ? null : Text(fabName),
      trailing: Text(
        l.dashSeasonPoints(pointsLabel),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _InstitutionDashboardView extends StatelessWidget {
  const _InstitutionDashboardView({
    required this.data,
    required this.onRefresh,
    required this.apiOnline,
    this.onExportCsv,
    this.onExportPdf,
  });

  final Map<String, dynamic> data;
  final Future<void> Function() onRefresh;
  final bool apiOnline;
  final Future<void> Function()? onExportCsv;
  final Future<void> Function()? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pending = data['pending_training_requests']?.toString() ?? '0';
    final pendingCount = int.tryParse(pending) ?? 0;
    final cs = data['completion_summary'];
    Map<String, dynamic>? csm;
    if (cs is Map) {
      csm = Map<String, dynamic>.from(cs);
    }
    final total = csm?['total_enrollments']?.toString() ?? '0';
    final done = csm?['completed_count']?.toString() ?? '0';
    final rate = csm?['completion_rate_percent'];
    final rateLabel = rate == null ? l.trainReqDashNone : '${rate.toString()} %';
    final trainingsCount = data['trainings_count']?.toString() ?? '0';
    final avgAll = data['avg_score_completed'];
    final avgAllLabel = avgAll == null ? l.trainReqDashNone : avgAll.toString();

    final bySector = (data['aggregated_by_sector'] as List<dynamic>?) ?? [];
    final byEq = (data['aggregated_by_equipment'] as List<dynamic>?) ?? [];

    Widget exportWrap(Widget child) => apiOnline ? child : Tooltip(message: l.instrOfflineHint, child: child);

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.dashInstitutionKpisTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l.dashInstitutionLgpdNote,
            style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
          ),
          if (!apiOnline) ...[
            const SizedBox(height: 12),
            _instrOfflineBanner(l),
          ],
          if (pendingCount > 0) ...[
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_late_outlined, color: Color(0xFFB45309), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.dashInstitutionAlertPendingTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.dashInstitutionAlertPendingBody(pendingCount),
                                style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF92400E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonal(
                        onPressed: () {
                          context.findAncestorStateOfType<_InstructorShellState>()?.navigateInShell('/institution/pedidos');
                        },
                        child: Text(l.shellNavTrainingRequests),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l.dashInstitutionShortcutsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  context.findAncestorStateOfType<_InstructorShellState>()?.navigateInShell('/institution/pedidos');
                },
                icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                label: Text(l.shellNavTrainingRequests),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.findAncestorStateOfType<_InstructorShellState>()?.navigateInShell('/institution/parque');
                },
                icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                label: Text(l.shellNavTechPark),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.findAncestorStateOfType<_InstructorShellState>()?.navigateInShell('/institution/endorsements');
                },
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(l.shellNavEndorsementsShort),
              ),
            ],
          ),
          if (onExportCsv != null || onExportPdf != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (onExportCsv != null)
                  exportWrap(
                    OutlinedButton.icon(
                      onPressed: apiOnline ? () => onExportCsv!() : null,
                      icon: const Icon(Icons.table_chart_outlined, size: 20),
                      label: Text(l.dashExportCsv),
                    ),
                  ),
                if (onExportPdf != null)
                  exportWrap(
                    OutlinedButton.icon(
                      onPressed: apiOnline ? () => onExportPdf!() : null,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                      label: Text(l.dashExportPdf),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Kpi(title: l.dashKpiPendingRequests, value: pending),
              _Kpi(title: l.dashKpiInstitutionTrainings, value: trainingsCount),
              _Kpi(title: l.dashKpiEnrollmentsTotal, value: total),
              _Kpi(title: l.dashKpiCompleted, value: done),
              _Kpi(title: l.dashKpiCompletionRate, value: rateLabel),
              _Kpi(title: l.dashKpiAvgScoreOverall, value: avgAllLabel),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.dashByEquipment, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          instructorShellCard(
            child: byEq.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.dashNoEquipmentData),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            context
                                .findAncestorStateOfType<_InstructorShellState>()
                                ?.navigateInShell('/institution/parque');
                          },
                          icon: const Icon(Icons.precision_manufacturing_outlined, size: 20),
                          label: Text(l.shellNavTechPark),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ...byEq.map((raw) {
                        final row = Map<String, dynamic>.from(raw as Map);
                        return ListTile(
                          title: Text(row['label']?.toString() ?? l.trainReqDashNone),
                          subtitle: Text(
                            l.dashEquipmentSubtitle(
                              row['total_enrollments'] ?? l.trainReqDashNone,
                              row['completed_count'] ?? l.trainReqDashNone,
                              row['completion_rate_percent'] ?? l.trainReqDashNone,
                              row['avg_score'] ?? l.trainReqDashNone,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          Text(l.dashSectorAveragesTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          instructorShellCard(
            child: bySector.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.dashNoSectorHistory),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                context
                                    .findAncestorStateOfType<_InstructorShellState>()
                                    ?.navigateInShell('/institution/pedidos');
                              },
                              icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                              label: Text(l.shellNavTrainingRequests),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                context
                                    .findAncestorStateOfType<_InstructorShellState>()
                                    ?.navigateInShell('/institution/parque');
                              },
                              icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                              label: Text(l.shellNavTechPark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ...bySector.map((raw) {
                        final row = Map<String, dynamic>.from(raw as Map);
                        return ListTile(
                          title: Text(row['sector']?.toString() ?? l.trainReqDashNone),
                          subtitle: Text(
                            l.dashSectorSubtitle(
                              (row['total_enrollments'] as num?)?.toInt() ?? 0,
                              (row['completed_count'] as num?)?.toInt() ?? 0,
                              (row['completions'] as num?)?.toInt() ?? 0,
                              row['avg_score'] != null
                                  ? row['avg_score'].toString()
                                  : l.trainReqDashNone,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: instructorShellCard(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ClinicalPrecisionColors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingRow extends StatelessWidget {
  const _TrainingRow(this.t);

  final Map<String, dynamic> t;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inst = t['institution'] as Map<String, dynamic>?;
    final instName = inst?['name']?.toString() ?? l.trainReqDashNone;
    final statusLabel = localizedTrainingLifecycleStatus(l, t['status']?.toString());
    final hashRaw = t['join_hash']?.toString().trim();
    final hashLabel = (hashRaw != null && hashRaw.isNotEmpty) ? hashRaw : l.trainReqDashNone;
    return ListTile(
      title: Text(t['title']?.toString() ?? l.trainReqDashNone, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('$instName · $statusLabel'),
      trailing: Text(hashLabel, style: const TextStyle(fontSize: 12, color: ClinicalPrecisionColors.secondary)),
    );
  }
}

/// APP-SAL-02 — gestão pós-sessão: lista de inscritos + repescagem (fluxo Application).
class _PostTrainingResultsPage extends StatefulWidget {
  const _PostTrainingResultsPage({required this.api});

  final ProductionApi api;

  @override
  State<_PostTrainingResultsPage> createState() => _PostTrainingResultsPageState();
}

class _PostTrainingResultsPageState extends State<_PostTrainingResultsPage> {
  List<Map<String, dynamic>> _trainings = [];
  int? _selectedId;
  Map<String, dynamic>? _monitor;
  bool _loading = false;
  bool _closingTraining = false;
  int? _certPdfLoadingId;
  int? _issueCertLoadingEid;
  bool _exportCsvLoading = false;
  bool _exportPdfLoading = false;
  final Set<int> _repescageIds = {};
  List<Map<String, dynamic>> _trainingBlocks = [];
  int? _repescageBlockId;
  final TextEditingController _postResultsParticipantSearchCtrl = TextEditingController();
  Timer? _postResultsParticipantSearchDebounce;
  String _postResultsParticipantSearchApplied = '';

  @override
  void dispose() {
    _postResultsParticipantSearchDebounce?.cancel();
    _postResultsParticipantSearchCtrl.dispose();
    super.dispose();
  }

  void _schedulePostResultsParticipantSearch() {
    _postResultsParticipantSearchDebounce?.cancel();
    _postResultsParticipantSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      var t = _postResultsParticipantSearchCtrl.text.trim();
      if (t.length > 120) t = t.substring(0, 120);
      setState(() => _postResultsParticipantSearchApplied = t);
    });
  }

  bool _canFinishTrainingFromMonitor() {
    final st = _monitor?['training']?['status']?.toString();
    return st != null && st != 'finished' && st != 'cancelled';
  }

  Future<void> _confirmFinishTraining() async {
    final l = AppLocalizations.of(context);
    final tid = _selectedId;
    if (tid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.postTrainingFinishTrainingConfirmTitle),
        content: Text(l.postTrainingFinishTrainingConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mfgBtnCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.postTrainingFinishTraining)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _closingTraining = true);
    try {
      await widget.api.updateTraining(t, tid, {'status': 'finished'});
      await _refreshTrainings();
      await _loadMonitor();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.postTrainingFinishTrainingDone)));
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _closingTraining = false);
    }
  }

  Future<void> _onParticipantCertificatePdf(Map<String, dynamic> cert) async {
    final l = AppLocalizations.of(context);
    final t = appAuth.token;
    final tid = _selectedId;
    final cid = _parseInt(cert['id']);
    final code = cert['certificate_code']?.toString() ?? l.trnCertCodeFallback;
    if (t == null || tid == null || cid == null) return;
    setState(() => _certPdfLoadingId = cid);
    try {
      final bytes = await widget.api.downloadTrainingParticipantCertificatePdf(t, tid, cid);
      if (!mounted) return;
      final safe = code.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '-');
      final filename = l.trnCertDownloadFilename(safe);
      downloadBytesAsFile(bytes, '$filename.pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trnSnackCertPdfDownloaded)));
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trnSnackCertPdfFailed)));
      }
    } finally {
      if (mounted) setState(() => _certPdfLoadingId = null);
    }
  }

  Future<void> _issueCertificateForEnrollment(int enrollmentId) async {
    final l = AppLocalizations.of(context);
    final t = appAuth.token;
    final tid = _selectedId;
    if (t == null || tid == null) return;
    setState(() => _issueCertLoadingEid = enrollmentId);
    try {
      final r = await widget.api.issueTrainingEnrollmentCertificate(t, tid, enrollmentId);
      await _loadMonitor();
      if (!mounted) return;
      final already = r['already_issued'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(already ? l.postTrainingIssueCertificateAlready : l.postTrainingIssueCertificateDone),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _issueCertLoadingEid = null);
    }
  }

  Future<void> _exportTrainingCertificatesCsv() async {
    final l = AppLocalizations.of(context);
    final t = appAuth.token;
    final tid = _selectedId;
    if (t == null || tid == null) return;
    setState(() => _exportCsvLoading = true);
    try {
      final bytes = await widget.api.downloadTrainingCertificatesReportCsv(t, tid);
      if (!mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      downloadBytesAsFile(bytes, l.postTrainingExportCertificatesCsvFilename(tid, stamp));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.postTrainingExportCertificatesDone)));
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _exportCsvLoading = false);
    }
  }

  Future<void> _exportTrainingCertificatesPdf() async {
    final l = AppLocalizations.of(context);
    final t = appAuth.token;
    final tid = _selectedId;
    if (t == null || tid == null) return;
    setState(() => _exportPdfLoading = true);
    try {
      final bytes = await widget.api.downloadTrainingCertificatesReportPdf(t, tid);
      if (!mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      downloadBytesAsFile(bytes, l.postTrainingExportCertificatesPdfFilename(tid, stamp));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.postTrainingExportCertificatesPdfDone)));
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _exportPdfLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTrainings();
  }

  Future<void> _refreshTrainings() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.myTrainings(t);
      if (mounted) {
        setState(() {
          _trainings = list;
          if (_selectedId == null && list.isNotEmpty) {
            _selectedId = _parseInt(list.first['id']);
          }
        });
        await _loadMonitor();
      }
    } catch (_) {}
  }

  Future<void> _loadMonitor() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    try {
      final m = await widget.api.trainingParticipants(t, id);
      if (mounted) {
        final bl = m['training_blocks'];
        final blocks = bl is List
            ? bl.map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : <Map<String, dynamic>>[];
        setState(() {
          _monitor = m;
          _trainingBlocks = blocks;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _monitor = null);
    }
  }

  Future<void> _runRepescage() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null || _repescageIds.isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.api.realtimeTrainingCommand(
        t,
        id,
        action: 'repescage',
        payload: {
          'enrollment_ids': _repescageIds.toList(),
          if (_repescageBlockId != null) 'training_block_id': _repescageBlockId,
        },
      );
      setState(() => _repescageIds.clear());
      await _loadMonitor();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).comandoSnackRepescageDone)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    final participants = (_monitor?['participants'] as List<dynamic>?) ?? [];
    final searchQ = _postResultsParticipantSearchApplied.toLowerCase();
    final filteredParticipants = searchQ.isEmpty
        ? participants
        : participants.where((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            final u = row['user'] as Map<String, dynamic>?;
            final name = u?['name']?.toString().toLowerCase() ?? '';
            final email = u?['email']?.toString().toLowerCase() ?? '';
            return name.contains(searchQ) || email.contains(searchQ);
          }).toList();

    final body = _selectedId == null
        ? LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _refreshTrainings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Text(
                        l.postTrainingPickTraining,
                        style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 900;
              final listMinHeight = math.max(160.0, constraints.maxHeight * 0.35);
              Map<String, dynamic>? trainingForCert;
              final trw = _monitor?['training'];
              if (trw is Map) {
                trainingForCert = Map<String, dynamic>.from(trw);
              }
              final participantPane = instructorShellCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.comandoParticipantsTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _postResultsParticipantSearchCtrl,
                        onChanged: (_) => _schedulePostResultsParticipantSearch(),
                        decoration: InputDecoration(
                          hintText: l.comandoParticipantsSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded, size: 22),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: ClinicalPrecisionColors.surfaceContainerLowest,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshTrainings,
                          child: participants.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: listMinHeight,
                                      child: Center(child: Text(l.comandoNoParticipants)),
                                    ),
                                  ],
                                )
                              : filteredParticipants.isEmpty
                                  ? ListView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: listMinHeight,
                                          child: Center(
                                            child: Text(
                                              l.comandoParticipantsNoMatch,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: filteredParticipants.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final raw = filteredParticipants[index];
                                        final row = Map<String, dynamic>.from(raw as Map);
                                        final eid = _parseInt(row['enrollment']?['id']);
                                        return _ParticipantTile(
                                          row,
                                          apiOnline: online,
                                          selected: eid != null && _repescageIds.contains(eid),
                                          onToggle: (enrollmentId) {
                                            setState(() {
                                              if (_repescageIds.contains(enrollmentId)) {
                                                _repescageIds.remove(enrollmentId);
                                              } else {
                                                _repescageIds.add(enrollmentId);
                                              }
                                            });
                                          },
                                          onCertificatePdf: _onParticipantCertificatePdf,
                                          certificatePdfLoadingForId: _certPdfLoadingId,
                                          onIssueManualCertificate: eid != null &&
                                                  participantEligibleForManualCertificate(row, trainingForCert)
                                              ? () => _issueCertificateForEnrollment(eid)
                                              : null,
                                          issueCertificateBusy: eid != null && _issueCertLoadingEid == eid,
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              final postRepescageActionButton = OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber.shade200,
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.65)),
                ),
                onPressed: _loading || _repescageIds.isEmpty || !online ? null : _runRepescage,
                child: Text(l.comandoRepescageCount(_repescageIds.length)),
              );
              final postRepescageAction =
                  online ? postRepescageActionButton : Tooltip(message: l.instrOfflineHint, child: postRepescageActionButton);
              final repescPane = instructorShellCard(
                color: ClinicalPrecisionColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.comandoRepescageScope,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        if (_trainingBlocks.isNotEmpty)
                          DropdownButtonFormField<int?>(
                            key: ValueKey<String>('repesc_post_${_repescageBlockId ?? 'all'}'),
                            decoration: InputDecoration(
                              labelText: l.comandoRepescageScope,
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
                            ),
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            initialValue: _repescageBlockId,
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text(l.comandoRepescageScopeAll, style: const TextStyle(color: Colors.white)),
                              ),
                              for (final b in _trainingBlocks)
                                DropdownMenuItem<int?>(
                                  value: _parseInt(b['id']),
                                  child: Text(
                                    b['title']?.toString() ?? l.comandoBlockDefault,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) => setState(() => _repescageBlockId = v),
                          ),
                        const SizedBox(height: 16),
                        postRepescageAction,
                        const SizedBox(height: 20),
                        Text(
                          l.comandoHelpFooter,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: participantPane),
                    const SizedBox(height: 16),
                    Expanded(flex: 2, child: repescPane),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: participantPane),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: repescPane),
                ],
              );
            },
          );

    return instructorShellScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.shellTitlePostTrainingResults,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(l.postTrainingIntro, style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 20),
            if (!online) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Color(0xFFB91C1C), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.instrOfflineHint,
                          style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF7F1D1D)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey<int?>(_selectedId),
                    decoration: InputDecoration(
                      labelText: l.comandoActiveTraining,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: ClinicalPrecisionColors.surfaceContainerLowest,
                    ),
                    initialValue: _selectedId,
                    items: [
                      for (final tr in _trainings)
                        DropdownMenuItem(
                          value: _parseInt(tr['id']),
                          child: Text(tr['title']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedId = v;
                        _repescageIds.clear();
                        _repescageBlockId = null;
                        _postResultsParticipantSearchDebounce?.cancel();
                        _postResultsParticipantSearchCtrl.clear();
                        _postResultsParticipantSearchApplied = '';
                      });
                      _loadMonitor();
                    },
                  ),
                ),
                IconButton(onPressed: _refreshTrainings, icon: const Icon(Icons.refresh_rounded)),
                if (_selectedId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 6),
                    child: Tooltip(
                      message: online ? l.postTrainingExportCertificatesCsvTooltip : l.instrOfflineHint,
                      child: IconButton(
                        onPressed: (_exportCsvLoading || _exportPdfLoading || !online) ? null : _exportTrainingCertificatesCsv,
                        icon: _exportCsvLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.table_chart_outlined),
                      ),
                    ),
                  ),
                if (_selectedId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 6),
                    child: Tooltip(
                      message: online ? l.postTrainingExportCertificatesPdfTooltip : l.instrOfflineHint,
                      child: IconButton(
                        onPressed: (_exportCsvLoading || _exportPdfLoading || !online) ? null : _exportTrainingCertificatesPdf,
                        icon: _exportPdfLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                      ),
                    ),
                  ),
                if (_selectedId != null && _canFinishTrainingFromMonitor())
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 6),
                    child: online
                        ? FilledButton.tonal(
                            onPressed: _closingTraining ? null : _confirmFinishTraining,
                            child: Text(l.postTrainingFinishTraining),
                          )
                        : Tooltip(
                            message: l.instrOfflineHint,
                            child: FilledButton.tonal(
                              onPressed: null,
                              child: Text(l.postTrainingFinishTraining),
                            ),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _TreinamentoPage extends StatefulWidget {
  const _TreinamentoPage({required this.api});

  final ProductionApi api;

  @override
  State<_TreinamentoPage> createState() => _TreinamentoPageState();
}

class _TreinamentoPageState extends State<_TreinamentoPage> {
  final _title = TextEditingController();
  final _scheduled = TextEditingController();
  String _type = 'official';
  int? _institutionId;

  List<Map<String, dynamic>> _institutions = [];
  List<Map<String, dynamic>> _officialTemplates = [];
  int? _templatePickId;
  Map<String, dynamic>? _createdTraining;
  String _postRepescageScorePolicy = 'full_average';
  bool _repescageVariantBank = false;
  bool _loading = false;
  String? _error;

  final List<_QuestionDraft> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
    _loadOfficialTemplates();
    _questions.add(_QuestionDraft());
  }

  @override
  void dispose() {
    _title.dispose();
    _scheduled.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInstitutions() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.institutions(t);
      if (mounted) {
        setState(() {
          _institutions = list;
          if (_institutionId == null && list.isNotEmpty) {
            _institutionId = _parseInt(list.first['id']);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadOfficialTemplates() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.officialTrainingTemplatesCatalog(t);
      if (mounted) {
        setState(() {
          _officialTemplates = list;
          if (_templatePickId == null && list.isNotEmpty) {
            _templatePickId = _parseInt(list.first['id']);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _reloadTreinamentoPage() async {
    await Future.wait([
      _loadInstitutions(),
      _loadOfficialTemplates(),
    ]);
  }

  void _syncRepescagePolicyFromTraining(Map<String, dynamic> tr) {
    final m = tr['metadata'];
    if (m is Map) {
      if (m['post_repescage_score_policy'] != null) {
        final p = m['post_repescage_score_policy'].toString();
        if (p == 'full_average' || p == 'recovery_only') {
          _postRepescageScorePolicy = p;
        }
      }
      final vb = m['repescage_variant_bank'];
      if (vb == true || vb == false) {
        _repescageVariantBank = vb == true;
      } else if (vb == 1 || vb == 0) {
        _repescageVariantBank = vb == 1;
      }
    }
  }

  Future<void> _saveRepescageScorePolicy() async {
    final t = appAuth.token;
    final tr = _createdTraining;
    if (t == null || tr == null) return;
    final id = _parseInt(tr['id']);
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final existing = _createdTraining?['metadata'];
      final merged = <String, dynamic>{
        if (existing is Map) ...Map<String, dynamic>.from(existing),
        'post_repescage_score_policy': _postRepescageScorePolicy,
        'repescage_variant_bank': _repescageVariantBank,
      };
      final updated = await widget.api.updateTraining(t, id, {
        'metadata': merged,
      });
      if (mounted) {
        setState(() {
          _createdTraining = updated;
          _syncRepescagePolicyFromTraining(updated);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).trainingSnackPolicySaved)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _instantiateFromOfficialTemplate() async {
    final t = appAuth.token;
    if (t == null || _institutionId == null || _templatePickId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tr = await widget.api.instantiateTrainingFromTemplate(
        t,
        _templatePickId!,
        institutionId: _institutionId!,
        title: _title.text.trim().isEmpty ? null : _title.text.trim(),
        scheduledAt: _scheduled.text.trim().isEmpty ? null : _scheduled.text.trim(),
      );
      if (mounted) {
        setState(() {
          _createdTraining = tr;
          _syncRepescagePolicyFromTraining(tr);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).trainingSnackFromTemplate)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createTraining() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_institutionId == null) {
      setState(() => _error = AppLocalizations.of(context).trainingPickInstitution);
      return;
    }
    if (_title.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.of(context).trainingErrTitle);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = <String, dynamic>{
        'institution_id': _institutionId,
        'title': _title.text.trim(),
        'type': _type,
        if (_scheduled.text.trim().isNotEmpty) 'scheduled_at': _scheduled.text.trim(),
        'status': 'draft',
      };
      final tr = await widget.api.createTraining(t, body);
      if (mounted) {
        setState(() {
          _createdTraining = tr;
          _syncRepescagePolicyFromTraining(tr);
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveQuestionnaire() async {
    final t = appAuth.token;
    final tr = _createdTraining;
    if (t == null || tr == null) return;

    final tid = _parseInt(tr['id']);
    if (tid == null) return;

    final l = AppLocalizations.of(context);
    final blocks = <Map<String, dynamic>>[
      {
        'title': l.trainingDefaultQuestionnaireBlockTitle,
        'sort_order': 1,
        'questions': <Map<String, dynamic>>[],
      },
    ];

    var order = 1;
    for (final q in _questions) {
      final prompt = q.prompt.text.trim();
      if (prompt.isEmpty) continue;
      final opts = <Map<String, dynamic>>[];
      for (var i = 0; i < q.optionCtrls.length; i++) {
        final label = q.optionCtrls[i].text.trim();
        if (label.isEmpty) continue;
        opts.add({
          'label': label,
          'is_correct': q.correctIndex == i,
          'sort_order': opts.length + 1,
        });
      }
      if (opts.length < 2) continue;
      if (!opts.any((o) => o['is_correct'] == true)) {
        setState(() => _error = l.trainingErrQuestionCorrect);
        return;
      }
      (blocks.first['questions'] as List<Map<String, dynamic>>).add({
        'prompt': prompt,
        'sort_order': order,
        'options': opts,
      });
      order++;
    }

    if ((blocks.first['questions'] as List).isEmpty) {
      setState(() => _error = l.trainingErrQuestionValid);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.syncQuestionnaire(t, tid, {'blocks': blocks});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.trainingSnackQuestionnaireSaved)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(l, e));
    } catch (_) {
      if (mounted) setState(() => _error = l.errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    final tr = _createdTraining;
    Widget offlineWrap(Widget child) => online ? child : Tooltip(message: s.instrOfflineHint, child: child);

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: _reloadTreinamentoPage,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
          Text(s.trainingSectionTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
          const SizedBox(height: 14),
          if (!online) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Color(0xFFB91C1C), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.instrOfflineHint,
                        style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF7F1D1D)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          instructorShellCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: s.fieldInstitution),
                  initialValue: _institutionId,
                  items: [
                    for (final i in _institutions)
                      DropdownMenuItem(
                        value: _parseInt(i['id']),
                        child: Text(i['name']?.toString() ?? ''),
                      ),
                  ],
                  onChanged: (v) => setState(() => _institutionId = v),
                ),
                const SizedBox(height: 12),
                TextField(controller: _title, decoration: InputDecoration(labelText: s.trainingFieldTitle)),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'official', label: Text(s.trainingTypeOfficial)),
                    ButtonSegment(value: 'custom', label: Text(s.trainingTypeCustom)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (sel) => setState(() => _type = sel.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _scheduled,
                  decoration: InputDecoration(
                    labelText: s.trainingScheduledLabel,
                    hintText: s.trainingScheduledHint,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ],
                const SizedBox(height: 16),
                offlineWrap(
                  FilledButton(
                    onPressed: _loading || !online ? null : _createTraining,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF131B2E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(s.trainingCreateButton),
                  ),
                ),
              ],
            ),
            ),
          ),
        if (_officialTemplates.isNotEmpty) ...[
          const SizedBox(height: 18),
          instructorShellCard(
            color: const Color(0xFFF0FDFA),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.trainingTemplateCardTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    s.trainingTemplateCardBody,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: s.trainingTemplateLabel),
                    initialValue: _templatePickId,
                    items: [
                      for (final o in _officialTemplates)
                        DropdownMenuItem(
                          value: _parseInt(o['id']),
                          child: Text(o['title']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: (v) => setState(() => _templatePickId = v),
                  ),
                  const SizedBox(height: 12),
                  offlineWrap(
                    FilledButton(
                      onPressed: _loading || !online ? null : _instantiateFromOfficialTemplate,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                      child: Text(s.trainingUseTemplateButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (tr != null) ...[
          const SizedBox(height: 22),
          instructorShellCard(
            color: const Color(0xFF0F172A),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.trainingJoinCodeTitle, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  SelectableText(
                    _joinHashDisplay(Map<String, dynamic>.from(tr), s),
                    style: const TextStyle(color: Color(0xFF50D9FE), fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.trainingInternalId('${_parseInt(tr['id']) ?? s.trainReqDashNone}'),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          instructorShellCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.trainingPostRepescageTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    s.trainingPostRepescageBody,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF45464D)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: s.trainingPolicyFinalLabel),
                    initialValue: _postRepescageScorePolicy,
                    items: [
                      DropdownMenuItem(value: 'full_average', child: Text(s.trainingPolicyFullAverage)),
                      DropdownMenuItem(value: 'recovery_only', child: Text(s.trainingPolicyRecoveryOnly)),
                    ],
                    onChanged: !online
                        ? null
                        : (v) {
                            if (v != null) setState(() => _postRepescageScorePolicy = v);
                          },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.trainingVariantBankTitle),
                    subtitle: Text(
                      s.trainingVariantBankSubtitle,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _repescageVariantBank,
                    onChanged: _loading || !online ? null : (v) => setState(() => _repescageVariantBank = v),
                  ),
                  const SizedBox(height: 12),
                  offlineWrap(
                    FilledButton.tonal(
                      onPressed: _loading || !online ? null : _saveRepescageScorePolicy,
                      child: Text(s.trainingSavePolicyButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(s.trainingQuestionnaireTitle, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              offlineWrap(
                TextButton.icon(
                  onPressed: !online ? null : () => setState(() => _questions.add(_QuestionDraft())),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.trainingAddQuestion),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _questions.length; i++)
            _QuestionEditorCard(
              key: ValueKey(i),
              index: i,
              draft: _questions[i],
              onRemove: _questions.length > 1
                  ? () => setState(() {
                        _questions[i].dispose();
                        _questions.removeAt(i);
                      })
                  : null,
            ),
          const SizedBox(height: 16),
          offlineWrap(
            FilledButton(
              onPressed: _loading || !online ? null : _saveQuestionnaire,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(s.trainingSaveQuestionnaireApi),
            ),
          ),
        ],
        ],
        ),
      ),
    );
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

double? _parseScoreDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().replaceAll(',', '.');
  return double.tryParse(s);
}

bool participantEligibleForManualCertificate(
  Map<String, dynamic> row,
  Map<String, dynamic>? training,
) {
  if (row['certificate'] != null) {
    return false;
  }
  final e = row['enrollment'];
  if (e is! Map) {
    return false;
  }
  final em = Map<String, dynamic>.from(e);
  if (em['status']?.toString() != 'completed') {
    return false;
  }
  final score = _parseScoreDouble(em['score']);
  if (score == null) {
    return false;
  }
  final pct = training?['passing_score_percent'];
  final passing = ((pct is num) ? pct : 70).toDouble() / 10.0;
  if (score < passing) {
    return false;
  }
  final st = training?['status']?.toString();
  return st == 'in_progress' || st == 'finished';
}

Widget _postTrainingOutcomeChip(BuildContext context, Map<String, dynamic>? enrollment) {
  final l = AppLocalizations.of(context);
  final inRecovery = enrollment?['in_recovery'] == true || enrollment?['in_recovery'] == 1;
  final st = enrollment?['status']?.toString();
  final scoreVal = _parseScoreDouble(enrollment?['score']);

  if (st == 'waiting') {
    return _PostTrainingOutcomePill(
      label: l.postTrainingOutcomeWaitingRoom,
      background: const Color(0xFFFFF7ED),
      foreground: const Color(0xFFB45309),
      border: const Color(0xFFFDBA74),
    );
  }
  if (inRecovery) {
    return _PostTrainingOutcomePill(
      label: l.postTrainingOutcomeRecovery,
      background: const Color(0xFFFFF7ED),
      foreground: const Color(0xFFC2410C),
      border: const Color(0xFFFDBA74),
    );
  }
  if (st == 'completed') {
    if (scoreVal != null) {
      if (scoreVal >= 7.0) {
        return _PostTrainingOutcomePill(
          label: l.postTrainingOutcomeApproved,
          background: const Color(0xFFECFDF5),
          foreground: const Color(0xFF065F46),
          border: const Color(0xFF6EE7B7),
        );
      }
      return _PostTrainingOutcomePill(
        label: l.postTrainingOutcomeInsufficient,
        background: const Color(0xFFFFF7ED),
        foreground: const Color(0xFF9A3412),
        border: const Color(0xFFFDBA74),
      );
    }
    return _PostTrainingOutcomePill(
      label: l.postTrainingOutcomeCompletedNoGrade,
      background: const Color(0xFFF1F5F9),
      foreground: const Color(0xFF475569),
      border: const Color(0xFFE2E8F0),
    );
  }
  return _PostTrainingOutcomePill(
    label: l.postTrainingOutcomeInProgress,
    background: const Color(0xFFF1F5F9),
    foreground: const Color(0xFF475569),
    border: const Color(0xFFE2E8F0),
  );
}

class _PostTrainingOutcomePill extends StatelessWidget {
  const _PostTrainingOutcomePill({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground, height: 1.2),
      ),
    );
  }
}

String _joinHashDisplay(Map<String, dynamic> row, AppLocalizations l) {
  final h = row['join_hash']?.toString().trim();
  return (h != null && h.isNotEmpty) ? h : l.trainReqDashNone;
}

String _participantInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final s = parts.single;
    return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s[0].toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

Color _credentialStatusColor(String? s) {
  switch (s) {
    case 'approved':
      return const Color(0xFFE8FFF4);
    case 'pending':
      return const Color(0xFFFFF7ED);
    case 'rejected':
      return const Color(0xFFFFF1F2);
    case 'suspended':
      return const Color(0xFFF1F5FF);
    default:
      return const Color(0xFFF4F6F8);
  }
}

class _CredentialInstitutionRow extends StatelessWidget {
  const _CredentialInstitutionRow(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inst = row['institution'] as Map?;
    final name = inst?['name']?.toString() ?? l.trainReqDashNone;
    final cnpj = inst?['cnpj']?.toString();
    final st = row['status']?.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (cnpj != null && cnpj.isNotEmpty)
                  Text(cnpj, style: const TextStyle(fontSize: 12, color: Color(0xFF45464D))),
              ],
            ),
          ),
          Chip(
            label: Text(localizedCredentialQueueStatus(l, st)),
            visualDensity: VisualDensity.compact,
            backgroundColor: _credentialStatusColor(st),
          ),
        ],
      ),
    );
  }
}

class _CredentialManufacturerRow extends StatelessWidget {
  const _CredentialManufacturerRow(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = row['manufacturer'] as Map?;
    final name = m?['name']?.toString() ?? l.trainReqDashNone;
    final st = row['status']?.toString();
    final fee = row['fee_paid'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  fee ? l.credFeePaid : l.credFeePending,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF45464D)),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(localizedCredentialQueueStatus(l, st)),
            visualDensity: VisualDensity.compact,
            backgroundColor: _credentialStatusColor(st),
          ),
        ],
      ),
    );
  }
}

class _QuestionDraft {
  _QuestionDraft() : prompt = TextEditingController(), optionCtrls = List.generate(4, (_) => TextEditingController());

  final TextEditingController prompt;
  final List<TextEditingController> optionCtrls;
  int correctIndex = 0;

  void dispose() {
    prompt.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
  }
}

class _QuestionEditorCard extends StatefulWidget {
  const _QuestionEditorCard({super.key, required this.index, required this.draft, this.onRemove});

  final int index;
  final _QuestionDraft draft;
  final VoidCallback? onRemove;

  @override
  State<_QuestionEditorCard> createState() => _QuestionEditorCardState();
}

class _QuestionEditorCardState extends State<_QuestionEditorCard> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final draft = widget.draft;
    return instructorShellCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(l.trainingQuestionN(widget.index + 1), style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline_rounded)),
              ],
            ),
            TextField(controller: draft.prompt, decoration: InputDecoration(labelText: l.trainingPromptLabel)),
            const SizedBox(height: 12),
            Text(l.trainingOptionsMarkCorrect, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: draft.correctIndex,
              onChanged: (v) => setState(() => draft.correctIndex = v ?? 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < draft.optionCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Radio<int>(value: i),
                          Expanded(
                            child: TextField(
                              controller: draft.optionCtrls[i],
                              decoration: InputDecoration(labelText: l.trainingOptionN(i + 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstitutionParquePage extends StatefulWidget {
  const _InstitutionParquePage({required this.api});

  final ProductionApi api;

  @override
  State<_InstitutionParquePage> createState() => _InstitutionParquePageState();
}

class _InstitutionParquePageState extends State<_InstitutionParquePage> {
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _categoryCatalog = [];
  bool _loading = true;
  String? _error;
  String? _statusFilter;
  /// Id da categoria (`config/equipment.categories`) ou null = todas.
  String? _categoryFilter;
  int? _pickedCatalogId;
  final _sector = TextEditingController();
  final _parkSearchCtrl = TextEditingController();
  Timer? _parkSearchDebounce;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _parkSearchDebounce?.cancel();
    _sector.dispose();
    _parkSearchCtrl.dispose();
    super.dispose();
  }

  void _scheduleParkSearchReload() {
    _parkSearchDebounce?.cancel();
    _parkSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (!_InstructorApiReachability.apiOnlineOf(context)) return;
      unawaited(_reload());
    });
  }

  Future<void> _reload() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var cats = _categoryCatalog;
      if (cats.isEmpty) {
        try {
          cats = await widget.api.equipmentCategoriesCatalog(t);
        } catch (_) {
          cats = [];
        }
      }
      final q = _parkSearchCtrl.text.trim().isEmpty ? null : _parkSearchCtrl.text.trim();
      final tpl = await widget.api.institutionEquipmentTemplates(t, category: _categoryFilter, search: q);
      final u = await widget.api.institutionEquipmentPark(t, status: _statusFilter, category: _categoryFilter, search: q);
      if (!mounted) return;
      setState(() {
        _categoryCatalog = cats;
        _templates = tpl;
        _units = u;
        final ids = tpl.map((e) => _parseInt(e['id'])).whereType<int>().toSet();
        if (tpl.isEmpty) {
          _pickedCatalogId = null;
        } else if (_pickedCatalogId == null || !ids.contains(_pickedCatalogId)) {
          _pickedCatalogId = _parseInt(tpl.first['id']);
        }
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).trainReqLoadFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setFilter(String? s) {
    setState(() => _statusFilter = s);
    _reload();
  }

  void _setCategoryFilter(String? categoryId) {
    setState(() => _categoryFilter = categoryId);
    _reload();
  }

  String _categoryLabel(String id) {
    for (final c in _categoryCatalog) {
      if (c['id']?.toString() == id) {
        return c['label']?.toString() ?? id;
      }
    }
    return id;
  }

  Future<void> _addUnit() async {
    final t = appAuth.token;
    final cid = _pickedCatalogId;
    if (t == null || cid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).parkSnackPickCatalog)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.api.createInstitutionParkEquipment(
        t,
        catalogEquipmentId: cid,
        sector: _sector.text.trim().isEmpty ? null : _sector.text.trim(),
      );
      _sector.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).parkSnackUnitRegisteredPending)),
        );
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  Future<void> _activate(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.updateInstitutionParkEquipment(t, id, {'status': 'active'});
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  Future<void> _remove(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.deleteInstitutionParkEquipment(t, id);
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  String _mfgName(Map<String, dynamic> row) {
    final m = row['manufacturer'];
    if (m is Map) return m['name']?.toString() ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    if (_gestorNeedsInstitutionLink()) {
      return instructorShellScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.parkBannerLinkInstitutionFirst),
          ),
        ),
      );
    }

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: _loading && _templates.isEmpty && _units.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                  ),
                Text(l.shellTitleTechPark, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  l.parkIntro,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                ),
                const SizedBox(height: 12),
                if (!online) ...[
                  _instrOfflineBanner(l),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _parkSearchCtrl,
                  decoration: InputDecoration(
                    labelText: l.parkSearchHint,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: _loading || !online ? null : () {
                        _parkSearchDebounce?.cancel();
                        unawaited(_reload());
                      },
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _scheduleParkSearchReload();
                  },
                  onSubmitted: (_) {
                    if (!online) return;
                    _parkSearchDebounce?.cancel();
                    unawaited(_reload());
                  },
                ),
                const SizedBox(height: 16),
                Text(l.parkFilterByState, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l.parkFilterChipAll),
                      selected: _statusFilter == null,
                      onSelected: _loading || !online ? null : (_) => _setFilter(null),
                    ),
                    ChoiceChip(
                      label: Text(l.parkFilterChipPending),
                      selected: _statusFilter == 'pending',
                      onSelected: _loading || !online ? null : (_) => _setFilter('pending'),
                    ),
                    ChoiceChip(
                      label: Text(l.parkFilterChipActive),
                      selected: _statusFilter == 'active',
                      onSelected: _loading || !online ? null : (_) => _setFilter('active'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l.parkFilterByCategory, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: Text(l.parkFilterChipAllCategories),
                      selected: _categoryFilter == null,
                      onSelected: _loading || !online ? null : (_) => _setCategoryFilter(null),
                    ),
                    ..._categoryCatalog.map((c) {
                      final cid = c['id']?.toString();
                      if (cid == null || cid.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ChoiceChip(
                        label: Text(c['label']?.toString() ?? cid),
                        selected: _categoryFilter == cid,
                        onSelected: _loading || !online ? null : (_) => _setCategoryFilter(cid),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l.parkSectionAddUnit, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_templates.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.parkEmptyCatalog),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          context
                              .findAncestorStateOfType<_InstructorShellState>()
                              ?.navigateInShell('/institution/endorsements');
                        },
                        icon: const Icon(Icons.verified_outlined, size: 20),
                        label: Text(l.shellNavEndorsementsShort),
                      ),
                    ],
                  )
                else ...[
                  DropdownButton<int?>(
                    isExpanded: true,
                    value: _pickedCatalogId,
                    hint: Text(l.parkCatalogDropdownHint),
                    items: [
                      for (final row in _templates)
                        DropdownMenuItem<int?>(
                          value: _parseInt(row['id']),
                          child: Text(
                            '${_mfgName(row)} · ${row['name']?.toString() ?? ''} (${row['model']?.toString() ?? ''})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _loading || !online
                        ? null
                        : (v) => setState(() => _pickedCatalogId = v),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _sector,
                    decoration: InputDecoration(
                      labelText: l.parkFieldSectorOptional,
                      hintText: l.parkFieldSectorHintExample,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading || !online ? null : _addUnit,
                    child: Text(l.parkBtnRegisterUnit),
                  ),
                ],
                const SizedBox(height: 28),
                Text(l.parkUnitsCount(_units.length), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (_units.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.parkEmptyPark, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .findAncestorStateOfType<_InstructorShellState>()
                                  ?.navigateInShell('/institution/pedidos');
                            },
                            icon: const Icon(Icons.playlist_add_check_rounded, size: 20),
                            label: Text(l.shellNavTrainingRequests),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._units.map((row) {
                    final id = _parseInt(row['id']);
                    final catalogId = _parseInt(row['catalog_equipment_id']);
                    final hasCatalogImg = row['catalog_has_image'] == true;
                    final st = row['status']?.toString() ?? '';
                    final pending = st == 'pending';
                    final catRaw = row['category']?.toString();
                    final catPrefix =
                        (catRaw != null && catRaw.isNotEmpty) ? '${_categoryLabel(catRaw)} · ' : '';
                    final ct = row['catalog_template'];
                    String subtitle = row['model']?.toString() ?? '';
                    if (ct is Map) {
                      final mm = ct['manufacturer'];
                      if (mm is Map && mm['name'] != null) {
                        subtitle = '${mm['name']} · $subtitle';
                      }
                    }
                    return instructorShellCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: catalogId == null
                            ? const CircleAvatar(
                                backgroundColor: Color(0xFFE2E8F0),
                                child: Icon(
                                  Icons.precision_manufacturing_outlined,
                                  color: Color(0xFF475569),
                                ),
                              )
                            : _InstitutionCatalogThumb(
                                api: widget.api,
                                catalogEquipmentId: catalogId,
                                hasImage: hasCatalogImg,
                              ),
                        title: Text(row['name']?.toString() ?? l.parkEquipmentFallbackName),
                        subtitle: Text(
                          '$catPrefix${row['sector']?.toString().isNotEmpty == true ? '${row['sector']} · ' : ''}$subtitle · ${localizedParkEquipmentStatus(l, st)}',
                        ),
                        trailing: id == null
                            ? null
                            : Wrap(
                                spacing: 4,
                                children: [
                                  if (pending)
                                    TextButton(
                                      onPressed: _loading || !online ? null : () => _activate(id),
                                      child: Text(l.parkBtnActivate),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: _loading || !online ? null : () => _remove(id),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
              ],
            ),
      ),
    );
  }
}

/// Miniatura do modelo de catálogo (imagem enviada pelo fabricante).
class _InstitutionCatalogThumb extends StatefulWidget {
  const _InstitutionCatalogThumb({
    required this.api,
    required this.catalogEquipmentId,
    required this.hasImage,
  });

  final ProductionApi api;
  final int catalogEquipmentId;
  final bool hasImage;

  @override
  State<_InstitutionCatalogThumb> createState() => _InstitutionCatalogThumbState();
}

class _InstitutionCatalogThumbState extends State<_InstitutionCatalogThumb> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    if (widget.hasImage) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final t = appAuth.token;
    if (t == null || !mounted) return;
    try {
      final b = await widget.api.downloadInstitutionCatalogEquipmentImage(t, widget.catalogEquipmentId);
      if (mounted) setState(() => _bytes = b);
    } catch (_) {
      // Mantém ícone.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ColoredBox(
        color: const Color(0xFFE2E8F0),
        child: SizedBox(
          width: 40,
          height: 40,
          child: _bytes != null
              ? Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true)
              : Icon(
                  widget.hasImage ? Icons.broken_image_outlined : Icons.precision_manufacturing_outlined,
                  color: const Color(0xFF475569),
                  size: 22,
                ),
        ),
      ),
    );
  }
}

class _InstitutionEndorsementsPage extends StatefulWidget {
  const _InstitutionEndorsementsPage({required this.api});

  final ProductionApi api;

  @override
  State<_InstitutionEndorsementsPage> createState() => _InstitutionEndorsementsPageState();
}

class _InstitutionEndorsementsPageState extends State<_InstitutionEndorsementsPage> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  final Set<int> _endorsing = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  /// [silent] evita substituir o ecrã pelo loading (ex.: pull na lista já carregada).
  Future<void> _reload({bool silent = false}) async {
    final t = appAuth.token;
    if (t == null) {
      return;
    }
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _error = null);
    }
    try {
      final r = await widget.api.institutionManufacturerEndorsementQueue(t);
      if (mounted) {
        setState(() {
          _rows = r;
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).trainReqLoadFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _endorse(int id) async {
    final t = appAuth.token;
    if (t == null) {
      return;
    }
    setState(() => _endorsing.add(id));
    try {
      await widget.api.institutionManufacturerEndorse(t, id);
      await _reload(silent: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).endorsSnackRecorded)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) {
        setState(() => _endorsing.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    if (_gestorNeedsInstitutionLink()) {
      return instructorShellScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l.trainReqUseOrangeBanner,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF45464D)),
            ),
          ),
        ),
      );
    }
    if (_loading) {
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _reload(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          },
        ),
      );
    }
    if (_error != null) {
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _reload(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: () => _reload(), child: Text(l.actionRetry)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: () => _reload(silent: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.shellTitleEndorsements, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              l.endorsIntro,
              style: const TextStyle(color: Color(0xFF45464D)),
            ),
            const SizedBox(height: 18),
            if (!online) ...[
              _instrOfflineBanner(l),
              const SizedBox(height: 16),
            ],
            if (_rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.endorsEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF45464D)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            context
                                .findAncestorStateOfType<_InstructorShellState>()
                                ?.navigateInShell('/institution/parque');
                          },
                          icon: const Icon(Icons.precision_manufacturing_outlined, size: 20),
                          label: Text(l.shellNavTechPark),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              for (final row in _rows)
                Builder(
                  builder: (context) {
                    final rowId = _parseInt(row['id']);
                    final busy = rowId != null && _endorsing.contains(rowId);
                    final mfgName = row['manufacturer'] is Map
                        ? (row['manufacturer']['name']?.toString() ?? l.endorsManufacturerFallback)
                        : l.endorsManufacturerFallback;
                    final instName = row['instructor'] is Map
                        ? (row['instructor']['name']?.toString() ?? l.trainReqDashNone)
                        : l.trainReqDashNone;
                    return instructorShellCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mfgName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l.endorsInstructorLine(instName),
                              style: const TextStyle(color: Color(0xFF45464D)),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: online
                                  ? FilledButton(
                                      onPressed: rowId == null || busy ? null : () => _endorse(rowId),
                                      child: busy
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : Text(l.endorsBtnEndorse),
                                    )
                                  : Tooltip(
                                      message: l.instrOfflineHint,
                                      child: FilledButton(
                                        onPressed: null,
                                        child: Text(l.endorsBtnEndorse),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _TrainingRequestsKanban extends StatelessWidget {
  const _TrainingRequestsKanban({
    required this.colQueue,
    required this.colScheduled,
    required this.colClosed,
    required this.instructors,
    required this.trainings,
    required this.onSubmit,
    required this.wide,
    required this.batchSelectedIds,
    required this.onBatchToggle,
    required this.apiOnline,
  });

  final List<Map<String, dynamic>> colQueue;
  final List<Map<String, dynamic>> colScheduled;
  final List<Map<String, dynamic>> colClosed;
  final List<Map<String, dynamic>> instructors;
  final List<Map<String, dynamic>> trainings;
  final Future<void> Function(int id, Map<String, dynamic> body) onSubmit;
  final bool wide;
  final Set<int> batchSelectedIds;
  final ValueChanged<int>? onBatchToggle;
  final bool apiOnline;

  Widget _column({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> rows,
    bool isBatchColumn = false,
  }) {
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.25)),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            '${rows.length}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF334155)),
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 14),
          ...rows.map((row) {
            final rid = _parseInt(row['id']);
            return _InstitutionPedidoCard(
              key: ValueKey(row['id']),
              row: row,
              instructors: instructors,
              trainings: trainings,
              onSubmit: onSubmit,
              apiOnline: apiOnline,
              batchSelectable: isBatchColumn && onBatchToggle != null,
              batchSelected: rid != null && batchSelectedIds.contains(rid),
              onBatchToggle: (isBatchColumn && onBatchToggle != null && rid != null) ? () => onBatchToggle!(rid) : null,
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c1 = _column(
      title: l.trainReqKanbanColumnQueue,
      subtitle: l.trainReqKanbanColumnQueueHint,
      rows: colQueue,
      isBatchColumn: true,
    );
    final c2 = _column(
      title: l.trainReqKanbanColumnScheduled,
      subtitle: l.trainReqKanbanColumnScheduledHint,
      rows: colScheduled,
    );
    final c3 = _column(
      title: l.trainReqKanbanColumnClosed,
      subtitle: l.trainReqKanbanColumnClosedHint,
      rows: colClosed,
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: c1),
          const SizedBox(width: 14),
          Expanded(child: c2),
          const SizedBox(width: 14),
          Expanded(child: c3),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        c1,
        const SizedBox(height: 14),
        c2,
        const SizedBox(height: 14),
        c3,
      ],
    );
  }
}

class _InstitutionPedidosPage extends StatefulWidget {
  const _InstitutionPedidosPage({required this.api});

  final ProductionApi api;

  @override
  State<_InstitutionPedidosPage> createState() => _InstitutionPedidosPageState();
}

class _InstitutionPedidosPageState extends State<_InstitutionPedidosPage> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _trainings = [];
  final Set<int> _batchIds = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  /// [silent] evita substituir o ecrã pelo loading (ex.: pull no Kanban).
  Future<void> _reload({bool silent = false}) async {
    final t = appAuth.token;
    if (t == null) {
      return;
    }
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _error = null);
    }
    try {
      final r = await widget.api.institutionTrainingRequests(t);
      final i = await widget.api.institutionApprovedInstructors(t);
      final tr = await widget.api.institutionMyTrainings(t);
      if (mounted) {
        setState(() {
          _requests = r;
          _instructors = i;
          _trainings = tr;
          _batchIds.removeWhere((id) => !r.any((row) => _parseInt(row['id']) == id));
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).trainReqLoadFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _update(int requestId, Map<String, dynamic> body, {bool quiet = false}) async {
    final t = appAuth.token;
    if (t == null) {
      return;
    }
    try {
      await widget.api.updateInstitutionTrainingRequest(t, requestId, body);
      await _reload(silent: true);
      if (mounted && !quiet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).trainReqSnackUpdated)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    }
  }

  Future<void> _showBatchScheduleDialog() async {
    final l = AppLocalizations.of(context);
    final eligibleIds = <int>[];
    for (final r in _requests) {
      final id = _parseInt(r['id']);
      final st = r['status']?.toString() ?? '';
      if (id != null && _batchIds.contains(id) && (st == 'pending' || st == 'approved')) {
        eligibleIds.add(id);
      }
    }
    if (eligibleIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trainReqBatchSnackNoneEligible)));
      }
      return;
    }
    if (_instructors.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trainReqBatchNoInstructors)));
      }
      return;
    }

    int? pickedInstructor = _instructors.length == 1 ? _parseInt(_instructors.first['id']) : null;
    int? pickedTraining;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(l.trainReqBatchDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.trainReqBatchDialogBody(eligibleIds.length)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      key: ValueKey<String>('batch_inst_${pickedInstructor ?? 'n'}'),
                      decoration: InputDecoration(labelText: l.trainReqFieldAssignedInstructor),
                      initialValue: pickedInstructor,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(l.trainReqBatchSelectInstructorPlaceholder),
                        ),
                        for (final u in _instructors)
                          DropdownMenuItem<int?>(
                            value: _parseInt(u['id']),
                            child: Text(u['name']?.toString() ?? ''),
                          ),
                      ],
                      onChanged: (v) => setLocal(() => pickedInstructor = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      key: ValueKey<String>('batch_tr_${pickedTraining ?? 'n'}'),
                      decoration: InputDecoration(labelText: l.trainReqFieldFulfilledTraining),
                      initialValue: pickedTraining,
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text(l.trainReqDashNone)),
                        for (final t in _trainings)
                          DropdownMenuItem<int?>(
                            value: _parseInt(t['id']),
                            child: Text(
                              '${t['title'] ?? ''} (#${t['id']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setLocal(() => pickedTraining = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mfgBtnCancel)),
                FilledButton(
                  onPressed: pickedInstructor == null ? null : () => Navigator.pop(ctx, true),
                  child: Text(l.trainReqBatchConfirm),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    for (final id in eligibleIds) {
      await _update(
        id,
        {
          'status': 'scheduled',
          'assigned_instructor_id': pickedInstructor,
          ...?pickedTraining != null ? {'fulfilled_training_id': pickedTraining} : null,
        },
        quiet: true,
      );
    }

    if (!mounted) return;
    setState(() => _batchIds.clear());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.trainReqBatchSnackDone(eligibleIds.length))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_gestorNeedsInstitutionLink()) {
      return instructorShellScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l.trainReqUseOrangeBanner,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF45464D)),
            ),
          ),
        ),
      );
    }
    if (_loading) {
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _reload(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          },
        ),
      );
    }
    if (_error != null) {
      return instructorShellScaffold(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () => _reload(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: () => _reload(), child: Text(l.actionRetry)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    List<Map<String, dynamic>> byStatuses(Set<String> statuses) {
      return _requests.where((r) => statuses.contains(r['status']?.toString() ?? 'pending')).toList();
    }

    var colQueue = byStatuses({'pending', 'approved'});
    final colScheduled = byStatuses({'scheduled'});
    final colClosed = byStatuses({'fulfilled', 'rejected'});
    final assigned = <dynamic>{
      for (final r in [...colQueue, ...colScheduled, ...colClosed]) r['id'],
    };
    final orphans = _requests.where((r) => !assigned.contains(r['id'])).toList();
    if (orphans.isNotEmpty) {
      colQueue = [...colQueue, ...orphans];
    }

    final online = _InstructorApiReachability.apiOnlineOf(context);
    Widget wrapOff(Widget child) => online ? child : Tooltip(message: l.instrOfflineHint, child: child);

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: () => _reload(silent: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.shellTitleTrainingRequests, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    l.trainReqIntro,
                    style: const TextStyle(color: Color(0xFF45464D)),
                  ),
                  const SizedBox(height: 18),
                  if (!online) ...[
                    _instrOfflineBanner(l),
                    const SizedBox(height: 16),
                  ],
                  if (_requests.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            children: [
                              Text(
                                l.trainReqEmpty,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      context
                                          .findAncestorStateOfType<_InstructorShellState>()
                                          ?.navigateInShell('/institution/parque');
                                    },
                                    icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                                    label: Text(l.shellNavTechPark),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      context
                                          .findAncestorStateOfType<_InstructorShellState>()
                                          ?.navigateInShell('/institution/endorsements');
                                    },
                                    icon: const Icon(Icons.verified_outlined, size: 18),
                                    label: Text(l.shellNavEndorsementsShort),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_batchIds.isNotEmpty) ...[
                    instructorShellCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.trainReqBatchToolbarSelected(_batchIds.length),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _batchIds.clear()),
                              child: Text(l.trainReqBatchToolbarClear),
                            ),
                            const SizedBox(width: 8),
                            wrapOff(
                              FilledButton(
                                onPressed: !online ? null : _showBatchScheduleDialog,
                                child: Text(l.trainReqBatchToolbarSchedule),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _TrainingRequestsKanban(
                    colQueue: colQueue,
                    colScheduled: colScheduled,
                    colClosed: colClosed,
                    instructors: _instructors,
                    trainings: _trainings,
                    onSubmit: _update,
                    wide: wide,
                    batchSelectedIds: _batchIds,
                    apiOnline: online,
                    onBatchToggle: (id) {
                      setState(() {
                        if (_batchIds.contains(id)) {
                          _batchIds.remove(id);
                        } else {
                          _batchIds.add(id);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InstitutionPedidoCard extends StatefulWidget {
  const _InstitutionPedidoCard({
    super.key,
    required this.row,
    required this.instructors,
    required this.trainings,
    required this.onSubmit,
    this.apiOnline = true,
    this.batchSelectable = false,
    this.batchSelected = false,
    this.onBatchToggle,
  });

  final Map<String, dynamic> row;
  final List<Map<String, dynamic>> instructors;
  final List<Map<String, dynamic>> trainings;
  final Future<void> Function(int id, Map<String, dynamic> body) onSubmit;
  final bool apiOnline;
  final bool batchSelectable;
  final bool batchSelected;
  final VoidCallback? onBatchToggle;

  @override
  State<_InstitutionPedidoCard> createState() => _InstitutionPedidoCardState();
}

class _InstitutionPedidoCardState extends State<_InstitutionPedidoCard> {
  late String _status;
  int? _instructorId;
  int? _trainingId;

  @override
  void initState() {
    super.initState();
    _syncFromRow();
  }

  @override
  void didUpdateWidget(covariant _InstitutionPedidoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row['id'] != widget.row['id']) {
      _syncFromRow();
    }
  }

  void _syncFromRow() {
    _status = widget.row['status']?.toString() ?? 'pending';
    _instructorId = _parseInt(widget.row['assigned_instructor_id']);
    _trainingId = _parseInt(widget.row['fulfilled_training_id']);
  }

  Future<void> _save() async {
    final id = _parseInt(widget.row['id']);
    if (id == null) {
      return;
    }
    await widget.onSubmit(id, {
      'status': _status,
      'assigned_instructor_id': _instructorId,
      'fulfilled_training_id': _trainingId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = widget.apiOnline;
    final req = widget.row['requester'] as Map?;
    final name = req?['name']?.toString() ?? l.trainReqDashNone;
    final email = req?['email']?.toString() ?? '';
    final ft = widget.row['fulfilled_training'] as Map?;

    return instructorShellCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.batchSelectable && widget.onBatchToggle != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: widget.batchSelected,
                    onChanged: (_) => widget.onBatchToggle!(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        l.trainReqBatchCheckboxLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            if (widget.row['reason_label'] != null && widget.row['reason_label'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.trainReqReasonLine(widget.row['reason_label']), style: const TextStyle(fontSize: 13)),
            ] else if (widget.row['reason'] != null && widget.row['reason'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l.trainReqReasonLine(widget.row['reason']), style: const TextStyle(fontSize: 13)),
            ],
            if (widget.row['priority_label'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.trainReqPriorityLine(widget.row['priority_label']), style: const TextStyle(fontSize: 13)),
              ),
            if (widget.row['equipment'] is Map) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  () {
                    final e = widget.row['equipment'] as Map;
                    final n = e['name']?.toString() ?? '';
                    final m = e['model']?.toString() ?? '';
                    final mf = e['catalog_template'];
                    String tail = m;
                    if (mf is Map) {
                      final mm = mf['manufacturer'];
                      if (mm is Map && mm['name'] != null) {
                        tail = '${mm['name']} · $m';
                      }
                    }
                    return l.trainReqParkLine(n, tail);
                  }(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF00677D)),
                ),
              ),
            ],
            if (widget.row['desired_date'] != null || widget.row['latest_acceptable_date'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.trainReqPreferredDates(
                    widget.row['desired_date']?.toString() ?? l.trainReqDashNone,
                    widget.row['latest_acceptable_date']?.toString() ?? l.trainReqDashNone,
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
                ),
              ),
            if (widget.row['notes'] != null && widget.row['notes'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.trainReqNotesLine(widget.row['notes']), style: const TextStyle(fontSize: 13)),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey<String>('tr_req_${widget.row['id']}_st_$_status'),
              decoration: InputDecoration(labelText: l.trainReqFieldStatus),
              initialValue: _status,
              items: [
                DropdownMenuItem(value: 'pending', child: Text(l.trainReqStatusPending)),
                DropdownMenuItem(value: 'approved', child: Text(l.trainReqStatusApproved)),
                DropdownMenuItem(value: 'scheduled', child: Text(l.trainReqStatusScheduled)),
                DropdownMenuItem(value: 'rejected', child: Text(l.trainReqStatusRejected)),
                DropdownMenuItem(value: 'fulfilled', child: Text(l.trainReqStatusFulfilled)),
              ],
              onChanged: !online
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() => _status = v);
                      }
                    },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              key: ValueKey<String>('tr_req_${widget.row['id']}_ins_${_instructorId ?? 'n'}'),
              decoration: InputDecoration(labelText: l.trainReqFieldAssignedInstructor),
              initialValue: _instructorId,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l.trainReqDashNone)),
                for (final u in widget.instructors)
                  DropdownMenuItem<int?>(
                    value: _parseInt(u['id']),
                    child: Text(u['name']?.toString() ?? ''),
                  ),
              ],
              onChanged: !online ? null : (v) => setState(() => _instructorId = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              key: ValueKey<String>('tr_req_${widget.row['id']}_trn_${_trainingId ?? 'n'}'),
              decoration: InputDecoration(labelText: l.trainReqFieldFulfilledTraining),
              initialValue: _trainingId,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l.trainReqDashNone)),
                for (final t in widget.trainings)
                  DropdownMenuItem<int?>(
                    value: _parseInt(t['id']),
                    child: Text(
                      '${t['title'] ?? ''} (#${t['id']})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: !online ? null : (v) => setState(() => _trainingId = v),
            ),
            if (ft != null) ...[
              const SizedBox(height: 8),
              Text(
                l.trainReqLinkedTraining(
                  ft['title'] ?? '',
                  ft['join_hash']?.toString() ?? l.trainReqDashNone,
                ),
                style: const TextStyle(fontSize: 12, color: Color(0xFF00677D)),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: online
                  ? FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D)),
                      child: Text(l.trainReqBtnSaveChanges),
                    )
                  : Tooltip(
                      message: l.instrOfflineHint,
                      child: FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D)),
                        child: Text(l.trainReqBtnSaveChanges),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComandoPage extends StatefulWidget {
  const _ComandoPage({required this.api});

  final ProductionApi api;

  @override
  State<_ComandoPage> createState() => _ComandoPageState();
}

class _ComandoPageState extends State<_ComandoPage> {
  List<Map<String, dynamic>> _trainings = [];
  int? _selectedId;
  Map<String, dynamic>? _monitor;
  bool _loading = false;
  Timer? _timer;
  final Set<int> _repescageIds = {};
  List<Map<String, dynamic>> _trainingBlocks = [];
  int? _repescageBlockId;
  TrainingReverbListener? _reverbListener;
  int? _reverbTrainingId;
  int? _lastSignalSeq;
  TrainingRealtimeLinkPhase _rtPhase = TrainingRealtimeLinkPhase.httpOnly;
  final TextEditingController _participantSearchCtrl = TextEditingController();
  Timer? _participantSearchDebounce;
  String _participantSearchApplied = '';

  @override
  void initState() {
    super.initState();
    _refreshTrainings().then((_) => _restartPollingAndReverb());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _participantSearchDebounce?.cancel();
    _participantSearchCtrl.dispose();
    unawaited(_disconnectTrainingReverb());
    super.dispose();
  }

  void _scheduleParticipantSearchApplied() {
    _participantSearchDebounce?.cancel();
    _participantSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      var t = _participantSearchCtrl.text.trim();
      if (t.length > 120) t = t.substring(0, 120);
      setState(() => _participantSearchApplied = t);
    });
  }

  Future<void> _disconnectTrainingReverb() async {
    _reverbTrainingId = null;
    _lastSignalSeq = null;
    if (mounted) {
      setState(() => _rtPhase = TrainingRealtimeLinkPhase.httpOnly);
    }
    final l = _reverbListener;
    _reverbListener = null;
    await l?.dispose();
  }

  void _restartPollingAndReverb() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _loadMonitor());
    unawaited(_attachTrainingReverb());
  }

  Future<void> _attachTrainingReverb() async {
    final id = _selectedId;
    if (id == null) {
      await _disconnectTrainingReverb();
      return;
    }
    if (_reverbTrainingId == id && _reverbListener != null) {
      return;
    }

    await _disconnectTrainingReverb();
    if (!mounted) {
      return;
    }

    Map<String, dynamic> cfg;
    try {
      cfg = await widget.api.realtimeClientConfig();
    } catch (_) {
      return;
    }
    if (cfg['enabled'] != true) {
      return;
    }
    final raw = cfg['reverb'];
    if (raw is! Map) {
      return;
    }
    final r = Map<String, dynamic>.from(raw);
    final key = r['key']?.toString() ?? '';
    if (key.isEmpty) {
      return;
    }
    final host = r['host']?.toString() ?? '127.0.0.1';
    final port = r['port'] is int ? r['port'] as int : int.tryParse(r['port']?.toString() ?? '') ?? 8080;
    final useTls = r['use_tls'] == true;

    final listener = TrainingReverbListener(
      onSeq: (seq) {
        if (!mounted || _selectedId != id) {
          return;
        }
        if (_lastSignalSeq == seq) {
          return;
        }
        _lastSignalSeq = seq;
        _loadMonitor();
      },
      connectionErrorHandler: (dynamic e, StackTrace st, void Function() refresh) {
        refresh();
      },
      onLifecycle: (phase) {
        if (mounted) {
          setState(() => _rtPhase = phase);
        }
      },
    );

    try {
      await listener.connect(
        key: key,
        host: host,
        port: port,
        useTls: useTls,
        trainingId: id,
      );
    } catch (_) {
      await listener.dispose();
      return;
    }

    if (!mounted || _selectedId != id) {
      await listener.dispose();
      return;
    }

    _reverbTrainingId = id;
    _reverbListener = listener;
  }

  Future<void> _refreshTrainings() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.myTrainings(t);
      if (mounted) {
        setState(() {
          _trainings = list;
          if (_selectedId == null && list.isNotEmpty) {
            _selectedId = _parseInt(list.first['id']);
          }
        });
        await _loadMonitor();
      }
    } catch (_) {}
  }

  Future<void> _loadMonitor() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    try {
      final m = await widget.api.trainingParticipants(t, id);
      if (mounted) {
        final tr = m['training'];
        if (tr is Map) {
          final s = tr['command_seq'];
          final seq = s is int ? s : int.tryParse(s?.toString() ?? '');
          if (seq != null) {
            _lastSignalSeq = seq;
          }
        }
        final bl = m['training_blocks'];
        final blocks = bl is List
            ? bl.map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : <Map<String, dynamic>>[];
        setState(() {
          _monitor = m;
          _trainingBlocks = blocks;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _monitor = null);
    }
  }

  Future<void> _releaseNextBlock() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.realtimeTrainingCommand(t, id, action: 'release_block');
      await _loadMonitor();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).comandoSnackBlockReleased)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _runSessionSignal(String action) async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.realtimeTrainingCommand(t, id, action: action);
      await _loadMonitor();
      if (mounted) {
        final l = AppLocalizations.of(context);
        final msg = action == 'pause' ? l.comandoSessionPaused : l.comandoSessionResumed;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setTrainingStatus(String status) async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.updateTraining(t, id, {'status': status});
      await _loadMonitor();
      await _refreshTrainings();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.comandoStatusUpdate(localizedTrainingLifecycleStatus(loc, status)))),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (int, int) _participantCounts(List<dynamic> participants) {
    var a = 0;
    var w = 0;
    for (final raw in participants) {
      final row = Map<String, dynamic>.from(raw as Map);
      final st = row['enrollment']?['status']?.toString();
      if (st == 'waiting') {
        w++;
      } else {
        a++;
      }
    }
    return (a, w);
  }

  double _avgBlockCompletionPercent(List<dynamic> participants, int blockId) {
    var sum = 0.0;
    var n = 0;
    for (final raw in participants) {
      final row = Map<String, dynamic>.from(raw as Map);
      final bm = row['block_metrics'];
      if (bm is! List) continue;
      for (final m in bm) {
        if (m is! Map) continue;
        if (_parseInt(m['training_block_id']) != blockId) continue;
        final total = _parseInt(m['question_count']) ?? 0;
        if (total <= 0) continue;
        final correct = (m['correct_count'] as num? ?? 0).toDouble();
        final wrong = (m['wrong_count'] as num? ?? 0).toDouble();
        sum += (correct + wrong) / total;
        n++;
        break;
      }
    }
    return n == 0 ? 0 : sum / n * 100;
  }

  double? _avgBlockAccuracyPercent(List<dynamic> participants, int blockId) {
    var sum = 0.0;
    var n = 0;
    for (final raw in participants) {
      final row = Map<String, dynamic>.from(raw as Map);
      final bm = row['block_metrics'];
      if (bm is! List) continue;
      for (final m in bm) {
        if (m is! Map) continue;
        if (_parseInt(m['training_block_id']) != blockId) continue;
        final acc = m['accuracy_percent'];
        if (acc is num) {
          sum += acc.toDouble();
          n++;
        }
        break;
      }
    }
    return n == 0 ? null : sum / n;
  }

  String _deckLifecycleBadge(AppLocalizations l, Map<String, dynamic>? training, bool sessionPaused) {
    if (training == null) return l.comandoDeckBadgeScheduled;
    if (sessionPaused) return l.comandoDeckBadgePaused;
    switch (training['status']?.toString()) {
      case 'in_progress':
        return l.comandoDeckBadgeRunning;
      case 'scheduled':
        return l.comandoDeckBadgeScheduled;
      case 'finished':
        return l.comandoDeckBadgeFinished;
      default:
        return localizedTrainingLifecycleStatus(l, training['status']?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    final participants = (_monitor?['participants'] as List<dynamic>?) ?? [];
    final training = _monitor?['training'] as Map<String, dynamic>?;
    final sessionPaused = training != null && training['session_paused'] == true;
    final moduleTitle = training?['title']?.toString() ?? l.trainReqDashNone;
    final counts = _participantCounts(participants);
    final activeCt = counts.$1;
    final waitingCt = counts.$2;
    final searchQ = _participantSearchApplied.toLowerCase();
    final filteredParticipants = searchQ.isEmpty
        ? participants
        : participants.where((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            final u = row['user'] as Map<String, dynamic>?;
            final name = u?['name']?.toString().toLowerCase() ?? '';
            final email = u?['email']?.toString().toLowerCase() ?? '';
            return name.contains(searchQ) || email.contains(searchQ);
          }).toList();
    final sortedBlocks = List<Map<String, dynamic>>.from(_trainingBlocks);
    sortedBlocks.sort((a, b) => (_parseInt(a['sort_order']) ?? 0).compareTo(_parseInt(b['sort_order']) ?? 0));
    final deckBadge = _deckLifecycleBadge(l, training, sessionPaused);

    Widget statPill(String label, String value) {
      return SizedBox(
        width: 148,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ClinicalPrecisionColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.45)),
            boxShadow: ClinicalPrecisionShadows.ambientCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: ClinicalPrecisionColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ClinicalPrecisionColors.onSurface)),
            ],
          ),
        ),
      );
    }

    final liveBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFDC2626)),
          ),
          const SizedBox(width: 6),
          Text(
            _selectedId != null ? '${l.comandoHeroLiveBadge} · #$_selectedId' : l.comandoHeroLiveBadge,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
          ),
        ],
      ),
    );

    Widget participantsCard(double listPullMinH) {
      return instructorShellCard(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.comandoParticipantsTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ClinicalPrecisionColors.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _participantSearchCtrl,
                onChanged: (_) => _scheduleParticipantSearchApplied(),
                decoration: InputDecoration(
                  hintText: l.comandoParticipantsSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: ClinicalPrecisionColors.surfaceContainerLowest,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshTrainings,
                  child: participants.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: listPullMinH,
                              child: Center(
                                child: Text(l.comandoNoParticipants, style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant)),
                              ),
                            ),
                          ],
                        )
                      : filteredParticipants.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: listPullMinH,
                                  child: Center(
                                    child: Text(
                                      l.comandoParticipantsNoMatch,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredParticipants.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final raw = filteredParticipants[index];
                                final row = Map<String, dynamic>.from(raw as Map);
                                final eid = _parseInt(row['enrollment']?['id']);
                                return _ParticipantTile(
                                  row,
                                  apiOnline: online,
                                  selected: eid != null && _repescageIds.contains(eid),
                                  onToggle: (enrollmentId) {
                                    setState(() {
                                      if (_repescageIds.contains(enrollmentId)) {
                                        _repescageIds.remove(enrollmentId);
                                      } else {
                                        _repescageIds.add(enrollmentId);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget offlineHintWrap(Widget child) => online ? child : Tooltip(message: l.comandoOfflineHint, child: child);

    Widget controlDeck() {
      return instructorShellCard(
        color: ClinicalPrecisionColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l.comandoSessionControlTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(deckBadge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l.comandoDeckSubtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ComandoDeckTile(
                      icon: Icons.play_arrow_rounded,
                      label: l.comandoBtnStart,
                      enabled: !_loading && online,
                      disabledHint: online ? null : l.comandoOfflineHint,
                      onTap: () => _setTrainingStatus('in_progress'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ComandoDeckTile(
                      icon: Icons.pause_rounded,
                      label: l.comandoBtnPause,
                      enabled: !_loading && _selectedId != null && !sessionPaused && online,
                      disabledHint: online ? null : l.comandoOfflineHint,
                      onTap: () => _runSessionSignal('pause'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ComandoDeckTile(
                      icon: Icons.stop_rounded,
                      label: l.comandoBtnClose,
                      enabled: !_loading && online,
                      disabledHint: online ? null : l.comandoOfflineHint,
                      onTap: () => _setTrainingStatus('finished'),
                    ),
                  ),
                ],
              ),
              if (sessionPaused) ...[
                const SizedBox(height: 10),
                offlineHintWrap(
                  FilledButton(
                    onPressed: _loading || _selectedId == null || !online ? null : () => _runSessionSignal('resume'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ClinicalPrecisionColors.secondary,
                      foregroundColor: ClinicalPrecisionColors.onSecondary,
                    ),
                    child: Text(l.comandoBtnResume),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              offlineHintWrap(
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                  ),
                  onPressed: _loading || !online ? null : () => _setTrainingStatus('scheduled'),
                  child: Text(l.comandoBtnReschedule),
                ),
              ),
              const SizedBox(height: 14),
              offlineHintWrap(
                FilledButton(
                  onPressed: _loading || !online ? null : _releaseNextBlock,
                  style: FilledButton.styleFrom(
                    backgroundColor: ClinicalPrecisionColors.secondary,
                    foregroundColor: ClinicalPrecisionColors.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l.comandoBtnReleaseBlock),
                ),
              ),
              if (_trainingBlocks.isNotEmpty) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<int?>(
                  key: ValueKey<String>('repesc_${_repescageBlockId ?? 'all'}'),
                  decoration: InputDecoration(
                    labelText: l.comandoRepescageScope,
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  initialValue: _repescageBlockId,
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l.comandoRepescageScopeAll, style: const TextStyle(color: Colors.white)),
                    ),
                    for (final b in _trainingBlocks)
                      DropdownMenuItem<int?>(
                        value: _parseInt(b['id']),
                        child: Text(
                          b['title']?.toString() ?? l.comandoBlockDefault,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _repescageBlockId = v),
                ),
              ],
              const SizedBox(height: 8),
              offlineHintWrap(
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade200,
                    side: BorderSide(color: Colors.amber.withValues(alpha: 0.65)),
                  ),
                  onPressed: _loading || _repescageIds.isEmpty || !online ? null : _runRepescage,
                  child: Text(l.comandoRepescageCount(_repescageIds.length)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l.comandoHelpFooter,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), height: 1.45, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    Widget progressCard() {
      return instructorShellCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.comandoProgressByBlockTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ClinicalPrecisionColors.onSurface),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: sortedBlocks.isEmpty
                    ? Center(child: Text(l.trainReqDashNone, style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant)))
                    : SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: ClinicalPrecisionColors.outlineVariant)),
                              ),
                              children: [
                                _ComandoTableHeaderCell(l.comandoColBlockTitle),
                                _ComandoTableHeaderCell(l.comandoColState),
                                _ComandoTableHeaderCell(l.comandoColCompletion),
                                _ComandoTableHeaderCell(l.comandoColAccuracy),
                              ],
                            ),
                            for (final b in sortedBlocks)
                              TableRow(
                                children: [
                                  _ComandoTableDataCell(b['title']?.toString() ?? l.comandoBlockDefault),
                                  _ComandoTableDataCell(
                                    b['is_released'] == true ? l.comandoBlockStateReleased : l.comandoBlockStatePending,
                                    emphasize: true,
                                  ),
                                  _ComandoTableDataCell(
                                    '${_avgBlockCompletionPercent(participants, _parseInt(b['id']) ?? 0).toStringAsFixed(0)}%',
                                  ),
                                  _ComandoTableDataCell(() {
                                    final acc = _avgBlockAccuracyPercent(participants, _parseInt(b['id']) ?? 0);
                                    return acc == null ? l.trainReqDashNone : '${acc.toStringAsFixed(1)}%';
                                  }()),
                                ],
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 960;
        final listPullMinH = math.max(160.0, constraints.maxHeight * 0.22);
        final stack = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: participantsCard(listPullMinH)),
            const SizedBox(height: 16),
            Expanded(flex: 5, child: controlDeck()),
            const SizedBox(height: 16),
            Expanded(flex: 5, child: progressCard()),
          ],
        );
        final row = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: participantsCard(listPullMinH)),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 52, child: controlDeck()),
                  const SizedBox(height: 16),
                  Expanded(flex: 48, child: progressCard()),
                ],
              ),
            ),
          ],
        );
        return narrow ? stack : row;
      },
    );

    return instructorShellScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey<int?>(_selectedId),
                    decoration: InputDecoration(
                      labelText: l.comandoActiveTraining,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: ClinicalPrecisionColors.surfaceContainerLowest,
                    ),
                    initialValue: _selectedId,
                    items: [
                      for (final tr in _trainings)
                        DropdownMenuItem(
                          value: _parseInt(tr['id']),
                          child: Text(tr['title']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedId = v;
                        _repescageIds.clear();
                        _repescageBlockId = null;
                        _participantSearchDebounce?.cancel();
                        _participantSearchCtrl.clear();
                        _participantSearchApplied = '';
                      });
                      _restartPollingAndReverb();
                      _loadMonitor();
                    },
                  ),
                ),
                IconButton(onPressed: _refreshTrainings, icon: const Icon(Icons.refresh_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            if (!online) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Color(0xFFB91C1C), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.comandoOfflineHint,
                          style: const TextStyle(fontSize: 13.5, height: 1.4, color: Color(0xFF7F1D1D)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    liveBadge,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.comandoHeroTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ClinicalPrecisionColors.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l.comandoHeroModulePrefix} $moduleTitle',
                  style: const TextStyle(fontSize: 14, color: ClinicalPrecisionColors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    statPill(l.comandoStatDurationLabel, l.comandoDurationPlaceholder),
                    statPill(
                      l.comandoStatParticipantsLabel,
                      searchQ.isEmpty ? '${participants.length}' : '${filteredParticipants.length}/${participants.length}',
                    ),
                    statPill(l.comandoStatActiveShort, '$activeCt'),
                    statPill(l.comandoStatWaitingShort, '$waitingCt'),
                  ],
                ),
                if (_selectedId != null) ...[
                  const SizedBox(height: 12),
                  TrainingRealtimeLinkChip(phase: _rtPhase),
                ],
                if (training != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.comandoTrainingStatusHash(
                        localizedTrainingLifecycleStatus(l, training['status']?.toString()),
                        _joinHashDisplay(Map<String, dynamic>.from(training), l),
                      ),
                      style: const TextStyle(fontSize: 12, color: ClinicalPrecisionColors.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Future<void> _runRepescage() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null || _repescageIds.isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.api.realtimeTrainingCommand(
        t,
        id,
        action: 'repescage',
        payload: {
          'enrollment_ids': _repescageIds.toList(),
          if (_repescageBlockId != null) 'training_block_id': _repescageBlockId,
        },
      );
      setState(() => _repescageIds.clear());
      await _loadMonitor();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).comandoSnackRepescageDone)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ComandoDeckTile extends StatelessWidget {
  const _ComandoDeckTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.disabledHint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.04),
      borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.button),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.button),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: enabled ? Colors.white : Colors.white38, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? Colors.white.withValues(alpha: 0.92) : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!enabled && disabledHint != null && disabledHint!.isNotEmpty) {
      return Tooltip(message: disabledHint!, child: tile);
    }
    return tile;
  }
}

class _ComandoTableHeaderCell extends StatelessWidget {
  const _ComandoTableHeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: ClinicalPrecisionColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ComandoTableDataCell extends StatelessWidget {
  const _ComandoTableDataCell(this.text, {this.emphasize = false});

  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
          color: ClinicalPrecisionColors.onSurface,
        ),
      ),
    );
  }
}

class _BlockMetricChip extends StatelessWidget {
  const _BlockMetricChip(this.m);

  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = m['title']?.toString() ?? l.comandoBlockDefault;
    final acc = m['accuracy_percent'];
    final pct = acc is num ? '${acc.toStringAsFixed(1)}%' : '${acc ?? l.trainReqDashNone}%';
    final bad = m['below_50_percent'] == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bad ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bad ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$title · $pct',
        style: TextStyle(fontSize: 11, color: bad ? const Color(0xFF9A3412) : const Color(0xFF475569)),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile(
    this.row, {
    this.apiOnline = true,
    required this.selected,
    required this.onToggle,
    this.onCertificatePdf,
    this.certificatePdfLoadingForId,
    this.onIssueManualCertificate,
    this.issueCertificateBusy = false,
  });

  final Map<String, dynamic> row;
  final bool apiOnline;
  final bool selected;
  final ValueChanged<int> onToggle;
  final ValueChanged<Map<String, dynamic>>? onCertificatePdf;
  final int? certificatePdfLoadingForId;
  final VoidCallback? onIssueManualCertificate;
  final bool issueCertificateBusy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final u = row['user'] as Map<String, dynamic>?;
    final e = row['enrollment'] as Map<String, dynamic>?;
    final certRaw = row['certificate'];
    final cert = certRaw is Map ? Map<String, dynamic>.from(certRaw) : null;
    final certId = cert != null ? _parseInt(cert['id']) : null;
    final eid = _parseInt(e?['id']) ?? 0;
    final name = u?['name']?.toString() ?? l.trainReqDashNone;
    final answered = row['answered_count']?.toString() ?? '0';
    final total = row['question_count']?.toString() ?? '0';
    final score = e?['score']?.toString();
    final enrollmentStatusLabel = localizedEnrollmentStatus(l, e?['status']?.toString());
    final blockMetrics = row['block_metrics'];
    final st = e?['status']?.toString();
    final Color statusDot;
    switch (st) {
      case 'waiting':
        statusDot = const Color(0xFFF59E0B);
        break;
      case 'active':
        statusDot = const Color(0xFF22C55E);
        break;
      default:
        statusDot = ClinicalPrecisionColors.onSurfaceVariant;
    }
    final ti = int.tryParse(total) ?? 0;
    final ai = int.tryParse(answered) ?? 0;
    final progress = ti > 0 ? (ai / ti).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: ClinicalPrecisionColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: ClinicalPrecisionColors.surfaceContainer,
                  child: Text(
                    _participantInitials(name),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: ClinicalPrecisionColors.onSurface, fontSize: 14),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusDot,
                      border: Border.all(color: ClinicalPrecisionColors.surfaceContainerLowest, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ClinicalPrecisionColors.onSurface)),
                  const SizedBox(height: 6),
                  Align(alignment: Alignment.centerLeft, child: _postTrainingOutcomeChip(context, e)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: ClinicalPrecisionColors.surfaceContainer,
                      color: ClinicalPrecisionColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.comandoParticipantAnswers(answered, total, enrollmentStatusLabel),
                    style: const TextStyle(fontSize: 12, color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.3),
                  ),
                  if (blockMetrics is List && blockMetrics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final raw in blockMetrics)
                          if (raw is Map) _BlockMetricChip(Map<String, dynamic>.from(raw)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (eid > 0)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (score != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(score, style: const TextStyle(fontWeight: FontWeight.w800, color: ClinicalPrecisionColors.secondary)),
                    ),
                  if (onIssueManualCertificate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message: apiOnline ? l.postTrainingIssueCertificateTooltip : l.instrOfflineHint,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: (!apiOnline || issueCertificateBusy) ? null : onIssueManualCertificate,
                          child: issueCertificateBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  l.postTrainingIssueCertificate,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ),
                  if (certId != null && onCertificatePdf != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message: apiOnline ? l.postTrainingCertificatePdfTooltip : l.instrOfflineHint,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          onPressed: (!apiOnline || certificatePdfLoadingForId == certId) ? null : () => onCertificatePdf!(cert!),
                          icon: certificatePdfLoadingForId == certId
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFB91C1C)),
                        ),
                      ),
                    ),
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onToggle(eid),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CredenciamentoPage extends StatefulWidget {
  const _CredenciamentoPage({required this.api});

  final ProductionApi api;

  @override
  State<_CredenciamentoPage> createState() => _CredenciamentoPageState();
}

class _CredenciamentoPageState extends State<_CredenciamentoPage> {
  final _name = TextEditingController();
  final _cnpj = TextEditingController();
  List<Map<String, dynamic>> _list = [];
  List<Map<String, dynamic>> _manufacturers = [];
  Map<String, dynamic>? _credMine;
  List<Map<String, dynamic>> _instQueue = [];
  List<Map<String, dynamic>> _manuQueue = [];
  int? _applyInstitutionId;
  int? _applyManufacturerId;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _cnpj.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await widget.api.institutions(t);
      if (mounted) {
        setState(() {
          _list = list;
          _applyInstitutionId ??= list.isNotEmpty ? _parseInt(list.first['id']) : null;
        });
      }
      if (appAuth.role == 'instructor') {
        final m = await widget.api.manufacturersCatalog(t);
        final c = await widget.api.credentialsMine(t);
        if (mounted) {
          setState(() {
            _manufacturers = m;
            _credMine = c;
            _applyManufacturerId ??= m.isNotEmpty ? _parseInt(m.first['id']) : null;
          });
        }
      }
      if (appAuth.role == 'institution_admin') {
        final q = await widget.api.credentialInstitutionQueue(t);
        if (mounted) setState(() => _instQueue = q);
      }
      if (appAuth.role == 'manufacturer_admin') {
        final q = await widget.api.credentialManufacturerQueue(t);
        if (mounted) setState(() => _manuQueue = q);
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await widget.api.createInstitution(t, name: _name.text.trim(), cnpj: _cnpj.text.trim());
      _name.clear();
      _cnpj.clear();
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).credSnackInstitutionCreated)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final online = _InstructorApiReachability.apiOnlineOf(context);
    Widget wrapOff(Widget child) => online ? child : Tooltip(message: l.instrOfflineHint, child: child);

    return instructorShellScaffold(
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            if (!online) ...[
              _instrOfflineBanner(l),
              const SizedBox(height: 16),
            ],
            Text(l.credTitleInstitutions, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        Text(l.credIntroInstitutions, style: const TextStyle(color: Color(0xFF45464D))),
        const SizedBox(height: 18),
        instructorShellCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _name, decoration: InputDecoration(labelText: l.credFieldInstitutionName)),
                const SizedBox(height: 12),
                TextField(controller: _cnpj, decoration: InputDecoration(labelText: l.credFieldCnpjUnique)),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ],
                const SizedBox(height: 14),
                wrapOff(
                  FilledButton(
                    onPressed: _loading || !online ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF131B2E), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(l.credBtnRegisterInstitution),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(l.credListedCount(_list.length), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        instructorShellCard(
          child: Column(
            children: [
              for (final i in _list)
                ListTile(
                  title: Text(i['name']?.toString() ?? ''),
                  subtitle: Text(i['cnpj']?.toString() ?? ''),
                ),
            ],
          ),
        ),
        if (appAuth.role == 'instructor') ...[
          const SizedBox(height: 28),
          Text(l.credDoubleTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l.credDoubleIntro, style: const TextStyle(color: Color(0xFF45464D))),
          const SizedBox(height: 14),
          instructorShellCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: l.credApplyInstitutionLabel),
                    initialValue: _applyInstitutionId,
                    items: [
                      for (final i in _list)
                        DropdownMenuItem(value: _parseInt(i['id']), child: Text(i['name']?.toString() ?? '')),
                    ],
                    onChanged: !online ? null : (v) => setState(() => _applyInstitutionId = v),
                  ),
                  const SizedBox(height: 10),
                  wrapOff(
                    FilledButton(
                      onPressed: _loading || !online ? null : _applyInst,
                      child: Text(l.credBtnRequestInstitution),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: l.credApplyManufacturerLabel),
                    initialValue: _applyManufacturerId,
                    items: [
                      for (final m in _manufacturers)
                        DropdownMenuItem(value: _parseInt(m['id']), child: Text(m['name']?.toString() ?? '')),
                    ],
                    onChanged: !online ? null : (v) => setState(() => _applyManufacturerId = v),
                  ),
                  const SizedBox(height: 10),
                  wrapOff(
                    FilledButton(
                      onPressed: _loading || !online ? null : _applyManu,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D)),
                      child: Text(l.credBtnRequestManufacturer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_credMine != null) ...[
            const SizedBox(height: 12),
            Text(l.credMyLinksTitle, style: Theme.of(context).textTheme.titleMedium),
            instructorShellCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.credMyLinksInstitutionsHeader, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (((_credMine!['institutions'] as List<dynamic>?) ?? []).isEmpty)
                      Text(
                        l.credNoInstitutionalLink,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
                      )
                    else
                      for (final raw in (_credMine!['institutions'] as List<dynamic>))
                        _CredentialInstitutionRow(Map<String, dynamic>.from(raw as Map)),
                    const SizedBox(height: 14),
                    Text(l.credMyLinksManufacturersHeader, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 8),
                    if (((_credMine!['manufacturers'] as List<dynamic>?) ?? []).isEmpty)
                      Text(
                        l.credNoManufacturerHomologation,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
                      )
                    else
                      for (final raw in (_credMine!['manufacturers'] as List<dynamic>))
                        _CredentialManufacturerRow(Map<String, dynamic>.from(raw as Map)),
                  ],
                ),
              ),
            ),
          ],
        ],
        if (appAuth.role == 'institution_admin' && _instQueue.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.credQueueInstTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l.credQueueInstBody,
            style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
          ),
          const SizedBox(height: 12),
          for (final row in _instQueue)
            Builder(
              builder: (ctx) {
                final loc = AppLocalizations.of(ctx);
                final ins = row['instructor'] as Map?;
                final nm = ins?['name']?.toString() ?? loc.trainReqDashNone;
                final em = ins?['email']?.toString() ?? '';
                final st = row['status']?.toString();
                return instructorShellCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nm, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              if (em.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(em, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
                                ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(localizedCredentialQueueStatus(AppLocalizations.of(ctx), st)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: _credentialStatusColor(st),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: !online ? null : () => _decideInst(row['id'], 'approved'),
                              child: Text(l.credBtnApprove),
                            ),
                            TextButton(
                              onPressed: !online ? null : () => _decideInst(row['id'], 'rejected'),
                              child: Text(l.credBtnReject),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
        if (appAuth.role == 'manufacturer_admin' && _manuQueue.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l.credQueueManuTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l.credQueueManuBody,
            style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
          ),
          const SizedBox(height: 12),
          for (final row in _manuQueue)
            Builder(
              builder: (ctx) {
                final loc = AppLocalizations.of(ctx);
                final ins = row['instructor'] as Map?;
                final nm = ins?['name']?.toString() ?? loc.trainReqDashNone;
                final em = ins?['email']?.toString() ?? '';
                final st = row['status']?.toString();
                final endorsed = row['endorsed_by_institution'] is Map &&
                    (((row['endorsed_by_institution'] as Map)['name']?.toString() ?? '').isNotEmpty);
                final endName =
                    endorsed ? (row['endorsed_by_institution'] as Map)['name']?.toString() ?? '' : null;
                final canApproveRejectManu = st == 'pending';
                final canSuspendManu = st == 'approved';
                final canReactivateManu = st == 'suspended';
                final rawCreated = row['created_at']?.toString();
                return instructorShellCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nm, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              if (em.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(em, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
                                ),
                              if (rawCreated != null && rawCreated.length >= 10)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l.mfgHomologRequestedAt(rawCreated.substring(0, 10)),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                endorsed ? l.credEndorsementWith(endName ?? '') : l.credEndorsementPending,
                                style: TextStyle(fontSize: 12.5, color: Colors.blueGrey.shade800, height: 1.35),
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(localizedCredentialQueueStatus(AppLocalizations.of(ctx), st)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: _credentialStatusColor(st),
                              ),
                            ],
                          ),
                        ),
                        if (canApproveRejectManu || canSuspendManu || canReactivateManu)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (canApproveRejectManu) ...[
                                TextButton(
                                  onPressed: !online ? null : () => _decideManu(row['id'], 'approved'),
                                  child: Text(l.credBtnApprove),
                                ),
                                TextButton(
                                  onPressed: !online ? null : () => _decideManu(row['id'], 'rejected'),
                                  child: Text(l.credBtnReject),
                                ),
                              ],
                              if (canSuspendManu)
                                TextButton(
                                  onPressed: !online ? null : () => _decideManu(row['id'], 'suspended'),
                                  child: Text(l.credBtnSuspend),
                                ),
                              if (canReactivateManu)
                                TextButton(
                                  onPressed: !online ? null : () => _decideManu(row['id'], 'approved', setFeePaidOnApprove: false),
                                  child: Text(l.credBtnReactivateHomolog),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ],
        ),
      ),
    );
  }

  Future<void> _applyInst() async {
    final t = appAuth.token;
    final id = _applyInstitutionId;
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.applyCredentialInstitution(t, id);
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).credSnackRequestSent)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _applyManu() async {
    final t = appAuth.token;
    final id = _applyManufacturerId;
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await widget.api.applyCredentialManufacturer(t, id);
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).credSnackRequestManufacturerSent)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decideInst(dynamic rowId, String status) async {
    final t = appAuth.token;
    final id = _parseInt(rowId);
    if (t == null || id == null) return;
    try {
      await widget.api.credentialInstitutionDecide(t, id, status);
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    }
  }

  Future<void> _decideManu(
    dynamic rowId,
    String status, {
    bool setFeePaidOnApprove = true,
  }) async {
    final t = appAuth.token;
    final id = _parseInt(rowId);
    if (t == null || id == null) return;
    try {
      await widget.api.credentialManufacturerDecide(
        t,
        id,
        status: status,
        feePaid: status == 'approved' ? (setFeePaidOnApprove ? true : null) : null,
      );
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    }
  }
}
