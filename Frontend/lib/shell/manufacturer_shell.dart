import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../l10n/status_labels.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../util/download_bytes.dart';
import '../widgets/version_badge.dart';
import 'manufacturer_equipment_wizard.dart';
import 'manufacturer_onboarding_wizard.dart';
import 'manufacturer_pending_approval_screen.dart';
import 'manufacturer_template_editor.dart';

const int _kMfgOpsPerPage = 20;

Widget _mfgInstrOfflineBanner(AppLocalizations l) {
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

Color _mfgCredentialChipColor(String? s) {
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

/// Área do fabricante: perfil da empresa e catálogo de equipamentos (instituição nula).
class ManufacturerShell extends StatefulWidget {
  const ManufacturerShell({super.key});

  @override
  State<ManufacturerShell> createState() => _ManufacturerShellState();
}

class _ManufacturerShellState extends State<ManufacturerShell> {
  final _api = ProductionApi(ApiClient());

  Timer? _healthTimer;
  bool _apiOnline = true;

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _manufacturer;
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _templates = [];

  /// Pesquisa na lista de templates (título).
  final _templatesSearchCtrl = TextEditingController();

  /// Filtro de estado na lista de templates (`null` = todos).
  String? _templatesStatusFilter;

  /// Ordenação da lista de templates (`updated_desc` | `title_asc` | `title_desc` | `status_asc`).
  String _templatesSort = 'updated_desc';
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _prizes = [];
  int _opsDocsPage = 1;
  int _opsSeasonsPage = 1;
  int _opsPrizesPage = 1;
  bool _opsDocsHasMore = false;
  bool _opsSeasonsHasMore = false;
  bool _opsPrizesHasMore = false;
  bool _opsPagingBusy = false;
  List<Map<String, dynamic>> _categoryCatalog = [];
  Map<String, dynamic>? _dashboardSummary;

  /// Secção principal (menu lateral): 0 Início, 1 Empresa, 2 Produtos, 3 Operações, 4 Homologações, 5 Análises.
  int _mfgNavIndex = 0;

  final ScrollController _mfgScrollController = ScrollController();

  /// Filtro do catálogo (id da categoria ou null = todos).
  String? _equipmentCategoryFilter;

  /// Pesquisa texto (nome / modelo / série).
  final _equipmentSearchCtrl = TextEditingController();

  /// Filtro de estado na lista (`null` = todos).
  String? _equipmentStatusFilter;

  /// Ordenação da lista (`name_asc` | `updated_desc` | `templates_desc`).
  String _equipmentSort = 'name_asc';

  /// Pedidos de credenciamento de instrutores (Applications).
  List<Map<String, dynamic>> _credentialQueue = [];

  /// Filtro local na lista de homologações: `null` = todos.
  String? _homologStatusFilter;

  int? _analyticsInstitutionId;
  int? _analyticsEquipmentId;
  final _analyticsFromCtrl = TextEditingController();
  final _analyticsToCtrl = TextEditingController();
  Map<String, dynamic>? _analyticsSummary;
  bool _analyticsLoading = false;

  final _name = TextEditingController();
  final _supportEmail = TextEditingController();
  final _cnpj = TextEditingController();
  final _templateTitle = TextEditingController();
  final _docKind = TextEditingController();
  final _docNotes = TextEditingController();

  /// Pesquisa (épocas, prémios, documentos) na secção Operações — API com debounce.
  final _operationsSearchCtrl = TextEditingController();
  Timer? _operationsSearchDebounce;

  /// Pesquisa na lista de templates (Produtos) — recarga parcial com debounce.
  Timer? _templatesSearchDebounce;

  /// Pesquisa no catálogo de equipamentos — recarga parcial com debounce.
  Timer? _equipmentSearchDebounce;

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
    _reload();
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    _name.dispose();
    _supportEmail.dispose();
    _cnpj.dispose();
    _equipmentSearchCtrl.dispose();
    _templatesSearchCtrl.dispose();
    _templateTitle.dispose();
    _docKind.dispose();
    _docNotes.dispose();
    _operationsSearchDebounce?.cancel();
    _operationsSearchCtrl.dispose();
    _templatesSearchDebounce?.cancel();
    _equipmentSearchDebounce?.cancel();
    _analyticsFromCtrl.dispose();
    _analyticsToCtrl.dispose();
    _mfgScrollController.dispose();
    super.dispose();
  }

  /// Navegação lateral (ex.: CTA na lista vazia de homologações) mantendo scroll no topo.
  void navigateToMfgTab(int index) {
    setState(() {
      _mfgNavIndex = index;
      if (_mfgScrollController.hasClients) {
        _mfgScrollController.jumpTo(0);
      }
    });
    if (index == 5 && _manufacturer?['validation_status']?.toString() == 'active') {
      unawaited(_loadAnalytics());
    }
  }

  Future<void> _reload() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prof = await _api.manufacturerProfile(t);
      final m = Map<String, dynamic>.from(prof['manufacturer'] as Map);
      final vs = m['validation_status']?.toString();
      final operational = vs == 'active';

      Map<String, dynamic>? dash;
      var cats = _categoryCatalog;
      List<Map<String, dynamic>> list = [];
      List<Map<String, dynamic>> templates = [];
      final opsSearch = _operationsSearchCtrl.text.trim().isEmpty ? null : _operationsSearchCtrl.text.trim();
      var docsRes = const ManufacturerOperationsIndexPage();
      try {
        docsRes = await _api.listManufacturerDocuments(t, search: opsSearch, page: 1, perPage: _kMfgOpsPerPage);
      } catch (_) {}
      List<Map<String, dynamic>> seasons = [];
      List<Map<String, dynamic>> prizes = [];
      var seasonsHasMore = false;
      var prizesHasMore = false;

      if (operational) {
        try {
          dash = await _api.manufacturerDashboardSummary(t);
        } catch (_) {
          dash = null;
        }
        if (cats.isEmpty) {
          try {
            cats = await _api.equipmentCategoriesCatalog(t);
          } catch (_) {
            cats = [];
          }
        }
        try {
          list = await _api.manufacturerEquipmentList(
            t,
            category: _equipmentCategoryFilter,
            search: _equipmentSearchParam,
            status: _equipmentStatusFilter,
            sort: _equipmentSort,
          );
        } catch (_) {
          list = [];
        }
        try {
          templates = await _api.manufacturerTemplates(
            t,
            search: _templatesSearchParam,
            status: _templatesStatusFilter,
            sort: _templatesSort,
          );
        } catch (_) {
          templates = [];
        }
        try {
          final sr = await _api.manufacturerSeasons(t, search: opsSearch, page: 1, perPage: _kMfgOpsPerPage);
          seasons = sr.items;
          seasonsHasMore = sr.hasMore;
        } catch (_) {
          seasons = [];
          seasonsHasMore = false;
        }
        try {
          final pr = await _api.manufacturerPrizes(t, search: opsSearch, page: 1, perPage: _kMfgOpsPerPage);
          prizes = pr.items;
          prizesHasMore = pr.hasMore;
        } catch (_) {
          prizes = [];
          prizesHasMore = false;
        }
      } else {
        dash = null;
        list = [];
        templates = [];
        seasons = [];
        prizes = [];
        seasonsHasMore = false;
        prizesHasMore = false;
      }

      List<Map<String, dynamic>> credQueue = [];
      if (operational) {
        try {
          credQueue = await _api.credentialManufacturerQueue(t);
        } catch (_) {
          credQueue = [];
        }
      }
      if (!mounted) return;
      setState(() {
        _manufacturer = m;
        _dashboardSummary = dash;
        _categoryCatalog = cats;
        _equipment = list;
        _templates = templates;
        _documents = docsRes.items;
        _opsDocsHasMore = docsRes.hasMore;
        _opsDocsPage = 1;
        _seasons = seasons;
        _opsSeasonsHasMore = seasonsHasMore;
        _opsSeasonsPage = 1;
        _prizes = prizes;
        _opsPrizesHasMore = prizesHasMore;
        _opsPrizesPage = 1;
        _credentialQueue = credQueue;
        _name.text = m['name']?.toString() ?? '';
        _supportEmail.text = m['support_email']?.toString() ?? '';
        _cnpj.text = m['cnpj']?.toString() ?? '';
        _loading = false;
      });
      if (mounted && _mfgNavIndex == 5 && m['validation_status']?.toString() == 'active') {
        unawaited(_loadAnalytics());
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedApiMessage(AppLocalizations.of(context), e);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).mfgLoadFailedData;
          _loading = false;
        });
      }
    }
  }

  List<DropdownMenuItem<int?>> _mfgAnalyticsInstitutionItems(AppLocalizations l) {
    final list = (_dashboardSummary?['aggregated_by_institution'] as List<dynamic>?) ?? [];
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(value: null, child: Text(l.mfgAnalyticsAll)),
    ];
    for (final raw in list) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['institution_id'];
      if (id == null) {
        continue;
      }
      final iid = id is int ? id : (id as num).toInt();
      items.add(
        DropdownMenuItem<int?>(
          value: iid,
          child: Text(m['label']?.toString() ?? '$iid'),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int?>> _mfgAnalyticsEquipmentItems(AppLocalizations l) {
    final list = (_dashboardSummary?['aggregated_by_equipment'] as List<dynamic>?) ?? [];
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(value: null, child: Text(l.mfgAnalyticsAll)),
    ];
    for (final raw in list) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['equipment_id'];
      if (id == null) {
        continue;
      }
      final eid = id is int ? id : (id as num).toInt();
      items.add(
        DropdownMenuItem<int?>(
          value: eid,
          child: Text(m['label']?.toString() ?? '$eid'),
        ),
      );
    }
    return items;
  }

  int? _parseTrainingId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<void> _openTemplateEditor(int trainingId, String title) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManufacturerTemplateEditorScreen(
          trainingId: trainingId,
          title: title,
        ),
      ),
    );
    if (changed == true && mounted) await _reload();
  }

  Future<void> _exportManufacturerDashboardCsv() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final q = _mfgNavIndex == 5 ? _manufacturerAnalyticsQuery() : null;
      final bytes = await _api.manufacturerDashboardExportCsv(t, query: q);
      if (!mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final l = AppLocalizations.of(context);
      downloadBytesAsFile(bytes, l.dashExportFileManufacturerCsv(stamp));
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    }
  }

  Future<void> _exportManufacturerDashboardPdf() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final q = _mfgNavIndex == 5 ? _manufacturerAnalyticsQuery() : null;
      final bytes = await _api.manufacturerDashboardExportPdf(t, query: q);
      if (!mounted) return;
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
      final l = AppLocalizations.of(context);
      downloadBytesAsFile(bytes, l.dashExportFileManufacturerPdf(stamp));
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    }
  }

  Map<String, String>? _manufacturerAnalyticsQuery() {
    final q = <String, String>{};
    if (_analyticsInstitutionId != null) {
      q['institution_id'] = '${_analyticsInstitutionId!}';
    }
    if (_analyticsEquipmentId != null) {
      q['equipment_id'] = '${_analyticsEquipmentId!}';
    }
    final from = _analyticsFromCtrl.text.trim();
    final to = _analyticsToCtrl.text.trim();
    if (from.isNotEmpty) {
      q['training_created_from'] = from;
    }
    if (to.isNotEmpty) {
      q['training_created_to'] = to;
    }
    return q.isEmpty ? null : q;
  }

  Future<void> _loadAnalytics() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_manufacturer?['validation_status']?.toString() != 'active') return;
    setState(() => _analyticsLoading = true);
    try {
      final data = await _api.manufacturerDashboardSummary(t, query: _manufacturerAnalyticsQuery());
      if (!mounted) return;
      setState(() {
        _analyticsSummary = data;
        _analyticsLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _analyticsLoading = false);
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _analyticsLoading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  void _resetAnalyticsFilters() {
    setState(() {
      _analyticsInstitutionId = null;
      _analyticsEquipmentId = null;
      _analyticsFromCtrl.clear();
      _analyticsToCtrl.clear();
    });
    unawaited(_loadAnalytics());
  }

  String _analyticsBreakdownSubtitle(AppLocalizations l, Map<String, dynamic> row) {
    final trainings = (row['trainings_count'] as num?)?.toInt() ?? 0;
    final enr = (row['total_enrollments'] as num?)?.toInt() ?? 0;
    final done = (row['completed_count'] as num?)?.toInt() ?? 0;
    final rateRaw = row['completion_rate_percent'];
    final rate = rateRaw == null ? l.trainReqDashNone : '$rateRaw%';
    final avgRaw = row['avg_score'];
    final avg = avgRaw == null ? l.trainReqDashNone : avgRaw.toString();
    return l.mfgAnalyticsBreakdownSubtitle(trainings, enr, done, rate, avg);
  }

  /// Últimos [maxMonths] períodos de `monthly_trend` (a API devolve meses ordenados).
  List<dynamic> _tailMonthlyTrendPreview(List<dynamic> series, int maxMonths) {
    if (series.isEmpty) {
      return const [];
    }
    if (series.length <= maxMonths) {
      return List<dynamic>.from(series);
    }
    return series.sublist(series.length - maxMonths);
  }

  Widget _buildMonthlyTrendCombined(AppLocalizations l, List<dynamic> rawTrend) {
    if (rawTrend.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.mfgAnalyticsMonthlyTrendEmpty,
              style: const TextStyle(color: Color(0xFF45464D), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => navigateToMfgTab(0),
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: Text(l.mfgNavHome),
                ),
                OutlinedButton.icon(
                  onPressed: () => navigateToMfgTab(2),
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text(l.mfgNavProducts),
                ),
              ],
            ),
          ],
        ),
      );
    }
    final rows = rawTrend.map((e) => Map<String, dynamic>.from(e)).toList();
    var maxE = 0;
    var maxC = 0;
    for (final r in rows) {
      maxE = math.max(maxE, (r['enrollment_count'] as num?)?.toInt() ?? 0);
      maxC = math.max(maxC, (r['completed_count'] as num?)?.toInt() ?? 0);
    }
    final denE = maxE > 0 ? maxE : 1;
    final denC = maxC > 0 ? maxC : 1;

    Widget metricRow(String label, int value, int denom, Color color) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / denom,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 28,
              child: Text(
                '$value',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          Text(
            rows[i]['period']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          metricRow(
            l.mfgAnalyticsTrendLegendEnroll,
            (rows[i]['enrollment_count'] as num?)?.toInt() ?? 0,
            denE,
            const Color(0xFF0369A1),
          ),
          metricRow(
            l.mfgAnalyticsTrendLegendComplete,
            (rows[i]['completed_count'] as num?)?.toInt() ?? 0,
            denC,
            const Color(0xFF0F766E),
          ),
          if (i < rows.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
        ],
      ],
    );
  }

  Future<void> _requestValidation() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      final res = await _api.requestManufacturerValidation(t);
      final m = Map<String, dynamic>.from(res['manufacturer'] as Map);
      if (mounted) {
        setState(() {
          _manufacturer = m;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).mfgSnackValidationRequested)),
        );
      }
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

  Future<void> _showCreateSeasonDialog() async {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final t = appAuth.token;
    if (t == null) return;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final lang = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(lang.mfgSeasonNewTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: lang.mfgFieldName)),
                  TextField(controller: startCtrl, decoration: InputDecoration(labelText: lang.mfgFieldSeasonStart)),
                  TextField(controller: endCtrl, decoration: InputDecoration(labelText: lang.mfgFieldSeasonEnd)),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: lang.mfgFieldTargetTrainingsOptional),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(lang.mfgBtnCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(lang.mfgBtnCreate)),
            ],
          );
        },
      );
      if (ok != true) return;
      setState(() => _loading = true);
      final tgt = int.tryParse(targetCtrl.text.trim());
      await _api.createManufacturerSeason(
        t,
        name: nameCtrl.text.trim(),
        startsAt: startCtrl.text.trim(),
        endsAt: endCtrl.text.trim(),
        targetTrainings: tgt,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSeasonCreatedSnack)));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSeasonCreateFailed)));
      }
    } finally {
      nameCtrl.dispose();
      startCtrl.dispose();
      endCtrl.dispose();
      targetCtrl.dispose();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSeasonLeaderboard(int seasonId) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      final data = await _api.manufacturerSeasonLeaderboard(t, seasonId);
      if (!mounted) return;
      final entries = (data['entries'] as List<dynamic>?) ?? [];
      final target = data['target_trainings'];
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final lang = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(lang.mfgSeasonRankingTitle),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (target != null) Text(lang.mfgSeasonTargetLine(target), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    if (entries.isEmpty)
                      Text(lang.mfgSeasonNoClosedTrainings)
                    else
                      Column(
                        children: [
                          for (final raw in entries) _seasonLeaderboardRow(ctx, raw),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.mfgBtnClose))],
          );
        },
      );
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgLeaderboardLoadFailed)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _recomputeSeason(int seasonId) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.recomputeManufacturerSeason(t, seasonId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackRankingRecomputed)));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        context.showErrApiConnectionSnack();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _seasonLeaderboardRow(BuildContext context, dynamic raw) {
    final l = AppLocalizations.of(context);
    final e = Map<String, dynamic>.from(raw as Map);
    final ins = e['instructor'];
    final name = ins is Map ? ins['name']?.toString() ?? l.trainReqDashNone : l.trainReqDashNone;
    return ListTile(
      dense: true,
      leading: Text('#${e['rank'] ?? l.trainReqDashNone}', style: const TextStyle(fontWeight: FontWeight.w800)),
      title: Text(name),
      trailing: Text(l.mfgPointsTrainings(e['points'] ?? 0)),
    );
  }

  Future<void> _showAddPrizeDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final sortCtrl = TextEditingController();
    final t = appAuth.token;
    if (t == null) {
      titleCtrl.dispose();
      descCtrl.dispose();
      sortCtrl.dispose();
      return;
    }
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final lang = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(lang.mfgPrizeNewTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: lang.mfgFieldTitle)),
                  TextField(
                    controller: descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: lang.mfgFieldDescriptionOptional),
                  ),
                  TextField(
                    controller: sortCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: lang.mfgFieldSortOptional),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(lang.mfgBtnCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(lang.mfgBtnSave)),
            ],
          );
        },
      );
      if (ok != true) return;
      setState(() => _loading = true);
      await _api.createManufacturerPrize(
        t,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        sortOrder: int.tryParse(sortCtrl.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgPrizeSavedSnack)));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgPrizeSaveFailed)));
      }
    } finally {
      titleCtrl.dispose();
      descCtrl.dispose();
      sortCtrl.dispose();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePrize(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lang = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(lang.mfgPrizeDeleteTitle),
          content: Text(lang.mfgPrizeDeleteBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(lang.mfgBtnCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(lang.mfgBtnRemove)),
          ],
        );
      },
    );
    if (ok != true) return;
    setState(() => _loading = true);
    try {
      await _api.deleteManufacturerPrize(t, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackRemoved)));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        context.showErrApiConnectionSnack();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.updateManufacturerProfile(t, {
        'name': _name.text.trim(),
        'support_email': _supportEmail.text.trim().isEmpty ? null : _supportEmail.text.trim(),
        'cnpj': _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackProfileUpdated)));
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

  String _categoryLabel(String id) {
    for (final c in _categoryCatalog) {
      if (c['id']?.toString() == id) {
        return c['label']?.toString() ?? id;
      }
    }
    return id;
  }

  void _setEquipmentCategoryFilter(String? categoryId) {
    setState(() => _equipmentCategoryFilter = categoryId);
    unawaited(_reloadEquipmentList());
  }

  void _setEquipmentStatusFilter(String? status) {
    setState(() => _equipmentStatusFilter = status);
    unawaited(_reloadEquipmentList());
  }

  bool get _equipmentFiltersDirty =>
      _equipmentSearchCtrl.text.trim().isNotEmpty ||
      _equipmentCategoryFilter != null ||
      _equipmentStatusFilter != null ||
      _equipmentSort != 'name_asc';

  void _setEquipmentSort(String sort) {
    if (_equipmentSort == sort) return;
    setState(() => _equipmentSort = sort);
    unawaited(_reloadEquipmentList());
  }

  bool get _equipmentSearchActive => _equipmentSearchCtrl.text.trim().isNotEmpty;

  String? get _equipmentSearchParam {
    final s = _equipmentSearchCtrl.text.trim();
    if (s.isEmpty) return null;
    return s.length > 120 ? s.substring(0, 120) : s;
  }

  Future<void> _reloadEquipmentList() async {
    final t = appAuth.token;
    if (t == null || !mounted) return;
    if (_manufacturer?['validation_status']?.toString() != 'active') {
      if (mounted) setState(() => _equipment = []);
      return;
    }
    try {
      final list = await _api.manufacturerEquipmentList(
        t,
        category: _equipmentCategoryFilter,
        search: _equipmentSearchParam,
        status: _equipmentStatusFilter,
        sort: _equipmentSort,
      );
      if (!mounted) return;
      setState(() => _equipment = list);
    } catch (_) {
      if (mounted) setState(() => _equipment = []);
    }
  }

  void _scheduleEquipmentSearchReload() {
    _equipmentSearchDebounce?.cancel();
    _equipmentSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || !_apiOnline) return;
      unawaited(_reloadEquipmentList());
    });
  }

  void _clearEquipmentFilters() {
    _equipmentSearchDebounce?.cancel();
    setState(() {
      _equipmentSearchCtrl.clear();
      _equipmentCategoryFilter = null;
      _equipmentStatusFilter = null;
      _equipmentSort = 'name_asc';
    });
    unawaited(_reloadEquipmentList());
  }

  bool get _templatesFiltersDirty =>
      _templatesSearchCtrl.text.trim().isNotEmpty ||
      _templatesStatusFilter != null ||
      _templatesSort != 'updated_desc';

  bool get _templatesSearchActive => _templatesSearchCtrl.text.trim().isNotEmpty;

  String? get _templatesSearchParam {
    final s = _templatesSearchCtrl.text.trim();
    if (s.isEmpty) return null;
    return s.length > 120 ? s.substring(0, 120) : s;
  }

  Future<void> _reloadTemplatesList() async {
    final t = appAuth.token;
    if (t == null || !mounted) return;
    if (_manufacturer?['validation_status']?.toString() != 'active') {
      if (mounted) setState(() => _templates = []);
      return;
    }
    try {
      final list = await _api.manufacturerTemplates(
        t,
        search: _templatesSearchParam,
        status: _templatesStatusFilter,
        sort: _templatesSort,
      );
      if (!mounted) return;
      setState(() => _templates = list);
    } catch (_) {
      if (mounted) setState(() => _templates = []);
    }
  }

  void _scheduleTemplatesSearchReload() {
    _templatesSearchDebounce?.cancel();
    _templatesSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || !_apiOnline) return;
      unawaited(_reloadTemplatesList());
    });
  }

  void _setTemplatesStatusFilter(String? status) {
    setState(() => _templatesStatusFilter = status);
    unawaited(_reloadTemplatesList());
  }

  void _setTemplatesSort(String sort) {
    if (_templatesSort == sort) return;
    setState(() => _templatesSort = sort);
    unawaited(_reloadTemplatesList());
  }

  void _clearTemplatesFilters() {
    _templatesSearchDebounce?.cancel();
    setState(() {
      _templatesSearchCtrl.clear();
      _templatesStatusFilter = null;
      _templatesSort = 'updated_desc';
    });
    unawaited(_reloadTemplatesList());
  }

  bool get _operationsSearchActive => _operationsSearchCtrl.text.trim().isNotEmpty;

  String? get _operationsSearchParam {
    final s = _operationsSearchCtrl.text.trim();
    if (s.isEmpty) return null;
    return s.length > 120 ? s.substring(0, 120) : s;
  }

  Future<void> _reloadOperationsData() async {
    final t = appAuth.token;
    if (t == null || !mounted) return;
    final vs = _manufacturer?['validation_status']?.toString();
    final operational = vs == 'active';
    final q = _operationsSearchParam;
    try {
      final docsRes = await _api.listManufacturerDocuments(t, search: q, page: 1, perPage: _kMfgOpsPerPage);
      if (!mounted) return;
      var seasons = <Map<String, dynamic>>[];
      var prizes = <Map<String, dynamic>>[];
      var seasonsHasMore = false;
      var prizesHasMore = false;
      if (operational) {
        try {
          final sr = await _api.manufacturerSeasons(t, search: q, page: 1, perPage: _kMfgOpsPerPage);
          seasons = sr.items;
          seasonsHasMore = sr.hasMore;
        } catch (_) {}
        try {
          final pr = await _api.manufacturerPrizes(t, search: q, page: 1, perPage: _kMfgOpsPerPage);
          prizes = pr.items;
          prizesHasMore = pr.hasMore;
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _documents = docsRes.items;
        _opsDocsHasMore = docsRes.hasMore;
        _opsDocsPage = 1;
        _seasons = seasons;
        _opsSeasonsHasMore = seasonsHasMore;
        _opsSeasonsPage = 1;
        _prizes = prizes;
        _opsPrizesHasMore = prizesHasMore;
        _opsPrizesPage = 1;
      });
    } catch (_) {}
  }

  Future<void> _loadMoreSeasons() async {
    if (!_opsSeasonsHasMore || _opsPagingBusy || _loading) return;
    final t = appAuth.token;
    if (t == null || _manufacturer?['validation_status']?.toString() != 'active') return;
    final next = _opsSeasonsPage + 1;
    final q = _operationsSearchParam;
    setState(() => _opsPagingBusy = true);
    try {
      final res = await _api.manufacturerSeasons(t, search: q, page: next, perPage: _kMfgOpsPerPage);
      if (!mounted) return;
      setState(() {
        _seasons = [..._seasons, ...res.items];
        _opsSeasonsPage = next;
        _opsSeasonsHasMore = res.hasMore;
        _opsPagingBusy = false;
      });
    } catch (_) {
      if (mounted) setState(() => _opsPagingBusy = false);
    }
  }

  Future<void> _loadMorePrizes() async {
    if (!_opsPrizesHasMore || _opsPagingBusy || _loading) return;
    final t = appAuth.token;
    if (t == null || _manufacturer?['validation_status']?.toString() != 'active') return;
    final next = _opsPrizesPage + 1;
    final q = _operationsSearchParam;
    setState(() => _opsPagingBusy = true);
    try {
      final res = await _api.manufacturerPrizes(t, search: q, page: next, perPage: _kMfgOpsPerPage);
      if (!mounted) return;
      setState(() {
        _prizes = [..._prizes, ...res.items];
        _opsPrizesPage = next;
        _opsPrizesHasMore = res.hasMore;
        _opsPagingBusy = false;
      });
    } catch (_) {
      if (mounted) setState(() => _opsPagingBusy = false);
    }
  }

  Future<void> _loadMoreDocuments() async {
    if (!_opsDocsHasMore || _opsPagingBusy || _loading) return;
    final t = appAuth.token;
    if (t == null) return;
    final next = _opsDocsPage + 1;
    final q = _operationsSearchParam;
    setState(() => _opsPagingBusy = true);
    try {
      final res = await _api.listManufacturerDocuments(t, search: q, page: next, perPage: _kMfgOpsPerPage);
      if (!mounted) return;
      setState(() {
        _documents = [..._documents, ...res.items];
        _opsDocsPage = next;
        _opsDocsHasMore = res.hasMore;
        _opsPagingBusy = false;
      });
    } catch (_) {
      if (mounted) setState(() => _opsPagingBusy = false);
    }
  }

  void _scheduleOperationsSearchReload() {
    _operationsSearchDebounce?.cancel();
    _operationsSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || !_apiOnline) return;
      unawaited(_reloadOperationsData());
    });
  }

  void _clearOperationsSearch() {
    _operationsSearchDebounce?.cancel();
    _operationsSearchCtrl.clear();
    setState(() {});
    unawaited(_reloadOperationsData());
  }

  Future<void> _openEquipmentWizard({
    int? parentEquipmentId,
    String? initialName,
    String? initialModel,
    String? initialCategoryId,
    Map<String, dynamic>? editEquipment,
  }) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManufacturerEquipmentWizardScreen(
          api: _api,
          categoryCatalog: _categoryCatalog,
          parentEquipmentId: parentEquipmentId,
          initialName: initialName,
          initialModel: initialModel,
          initialCategoryId: initialCategoryId,
          editEquipment: editEquipment,
        ),
      ),
    );
    if (ok == true && mounted) await _reload();
  }

  Future<void> _startNewEquipmentVersion(int parentId, String name, String model, String? categoryId) async {
    await _openEquipmentWizard(
      parentEquipmentId: parentId,
      initialName: name,
      initialModel: model,
      initialCategoryId: categoryId,
    );
  }

  Future<void> _deleteEquipment(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.deleteManufacturerEquipment(t, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackRemoved)));
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

  void _setHomologStatusFilter(String? status) {
    setState(() => _homologStatusFilter = status);
  }

  int _homologQueueCountForFilter(String? status) {
    if (status == null) {
      return _credentialQueue.length;
    }
    return _credentialQueue.where((r) => (r['status']?.toString() ?? '') == status).length;
  }

  Future<void> _decideHomologCredential(
    dynamic rowId,
    String status, {
    bool setFeePaidOnApprove = true,
  }) async {
    final t = appAuth.token;
    final id = rowId is int ? rowId : int.tryParse(rowId.toString());
    if (t == null || id == null) return;
    setState(() => _loading = true);
    try {
      await _api.credentialManufacturerDecide(
        t,
        id,
        status: status,
        feePaid: status == 'approved' ? (setFeePaidOnApprove ? true : null) : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).mfgSnackHomologUpdated)),
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

  Future<void> _pickAndUploadDocument() async {
    final t = appAuth.token;
    if (t == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    setState(() => _loading = true);
    try {
      final name = f.name;
      final kind = _docKind.text.trim();
      final notes = _docNotes.text.trim();
      if (f.bytes != null && f.bytes!.isNotEmpty) {
        await _api.uploadManufacturerDocument(
          t,
          filename: name,
          fileBytes: f.bytes,
          documentKind: kind.isEmpty ? null : kind,
          notes: notes.isEmpty ? null : notes,
        );
      } else if (f.path != null && f.path!.isNotEmpty) {
        await _api.uploadManufacturerDocument(
          t,
          filename: name,
          filePath: f.path,
          documentKind: kind.isEmpty ? null : kind,
          notes: notes.isEmpty ? null : notes,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).mfgSnackFileReadError)),
          );
        }
        return;
      }
      _docKind.clear();
      _docNotes.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackDocumentUploaded)));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackUploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteDocument(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.deleteManufacturerDocument(t, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackDocumentRemoved)));
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

  Future<void> _downloadDocument(Map<String, dynamic> row) async {
    final idRaw = row['id'];
    final name = row['original_filename']?.toString() ?? AppLocalizations.of(context).mfgFileFallbackName;
    final iid = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    final t = appAuth.token;
    if (t == null || iid == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await _api.downloadManufacturerDocument(t, iid);
      final parts = name.split('.');
      final ext = parts.length > 1 ? parts.last : 'bin';
      final base = parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name;
      await FileSaver.instance.saveFile(
        name: base,
        fileExtension: ext,
        bytes: bytes,
        mimeType: _mimeTypeForExtension(ext),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackFileSaved(name))));
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackDownloadFailed)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _formatDocSize(AppLocalizations l, dynamic v) {
    if (v == null) return l.trainReqDashNone;
    final n = v is int ? v : int.tryParse(v.toString());
    if (n == null || n <= 0) return l.trainReqDashNone;
    if (n < 1024) return l.mfgDocSizeBytes('$n');
    if (n < 1024 * 1024) return l.mfgDocSizeKb((n / 1024).toStringAsFixed(1));
    return l.mfgDocSizeMb((n / (1024 * 1024)).toStringAsFixed(1));
  }

  static MimeType _mimeTypeForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return MimeType.pdf;
      case 'jpg':
      case 'jpeg':
        return MimeType.jpeg;
      case 'png':
        return MimeType.png;
      case 'webp':
        return MimeType.webp;
      default:
        return MimeType.other;
    }
  }

  String _formatTemplateRowUpdated(AppLocalizations l, dynamic raw) {
    if (raw == null) return '';
    final d = DateTime.tryParse(raw.toString());
    if (d == null) return '';
    final x = d.toLocal();
    final date =
        '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')} ${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';
    return l.mfgTplRowUpdatedAt(date);
  }

  Future<void> _createOfficialTemplate() async {
    final t = appAuth.token;
    if (t == null) return;
    final title = _templateTitle.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).mfgSnackOfficialTitleRequired)));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.createTraining(t, {
        'title': title,
        'type': 'official',
        'is_official_template': true,
        'passing_score_percent': 70,
        'status': 'draft',
      });
      _templateTitle.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).mfgSnackTemplateCreated)),
        );
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        context.showErrApiConnectionSnack();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = appAuth.user;
    final email = user?['email']?.toString() ?? '';
    final l = AppLocalizations.of(context);
    final online = _apiOnline;

    if (_loading && _manufacturer == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _manufacturer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _reload, child: Text(l.actionRetry)),
              ],
            ),
          ),
        ),
      );
    }

    final vs = _manufacturer?['validation_status']?.toString();
    if (_manufacturer != null && (vs == 'pending_info' || vs == 'rejected')) {
      return ManufacturerOnboardingWizard(
        manufacturer: _manufacturer!,
        onCompleted: _reload,
        onLogout: () => appAuth.logout(),
        onShellRefresh: _reload,
      );
    }

    if (_manufacturer != null && vs == 'pending_validation') {
      return ManufacturerPendingApprovalScreen(
        manufacturer: _manufacturer!,
        userEmail: email,
        onLogout: () => appAuth.logout(),
        onRefresh: _reload,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.white,
                elevation: 1,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.mfgAreaTitle,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                              ),
                              Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: online ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                                size: 16,
                                color: online ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                online ? l.trnApiOk : l.trnApiOffline,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: online ? const Color(0xFF047857) : const Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(onPressed: () => appAuth.logout(), child: Text(l.actionSignOut)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _MfgSideNav(
                                selectedIndex: _mfgNavIndex,
                                onSelect: navigateToMfgTab,
                              ),
                              const VerticalDivider(width: 1, thickness: 1),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: _reload,
                                  child: ListView(
                                    controller: _mfgScrollController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                                    children: [
                                      if (!online) ...[
                                        _mfgInstrOfflineBanner(l),
                                        const SizedBox(height: 16),
                                      ],
                                      if (_mfgNavIndex == 0) ...[
                                if (_manufacturer?['validation_status']?.toString() == 'active' &&
                                    _dashboardSummary == null &&
                                    !_loading) ...[
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            l.mfgDashSummaryUnavailableTitle,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            l.mfgDashSummaryUnavailableBody,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: !online ? null : () => unawaited(_reload()),
                                                icon: const Icon(Icons.refresh_rounded, size: 20),
                                                label: Text(l.actionRetry),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: (_loading || !online) ? null : () => navigateToMfgTab(5),
                                                icon: const Icon(Icons.analytics_outlined, size: 20),
                                                label: Text(l.mfgDashOpenAnalytics),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (_dashboardSummary != null) ...[
                                  Text(l.mfgDashSummaryTitle, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 6),
                                  Text(
                                    l.mfgDashSummaryIntro,
                                    style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 14,
                                            runSpacing: 14,
                                            children: [
                                              _DashKpi(
                                                title: l.dashKpiTrainings,
                                                value: _dashboardSummary!['trainings_count']?.toString() ?? '0',
                                              ),
                                              _DashKpi(
                                                title: l.dashKpiFinished,
                                                value: _dashboardSummary!['finished_trainings_count']?.toString() ?? '0',
                                              ),
                                              _DashKpi(
                                                title: l.dashKpiEnrollmentsTotal,
                                                value: (_dashboardSummary!['completion_summary'] is Map
                                                        ? Map<String, dynamic>.from(
                                                            _dashboardSummary!['completion_summary'] as Map,
                                                          )['total_enrollments']
                                                        : null)
                                                    ?.toString() ??
                                                    '0',
                                              ),
                                              _DashKpi(
                                                title: l.dashKpiCompleted,
                                                value: (_dashboardSummary!['completion_summary'] is Map
                                                        ? Map<String, dynamic>.from(
                                                            _dashboardSummary!['completion_summary'] as Map,
                                                          )['completed_count']
                                                        : null)
                                                    ?.toString() ??
                                                    '0',
                                              ),
                                              _DashKpi(
                                                title: l.dashKpiAvgCompleted,
                                                value: _dashboardSummary!['avg_score_completed'] == null
                                                    ? l.trainReqDashNone
                                                    : _dashboardSummary!['avg_score_completed'].toString(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 8,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: (_loading || !online) ? null : () => unawaited(_exportManufacturerDashboardCsv()),
                                                icon: const Icon(Icons.table_chart_outlined, size: 20),
                                                label: Text(l.dashExportCsv),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: (_loading || !online) ? null : () => unawaited(_exportManufacturerDashboardPdf()),
                                                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                                label: Text(l.dashExportPdf),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l.mfgDashMonthlyTrendTitle, style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 6),
                                          Text(
                                            l.mfgDashMonthlyTrendIntro,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                          ),
                                          const SizedBox(height: 10),
                                          _buildMonthlyTrendCombined(
                                            l,
                                            _tailMonthlyTrendPreview(
                                              (_dashboardSummary!['monthly_trend'] as List<dynamic>?) ?? const [],
                                              6,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton.icon(
                                              onPressed: (_loading || !online) ? null : () => navigateToMfgTab(5),
                                              icon: const Icon(Icons.analytics_outlined, size: 20),
                                              label: Text(l.mfgDashOpenAnalytics),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (_manufacturer != null &&
                                    _manufacturer!['validation_status']?.toString() == 'active') ...[
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l.mfgDashQuickCatalogTitle, style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 6),
                                          Text(
                                            l.mfgDashQuickCatalogBody,
                                            style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
                                          ),
                                          const SizedBox(height: 12),
                                          FilledButton.icon(
                                            onPressed: (_loading || !online) ? null : () => unawaited(_openEquipmentWizard()),
                                            icon: const Icon(Icons.medical_services_outlined),
                                            label: Text(l.mfgDashNewEquipment),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (_manufacturer != null) _ValidationStatusCard(
                                  manufacturer: _manufacturer!,
                                  loading: _loading,
                                  apiOnline: online,
                                  onRequestValidation: _requestValidation,
                                ),
                                const SizedBox(height: 16),
                                      ],
                                      if (_mfgNavIndex == 3) ...[
                                TextField(
                                  controller: _operationsSearchCtrl,
                                  onChanged: (_) {
                                    setState(() {});
                                    _scheduleOperationsSearchReload();
                                  },
                                  onSubmitted: (_) {
                                    if (!online) return;
                                    _operationsSearchDebounce?.cancel();
                                    unawaited(_reloadOperationsData());
                                  },
                                  decoration: InputDecoration(
                                    labelText: l.mfgOpsSearchHint,
                                    suffixIcon: _operationsSearchActive
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded),
                                            onPressed: (_loading || !online) ? null : _clearOperationsSearch,
                                          )
                                        : null,
                                  ),
                                ),
                                if (_operationsSearchActive) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    l.mfgOpsServerFilterHint,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: Text(l.mfgSeasonsSectionTitle, style: Theme.of(context).textTheme.titleLarge)),
                                    TextButton.icon(
                                      onPressed: (_loading || !online) ? null : _showCreateSeasonDialog,
                                      icon: const Icon(Icons.add_rounded, size: 20),
                                      label: Text(l.mfgSeasonNewTitle),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l.mfgSeasonsIntro,
                                  style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                if (_seasons.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _operationsSearchActive
                                        ? Text(
                                            l.mfgOpsSublistNoMatch,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l.mfgSeasonsEmpty,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(0),
                                                    icon: const Icon(Icons.home_outlined, size: 18),
                                                    label: Text(l.mfgNavHome),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(2),
                                                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                                    label: Text(l.mfgNavProducts),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  )
                                else
                                  Card(
                                    child: Column(
                                      children: [
                                        for (final s in _seasons)
                                          ListTile(
                                            title: Text(s['name']?.toString() ?? ''),
                                            subtitle: Text(
                                              '${s['starts_at'] ?? l.trainReqDashNone} → ${s['ends_at'] ?? l.trainReqDashNone}'
                                              '${s['target_trainings'] != null ? l.mfgSeasonMetaSuffix(s['target_trainings']) : ''}',
                                            ),
                                            trailing: Wrap(
                                              spacing: 4,
                                              children: [
                                                IconButton(
                                                  tooltip: l.mfgTooltipViewLeaderboard,
                                                  icon: const Icon(Icons.leaderboard_outlined),
                                                  onPressed: (_loading || !online)
                                                      ? null
                                                      : () {
                                                          final id = _parseTrainingId(s['id']);
                                                          if (id != null) unawaited(_showSeasonLeaderboard(id));
                                                        },
                                                ),
                                                IconButton(
                                                  tooltip: l.mfgTooltipRecompute,
                                                  icon: const Icon(Icons.refresh_rounded),
                                                  onPressed: (_loading || !online)
                                                      ? null
                                                      : () {
                                                          final id = _parseTrainingId(s['id']);
                                                          if (id != null) unawaited(_recomputeSeason(id));
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (_opsSeasonsHasMore)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton(
                                        onPressed: _loading || _opsPagingBusy || !online ? null : () => unawaited(_loadMoreSeasons()),
                                        child: Text(l.mfgOpsLoadMore),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: Text(l.mfgPrizesSectionTitle, style: Theme.of(context).textTheme.titleLarge)),
                                    TextButton.icon(
                                      onPressed: (_loading || !online) ? null : _showAddPrizeDialog,
                                      icon: const Icon(Icons.emoji_events_outlined, size: 20),
                                      label: Text(l.mfgBtnAdd),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l.mfgPrizesIntro,
                                  style: const TextStyle(color: Color(0xFF45464D), fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                if (_prizes.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _operationsSearchActive ? l.mfgOpsSublistNoMatch : l.mfgPrizesEmpty,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                    ),
                                  )
                                else
                                  Card(
                                    child: Column(
                                      children: [
                                        for (final p in _prizes)
                                          ListTile(
                                            title: Text(p['title']?.toString() ?? ''),
                                            subtitle: p['description'] != null && p['description'].toString().isNotEmpty
                                                ? Text(
                                                    p['description'].toString(),
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                  )
                                                : null,
                                            trailing: IconButton(
                                              tooltip: l.mfgBtnRemove,
                                              icon: const Icon(Icons.delete_outline_rounded),
                                              onPressed: (_loading || !online)
                                                  ? null
                                                  : () {
                                                      final id = _parseTrainingId(p['id']);
                                                      if (id != null) unawaited(_deletePrize(id));
                                                    },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                if (_opsPrizesHasMore)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton(
                                        onPressed: _loading || _opsPagingBusy || !online ? null : () => unawaited(_loadMorePrizes()),
                                        child: Text(l.mfgOpsLoadMore),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(l.mfgDocumentsSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  l.mfgDocumentsIntro,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _docKind,
                                  decoration: InputDecoration(
                                    labelText: l.mfgDocKindOptional,
                                    hintText: l.mfgDocKindHint,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _docNotes,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: l.mfgDocNotesOptional,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: (_loading || !online) ? null : _pickAndUploadDocument,
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: Text(l.mfgBtnSendFile),
                                ),
                                const SizedBox(height: 16),
                                if (_documents.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _operationsSearchActive
                                        ? Text(
                                            l.mfgOpsSublistNoMatch,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l.mfgDocumentsEmpty,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(0),
                                                    icon: const Icon(Icons.home_outlined, size: 18),
                                                    label: Text(l.mfgNavHome),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(2),
                                                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                                    label: Text(l.mfgNavProducts),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  )
                                else ...[
                                  ..._documents.map((row) {
                                    final id = row['id'];
                                    final iid = id is int ? id : int.tryParse(id.toString());
                                    final title = row['original_filename']?.toString() ?? l.mfgFileFallbackName;
                                    final kind = row['document_kind']?.toString() ?? '';
                                    final notes = row['notes']?.toString() ?? '';
                                    final size = _formatDocSize(l, row['size_bytes']);
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(title),
                                        subtitle: Text(
                                          [
                                            if (kind.isNotEmpty) kind,
                                            size,
                                            if (notes.isNotEmpty) notes,
                                          ].join(' · '),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: l.mfgTooltipDownload,
                                              icon: const Icon(Icons.download_outlined),
                                              onPressed: _loading || !online || iid == null ? null : () => _downloadDocument(row),
                                            ),
                                            IconButton(
                                              tooltip: l.mfgBtnRemove,
                                              icon: const Icon(Icons.delete_outline),
                                              onPressed: _loading || !online || iid == null ? null : () => _deleteDocument(iid),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  if (_opsDocsHasMore)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: OutlinedButton(
                                          onPressed: _loading || _opsPagingBusy || !online ? null : () => unawaited(_loadMoreDocuments()),
                                          child: Text(l.mfgOpsLoadMore),
                                        ),
                                      ),
                                    ),
                                ],
                                      ],
                                      if (_mfgNavIndex == 1) ...[
                                Text(l.mfgCompanySectionTitle, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _name,
                                  decoration: InputDecoration(labelText: l.mfgFieldName),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _supportEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(labelText: l.mfgFieldSupportEmail),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _cnpj,
                                  decoration: InputDecoration(labelText: l.mfgLabelCnpj),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: (_loading || !online) ? null : _saveProfile,
                                  child: Text(l.mfgBtnSaveProfile),
                                ),
                                      ],
                                      if (_mfgNavIndex == 4) ...[
                                Text(l.mfgNavHomologations, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                if (_manufacturer == null ||
                                    _manufacturer!['validation_status']?.toString() != 'active') ...[
                                  Text(
                                    l.mfgValHelpPendingValidation,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                  ),
                                ] else ...[
                                  Text(
                                    l.credQueueManuBody,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(l.parkFilterByState, style: Theme.of(context).textTheme.titleSmall),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ChoiceChip(
                                          label: Text('${l.mfgHomologFilterAll} (${_homologQueueCountForFilter(null)})'),
                                          selected: _homologStatusFilter == null,
                                          onSelected: (_loading || !online) ? null : (_) => _setHomologStatusFilter(null),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: ChoiceChip(
                                            label: Text(
                                              '${l.mfgHomologFilterPending} (${_homologQueueCountForFilter('pending')})',
                                            ),
                                            selected: _homologStatusFilter == 'pending',
                                            onSelected: (_loading || !online) ? null : (_) => _setHomologStatusFilter('pending'),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: ChoiceChip(
                                            label: Text(
                                              '${l.mfgHomologFilterApproved} (${_homologQueueCountForFilter('approved')})',
                                            ),
                                            selected: _homologStatusFilter == 'approved',
                                            onSelected: (_loading || !online) ? null : (_) => _setHomologStatusFilter('approved'),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: ChoiceChip(
                                            label: Text(
                                              '${l.mfgHomologFilterRejected} (${_homologQueueCountForFilter('rejected')})',
                                            ),
                                            selected: _homologStatusFilter == 'rejected',
                                            onSelected: (_loading || !online) ? null : (_) => _setHomologStatusFilter('rejected'),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: ChoiceChip(
                                            label: Text(
                                              '${l.mfgHomologFilterSuspended} (${_homologQueueCountForFilter('suspended')})',
                                            ),
                                            selected: _homologStatusFilter == 'suspended',
                                            onSelected: (_loading || !online) ? null : (_) => _setHomologStatusFilter('suspended'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Builder(
                                    builder: (ctx) {
                                      final loc = AppLocalizations.of(ctx);
                                      final rows = _homologStatusFilter == null
                                          ? _credentialQueue
                                          : _credentialQueue
                                              .where((r) => (r['status']?.toString() ?? '') == _homologStatusFilter)
                                              .toList();
                                      if (rows.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 420),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    loc.mfgHomologEmpty,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(color: Color(0xFF64748B)),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      context
                                                          .findAncestorStateOfType<_ManufacturerShellState>()
                                                          ?.navigateToMfgTab(0);
                                                    },
                                                    icon: const Icon(Icons.home_outlined, size: 20),
                                                    label: Text(loc.mfgNavHome),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Column(
                                        children: [
                                          for (final row in rows)
                                            Builder(
                                              builder: (cctx) {
                                                final ins = row['instructor'] as Map?;
                                                final nm = ins?['name']?.toString() ?? loc.trainReqDashNone;
                                                final em = ins?['email']?.toString() ?? '';
                                                final st = row['status']?.toString();
                                                final endorsed = row['endorsed_by_institution'] is Map &&
                                                    (((row['endorsed_by_institution'] as Map)['name']?.toString() ?? '')
                                                        .isNotEmpty);
                                                final endName = endorsed
                                                    ? (row['endorsed_by_institution'] as Map)['name']?.toString() ?? ''
                                                    : null;
                                                final rowId = row['id'];
                                                final canApproveReject = st == 'pending';
                                                final canSuspend = st == 'approved';
                                                final canReactivate = st == 'suspended';
                                                return Card(
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
                                                              Text(
                                                                nm,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                              if (em.isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    em,
                                                                    style: const TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF45464D),
                                                                    ),
                                                                  ),
                                                                ),
                                                              Builder(
                                                                builder: (dctx) {
                                                                  final raw = row['created_at']?.toString();
                                                                  if (raw == null || raw.length < 10) {
                                                                    return const SizedBox.shrink();
                                                                  }
                                                                  return Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      AppLocalizations.of(dctx).mfgHomologRequestedAt(
                                                                        raw.substring(0, 10),
                                                                      ),
                                                                      style: const TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xFF64748B),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text(
                                                                endorsed
                                                                    ? loc.credEndorsementWith(endName ?? '')
                                                                    : loc.credEndorsementPending,
                                                                style: TextStyle(
                                                                  fontSize: 12.5,
                                                                  color: Colors.blueGrey.shade800,
                                                                  height: 1.35,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Chip(
                                                                label: Text(
                                                                  localizedCredentialQueueStatus(
                                                                    AppLocalizations.of(cctx),
                                                                    st,
                                                                  ),
                                                                ),
                                                                visualDensity: VisualDensity.compact,
                                                                backgroundColor: _mfgCredentialChipColor(st),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (canApproveReject || canSuspend || canReactivate)
                                                          Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              if (canApproveReject) ...[
                                                                TextButton(
                                                                  onPressed: (_loading || !online)
                                                                      ? null
                                                                      : () => _decideHomologCredential(rowId, 'approved'),
                                                                  child: Text(loc.credBtnApprove),
                                                                ),
                                                                TextButton(
                                                                  onPressed: (_loading || !online)
                                                                      ? null
                                                                      : () => _decideHomologCredential(rowId, 'rejected'),
                                                                  child: Text(loc.credBtnReject),
                                                                ),
                                                              ],
                                                              if (canSuspend)
                                                                TextButton(
                                                                  onPressed: (_loading || !online)
                                                                      ? null
                                                                      : () => _decideHomologCredential(rowId, 'suspended'),
                                                                  child: Text(loc.credBtnSuspend),
                                                                ),
                                                              if (canReactivate)
                                                                TextButton(
                                                                  onPressed: (_loading || !online)
                                                                      ? null
                                                                      : () => _decideHomologCredential(
                                                                            rowId,
                                                                            'approved',
                                                                            setFeePaidOnApprove: false,
                                                                          ),
                                                                  child: Text(loc.credBtnReactivateHomolog),
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
                                      );
                                    },
                                  ),
                                ],
                                      ],
                                      if (_mfgNavIndex == 5) ...[
                                Text(l.mfgAnalyticsTitle, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  l.mfgAnalyticsIntro,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 16),
                                if (_manufacturer?['validation_status']?.toString() != 'active')
                                  Text(
                                    l.mfgValHelpPendingValidation,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                  )
                                else ...[
                                  if (_analyticsLoading) const LinearProgressIndicator(minHeight: 3),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          if (_analyticsSummary != null) ...[
                                            Text(l.mfgDashSummaryTitle, style: Theme.of(context).textTheme.titleMedium),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 14,
                                              runSpacing: 14,
                                              children: [
                                                _DashKpi(
                                                  title: l.dashKpiTrainings,
                                                  value: _analyticsSummary!['trainings_count']?.toString() ?? '0',
                                                ),
                                                _DashKpi(
                                                  title: l.dashKpiFinished,
                                                  value: _analyticsSummary!['finished_trainings_count']?.toString() ?? '0',
                                                ),
                                                _DashKpi(
                                                  title: l.dashKpiEnrollmentsTotal,
                                                  value: (_analyticsSummary!['completion_summary'] is Map
                                                          ? Map<String, dynamic>.from(
                                                              _analyticsSummary!['completion_summary'] as Map,
                                                            )['total_enrollments']
                                                          : null)
                                                      ?.toString() ??
                                                      '0',
                                                ),
                                                _DashKpi(
                                                  title: l.dashKpiCompleted,
                                                  value: (_analyticsSummary!['completion_summary'] is Map
                                                          ? Map<String, dynamic>.from(
                                                              _analyticsSummary!['completion_summary'] as Map,
                                                            )['completed_count']
                                                          : null)
                                                      ?.toString() ??
                                                      '0',
                                                ),
                                                _DashKpi(
                                                  title: l.dashKpiAvgCompleted,
                                                  value: _analyticsSummary!['avg_score_completed'] == null
                                                      ? l.trainReqDashNone
                                                      : _analyticsSummary!['avg_score_completed'].toString(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 8,
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: (_analyticsLoading || !online)
                                                      ? null
                                                      : () => unawaited(_exportManufacturerDashboardCsv()),
                                                  icon: const Icon(Icons.table_chart_outlined, size: 20),
                                                  label: Text(l.dashExportCsv),
                                                ),
                                                OutlinedButton.icon(
                                                  onPressed: (_analyticsLoading || !online)
                                                      ? null
                                                      : () => unawaited(_exportManufacturerDashboardPdf()),
                                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                                  label: Text(l.dashExportPdf),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          DropdownButtonFormField<int?>(
                                            // Controlled field; `value` still required until DropdownMenu migration.
                                            // ignore: deprecated_member_use
                                            value: () {
                                              final opts = _mfgAnalyticsInstitutionItems(l);
                                              final v = _analyticsInstitutionId;
                                              if (v == null) {
                                                return null;
                                              }
                                              return opts.any((e) => e.value == v) ? v : null;
                                            }(),
                                            decoration: InputDecoration(labelText: l.mfgAnalyticsFilterInstitution),
                                            items: _mfgAnalyticsInstitutionItems(l),
                                            onChanged: (_analyticsLoading || !online)
                                                ? null
                                                : (v) => setState(() => _analyticsInstitutionId = v),
                                          ),
                                          const SizedBox(height: 10),
                                          DropdownButtonFormField<int?>(
                                            // ignore: deprecated_member_use
                                            value: () {
                                              final opts = _mfgAnalyticsEquipmentItems(l);
                                              final v = _analyticsEquipmentId;
                                              if (v == null) {
                                                return null;
                                              }
                                              return opts.any((e) => e.value == v) ? v : null;
                                            }(),
                                            decoration: InputDecoration(labelText: l.mfgAnalyticsFilterEquipment),
                                            items: _mfgAnalyticsEquipmentItems(l),
                                            onChanged: (_analyticsLoading || !online)
                                                ? null
                                                : (v) => setState(() => _analyticsEquipmentId = v),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: _analyticsFromCtrl,
                                            decoration: InputDecoration(labelText: l.mfgAnalyticsDateFrom),
                                          ),
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: _analyticsToCtrl,
                                            decoration: InputDecoration(labelText: l.mfgAnalyticsDateTo),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 8,
                                            children: [
                                              FilledButton(
                                                onPressed: (_analyticsLoading || !online) ? null : () => unawaited(_loadAnalytics()),
                                                child: Text(l.mfgAnalyticsApply),
                                              ),
                                              OutlinedButton(
                                                onPressed: (_analyticsLoading || !online) ? null : _resetAnalyticsFilters,
                                                child: Text(l.mfgAnalyticsReset),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_analyticsSummary != null) ...[
                                    Text(l.mfgAnalyticsSectionInstitutions, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (ctx) {
                                        final loc = AppLocalizations.of(ctx);
                                        final inst =
                                            (_analyticsSummary!['aggregated_by_institution'] as List<dynamic>?) ?? [];
                                        if (inst.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.mfgAnalyticsEmpty,
                                                  style: const TextStyle(color: Color(0xFF45464D)),
                                                ),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    OutlinedButton.icon(
                                                      onPressed: () => navigateToMfgTab(0),
                                                      icon: const Icon(Icons.home_outlined, size: 18),
                                                      label: Text(loc.mfgNavHome),
                                                    ),
                                                    OutlinedButton.icon(
                                                      onPressed: () => navigateToMfgTab(2),
                                                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                                      label: Text(loc.mfgNavProducts),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return Card(
                                          child: Column(
                                            children: [
                                              for (final raw in inst)
                                                ListTile(
                                                  title: Text(
                                                    Map<String, dynamic>.from(raw)['label']?.toString() ??
                                                        loc.trainReqDashNone,
                                                  ),
                                                  subtitle: Text(
                                                    _analyticsBreakdownSubtitle(
                                                      loc,
                                                      Map<String, dynamic>.from(raw),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(l.mfgAnalyticsSectionEquipment, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (ctx) {
                                        final loc = AppLocalizations.of(ctx);
                                        final eq =
                                            (_analyticsSummary!['aggregated_by_equipment'] as List<dynamic>?) ?? [];
                                        if (eq.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.mfgAnalyticsEmpty,
                                                  style: const TextStyle(color: Color(0xFF45464D)),
                                                ),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    OutlinedButton.icon(
                                                      onPressed: () => navigateToMfgTab(0),
                                                      icon: const Icon(Icons.home_outlined, size: 18),
                                                      label: Text(loc.mfgNavHome),
                                                    ),
                                                    OutlinedButton.icon(
                                                      onPressed: () => navigateToMfgTab(2),
                                                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                                      label: Text(loc.mfgNavProducts),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return Card(
                                          child: Column(
                                            children: [
                                              for (final raw in eq)
                                                ListTile(
                                                  title: Text(
                                                    Map<String, dynamic>.from(raw)['label']?.toString() ??
                                                        loc.trainReqDashNone,
                                                  ),
                                                  subtitle: Text(
                                                    _analyticsBreakdownSubtitle(
                                                      loc,
                                                      Map<String, dynamic>.from(raw),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(l.mfgAnalyticsSectionMonthlyTrend, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 6),
                                    Text(
                                      l.mfgAnalyticsMonthlyTrendIntro,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                    ),
                                    const SizedBox(height: 10),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: _buildMonthlyTrendCombined(
                                          l,
                                          (_analyticsSummary!['monthly_trend'] as List<dynamic>?) ?? [],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                                      ],
                                      if (_mfgNavIndex == 2) ...[
                                const SizedBox(height: 28),
                                Text(l.mfgOfficialTrainingTitle, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  l.mfgOfficialTrainingIntro,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _templateTitle,
                                  decoration: InputDecoration(
                                    labelText: l.mfgTemplateTitleLabel,
                                    hintText: l.mfgTemplateTitleHint,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: (_loading || !online) ? null : _createOfficialTemplate,
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                                  child: Text(l.mfgBtnCreateTemplateDraft),
                                ),
                                const SizedBox(height: 20),
                                Text(l.mfgYourTemplates, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _templatesSearchCtrl,
                                  decoration: InputDecoration(
                                    labelText: l.mfgTplSearchHint,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search_rounded),
                                      onPressed: (_loading || !online)
                                          ? null
                                          : () {
                                              _templatesSearchDebounce?.cancel();
                                              unawaited(_reloadTemplatesList());
                                            },
                                    ),
                                  ),
                                  onChanged: (_) {
                                    setState(() {});
                                    _scheduleTemplatesSearchReload();
                                  },
                                  onSubmitted: (_) {
                                    if (!online) return;
                                    _templatesSearchDebounce?.cancel();
                                    unawaited(_reloadTemplatesList());
                                  },
                                ),
                                if (_templatesSearchActive) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    l.mfgOpsServerFilterHint,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.mfgTplFilterStatusLabel,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text(l.mfgEquipStatusFilterAll),
                                        selected: _templatesStatusFilter == null,
                                        onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter(null),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(localizedTrainingLifecycleStatus(l, 'draft')),
                                          selected: _templatesStatusFilter == 'draft',
                                          onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter('draft'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(localizedTrainingLifecycleStatus(l, 'scheduled')),
                                          selected: _templatesStatusFilter == 'scheduled',
                                          onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter('scheduled'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(localizedTrainingLifecycleStatus(l, 'in_progress')),
                                          selected: _templatesStatusFilter == 'in_progress',
                                          onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter('in_progress'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(localizedTrainingLifecycleStatus(l, 'finished')),
                                          selected: _templatesStatusFilter == 'finished',
                                          onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter('finished'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(localizedTrainingLifecycleStatus(l, 'cancelled')),
                                          selected: _templatesStatusFilter == 'cancelled',
                                          onSelected: (_loading || !online) ? null : (_) => _setTemplatesStatusFilter('cancelled'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            l.mfgTplSortLabel,
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                          const SizedBox(height: 4),
                                          DropdownButton<String>(
                                            key: ValueKey<String>('mfg_tpl_sort_$_templatesSort'),
                                            isExpanded: true,
                                            value: _templatesSort,
                                            items: [
                                              DropdownMenuItem(
                                                value: 'updated_desc',
                                                child: Text(l.mfgTplSortUpdated),
                                              ),
                                              DropdownMenuItem(
                                                value: 'title_asc',
                                                child: Text(l.mfgTplSortTitleAsc),
                                              ),
                                              DropdownMenuItem(
                                                value: 'title_desc',
                                                child: Text(l.mfgTplSortTitleDesc),
                                              ),
                                              DropdownMenuItem(
                                                value: 'status_asc',
                                                child: Text(l.mfgTplSortStatus),
                                              ),
                                            ],
                                            onChanged: (_loading || !online)
                                                ? null
                                                : (v) {
                                                    if (v != null) _setTemplatesSort(v);
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_templatesFiltersDirty)
                                      TextButton(
                                        onPressed: (_loading || !online) ? null : _clearTemplatesFilters,
                                        child: Text(l.mfgTplClearFilters),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.mfgTplListResultCount(_templates.length),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_templates.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _templatesFiltersDirty
                                        ? Text(
                                            l.mfgTplNoMatches,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                          )
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l.mfgTemplatesEmpty,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(0),
                                                    icon: const Icon(Icons.home_outlined, size: 18),
                                                    label: Text(l.mfgNavHome),
                                                  ),
                                                  OutlinedButton.icon(
                                                    onPressed: () => navigateToMfgTab(3),
                                                    icon: const Icon(Icons.settings_suggest_outlined, size: 18),
                                                    label: Text(l.mfgNavOperations),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  )
                                else
                                  ..._templates.map((row) {
                                    final id = _parseTrainingId(row['id']);
                                    final ttitle = row['title']?.toString() ?? l.mfgTrainingFallbackTitle;
                                    final updatedLine = _formatTemplateRowUpdated(l, row['updated_at']);
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(ttitle),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(localizedTrainingLifecycleStatus(l, row['status']?.toString())),
                                            if (updatedLine.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  updatedLine,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF64748B),
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: id != null
                                            ? TextButton(
                                                onPressed: (_loading || !online) ? null : () => _openTemplateEditor(id, ttitle),
                                                child: Text(l.mfgBtnEditQuestionnaire),
                                              )
                                            : null,
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 32),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(l.mfgCatalogSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                                    ),
                                    FilledButton.icon(
                                      onPressed: (_loading || !online) ? null : () => unawaited(_openEquipmentWizard()),
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(l.mfgDashNewEquipment),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l.mfgCatalogIntro,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _equipmentSearchCtrl,
                                  decoration: InputDecoration(
                                    labelText: l.mfgEquipSearchHint,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.search_rounded),
                                      onPressed: (_loading || !online)
                                          ? null
                                          : () {
                                              _equipmentSearchDebounce?.cancel();
                                              unawaited(_reloadEquipmentList());
                                            },
                                    ),
                                  ),
                                  onChanged: (_) {
                                    setState(() {});
                                    _scheduleEquipmentSearchReload();
                                  },
                                  onSubmitted: (_) {
                                    if (!online) return;
                                    _equipmentSearchDebounce?.cancel();
                                    unawaited(_reloadEquipmentList());
                                  },
                                ),
                                if (_equipmentSearchActive) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    l.mfgOpsServerFilterHint,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(l.mfgEquipFilterStatusLabel, style: Theme.of(context).textTheme.titleSmall),
                                ),
                                const SizedBox(height: 6),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text(l.mfgEquipStatusFilterAll),
                                        selected: _equipmentStatusFilter == null,
                                        onSelected: (_loading || !online) ? null : (_) => _setEquipmentStatusFilter(null),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(l.mfgEquipStatusActive),
                                          selected: _equipmentStatusFilter == 'active',
                                          onSelected: (_loading || !online) ? null : (_) => _setEquipmentStatusFilter('active'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: ChoiceChip(
                                          label: Text(l.mfgEquipStatusInactive),
                                          selected: _equipmentStatusFilter == 'inactive',
                                          onSelected: (_loading || !online) ? null : (_) => _setEquipmentStatusFilter('inactive'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.mfgFilterListLabel,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text(l.parkFilterChipAll),
                                        selected: _equipmentCategoryFilter == null,
                                        onSelected: (_loading || !online)
                                            ? null
                                            : (_) => _setEquipmentCategoryFilter(null),
                                      ),
                                      ..._categoryCatalog.map((c) {
                                        final cid = c['id']?.toString() ?? '';
                                        final clabel = c['label']?.toString() ?? cid;
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: ChoiceChip(
                                            label: Text(clabel),
                                            selected: _equipmentCategoryFilter == cid,
                                            onSelected: (_loading || !online)
                                                ? null
                                                : (_) => _setEquipmentCategoryFilter(cid),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            l.mfgEquipSortLabel,
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                          const SizedBox(height: 4),
                                          DropdownButton<String>(
                                            key: ValueKey<String>('mfg_eq_sort_$_equipmentSort'),
                                            isExpanded: true,
                                            value: _equipmentSort,
                                            items: [
                                              DropdownMenuItem(
                                                value: 'name_asc',
                                                child: Text(l.mfgEquipSortName),
                                              ),
                                              DropdownMenuItem(
                                                value: 'updated_desc',
                                                child: Text(l.mfgEquipSortUpdated),
                                              ),
                                              DropdownMenuItem(
                                                value: 'templates_desc',
                                                child: Text(l.mfgEquipSortTemplates),
                                              ),
                                            ],
                                            onChanged: (_loading || !online)
                                                ? null
                                                : (v) {
                                                    if (v != null) _setEquipmentSort(v);
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_equipmentFiltersDirty)
                                      TextButton(
                                        onPressed: (_loading || !online) ? null : _clearEquipmentFilters,
                                        child: Text(l.mfgEquipClearFilters),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.mfgEquipListResultCount(_equipment.length),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_equipment.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: _equipmentFiltersDirty
                                          ? Text(
                                              l.mfgOpsSublistNoMatch,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                            )
                                          : ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 420),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    l.mfgEquipmentEmpty,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Wrap(
                                                    alignment: WrapAlignment.center,
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      OutlinedButton.icon(
                                                        onPressed: () => navigateToMfgTab(0),
                                                        icon: const Icon(Icons.home_outlined, size: 18),
                                                        label: Text(l.mfgNavHome),
                                                      ),
                                                      OutlinedButton.icon(
                                                        onPressed: () => navigateToMfgTab(3),
                                                        icon: const Icon(Icons.settings_suggest_outlined, size: 18),
                                                        label: Text(l.mfgNavOperations),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  )
                                else
                                  ..._equipment.map((row) {
                                    final id = row['id'];
                                    final iid = id is int ? id : int.tryParse(id.toString());
                                    final title = row['name']?.toString() ?? '';
                                    final model = row['model']?.toString() ?? '';
                                    final catRaw = row['category']?.toString();
                                    final catPrefix =
                                        (catRaw != null && catRaw.isNotEmpty) ? '${_categoryLabel(catRaw)} · ' : '';
                                    final pid = row['parent_equipment_id'];
                                    final parentId = pid is int ? pid : int.tryParse(pid?.toString() ?? '');
                                    final lineage = parentId != null
                                        ? '$catPrefix${l.mfgEquipmentDerivedFrom(parentId, model)}'
                                        : '$catPrefix$model';
                                    final hasImg = row['has_image'] == true;
                                    final tmplRaw = row['official_templates_count'];
                                    final tmplCount = tmplRaw is int
                                        ? tmplRaw
                                        : int.tryParse(tmplRaw?.toString() ?? '') ?? 0;
                                    final serial = row['serial_number']?.toString();
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        leading: iid == null
                                            ? const CircleAvatar(
                                                backgroundColor: Color(0xFFE2E8F0),
                                                child: Icon(
                                                  Icons.medical_services_outlined,
                                                  color: Color(0xFF475569),
                                                ),
                                              )
                                            : _ManufacturerEquipmentThumb(
                                                api: _api,
                                                equipmentId: iid,
                                                hasImage: hasImg,
                                              ),
                                        title: Text(title),
                                        isThreeLine: serial != null && serial.isNotEmpty,
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(lineage),
                                            if (serial != null && serial.isNotEmpty)
                                              Text(serial, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                            Text(
                                              l.mfgEquipTemplatesCount(tmplCount),
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                        trailing: iid == null
                                            ? null
                                            : Wrap(
                                                spacing: 0,
                                                children: [
                                                  TextButton(
                                                    onPressed: (_loading || !online)
                                                        ? null
                                                        : () => unawaited(_openEquipmentWizard(
                                                              editEquipment: Map<String, dynamic>.from(row),
                                                            )),
                                                    child: Text(l.mfgBtnEditEquipment),
                                                  ),
                                                  TextButton(
                                                    onPressed: (_loading || !online)
                                                        ? null
                                                        : () => unawaited(_startNewEquipmentVersion(
                                                              iid,
                                                              title,
                                                              model,
                                                              catRaw,
                                                            )),
                                                    child: Text(l.mfgBtnNewVersion),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline),
                                                    onPressed: (_loading || !online) ? null : () => _deleteEquipment(iid),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  }),
                                      ],
                              ],
                            ),
                          ),
                        ),
                            ],
                          ),
              ),
            ],
          ),
          const Positioned(right: 16, bottom: 16, child: VersionBadge()),
        ],
      ),
    );
  }
}

/// Miniatura da imagem do equipamento (download autenticado); ícone se não houver ou falhar.
class _ManufacturerEquipmentThumb extends StatefulWidget {
  const _ManufacturerEquipmentThumb({
    required this.api,
    required this.equipmentId,
    required this.hasImage,
  });

  final ProductionApi api;
  final int equipmentId;
  final bool hasImage;

  @override
  State<_ManufacturerEquipmentThumb> createState() => _ManufacturerEquipmentThumbState();
}

class _ManufacturerEquipmentThumbState extends State<_ManufacturerEquipmentThumb> {
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
      final b = await widget.api.downloadManufacturerEquipmentAttachment(t, widget.equipmentId, 'image');
      if (mounted) setState(() => _bytes = b);
    } catch (_) {
      // Mantém ícone de recurso.
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
                  widget.hasImage ? Icons.broken_image_outlined : Icons.medical_services_outlined,
                  color: const Color(0xFF475569),
                  size: 22,
                ),
        ),
      ),
    );
  }
}

/// Menu lateral fixo: grupos «Resumo e cadastro» / «Oferta e rotina».
class _MfgSideNav extends StatelessWidget {
  const _MfgSideNav({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groupStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.45,
        );

    return Material(
      color: Colors.white,
      elevation: 0,
      child: SizedBox(
        width: 232,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
              child: Text(
                l.mfgNavGroupSummary.toUpperCase(),
                style: groupStyle,
              ),
            ),
            _MfgSideTile(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: l.mfgNavHome,
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _MfgSideTile(
              icon: Icons.business_outlined,
              selectedIcon: Icons.business_rounded,
              label: l.mfgNavCompany,
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: Text(
                l.mfgNavGroupOffer.toUpperCase(),
                style: groupStyle,
              ),
            ),
            _MfgSideTile(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2_rounded,
              label: l.mfgNavProducts,
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
            _MfgSideTile(
              icon: Icons.settings_suggest_outlined,
              selectedIcon: Icons.settings_suggest_rounded,
              label: l.mfgNavOperations,
              selected: selectedIndex == 3,
              onTap: () => onSelect(3),
            ),
            _MfgSideTile(
              icon: Icons.verified_user_outlined,
              selectedIcon: Icons.verified_user_rounded,
              label: l.mfgNavHomologations,
              selected: selectedIndex == 4,
              onTap: () => onSelect(4),
            ),
            _MfgSideTile(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics_rounded,
              label: l.mfgNavAnalytics,
              selected: selectedIndex == 5,
              onTap: () => onSelect(5),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _MfgSideTile extends StatelessWidget {
  const _MfgSideTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? const Color(0xFF0F766E) : const Color(0xFF334155);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? const Color(0xFFE0F2F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: const Color(0xFF0F766E).withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(selected ? selectedIcon : icon, size: 22, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa horizontal: etapas de credenciação do fabricante (dados → análise → homologação).
class _ValidationFlowStrip extends StatelessWidget {
  const _ValidationFlowStrip({required this.status});

  final String? status;

  /// Etapas 0–1 concluídas (check); etapa 2 é o resultado (ativo / recusado).
  static bool _isComplete(int stepIndex, String? raw) {
    switch (raw) {
      case 'pending_validation':
        return stepIndex == 0;
      case 'active':
      case 'rejected':
        return stepIndex == 0 || stepIndex == 1;
      default:
        return false;
    }
  }

  static bool _isCurrent(int stepIndex, String? raw) {
    switch (raw) {
      case 'pending_info':
        return stepIndex == 0;
      case 'pending_validation':
        return stepIndex == 1;
      case 'active':
      case 'rejected':
        return stepIndex == 2;
      default:
        return stepIndex == 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final raw = status;
    final labels = [l.mfgFlowStepCompany, l.mfgFlowStepFluxxoReview, l.mfgFlowStepHomologation];
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 420;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (narrow)
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
                  child: _ValidationStepTile(
                    index: i,
                    label: labels[i],
                    status: raw,
                    isDone: _isComplete(i, raw),
                    isCurrent: _isCurrent(i, raw),
                    isLast: i == 2,
                  ),
                )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: _ValidationStepTile(
                        index: i,
                        label: labels[i],
                        status: raw,
                        isDone: _isComplete(i, raw),
                        isCurrent: _isCurrent(i, raw),
                        isLast: i == 2,
                      ),
                    ),
                    if (i < 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ValidationStepTile extends StatelessWidget {
  const _ValidationStepTile({
    required this.index,
    required this.label,
    required this.status,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final int index;
  final String label;
  final String? status;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    late final Color ring;
    late final Color fill;
    late final Widget mark;

    if (isLast && status == 'rejected') {
      ring = const Color(0xFFEF4444);
      fill = const Color(0xFFFFF1F2);
      mark = const Icon(Icons.close_rounded, size: 16, color: Color(0xFFB91C1C));
    } else if (isLast && status == 'active') {
      ring = const Color(0xFF10B981);
      fill = const Color(0xFFE8FFF4);
      mark = const Icon(Icons.check_rounded, size: 16, color: Color(0xFF065F46));
    } else if (isDone) {
      ring = const Color(0xFF94A3B8);
      fill = const Color(0xFFF1F5F9);
      mark = Icon(Icons.check_rounded, size: 16, color: Colors.blueGrey.shade600);
    } else if (isCurrent) {
      ring = const Color(0xFF0F766E);
      fill = const Color(0xFFE0F2F1);
      mark = Text(
        '${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F766E)),
      );
    } else {
      ring = const Color(0xFFCBD5E1);
      fill = const Color(0xFFF8FAFC);
      mark = Text(
        '${index + 1}',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.blueGrey.shade400),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2),
          ),
          alignment: Alignment.center,
          child: mark,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                color: const Color(0xFF334155),
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashKpi extends StatelessWidget {
  const _DashKpi({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF45464D))),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ValidationStatusCard extends StatelessWidget {
  const _ValidationStatusCard({
    required this.manufacturer,
    required this.loading,
    required this.apiOnline,
    required this.onRequestValidation,
  });

  final Map<String, dynamic> manufacturer;
  final bool loading;
  final bool apiOnline;
  final VoidCallback onRequestValidation;

  String _helpText(AppLocalizations l, String? raw) {
    switch (raw) {
      case 'pending_info':
        return l.mfgValHelpPendingInfo;
      case 'pending_validation':
        return l.mfgValHelpPendingValidation;
      case 'active':
        return l.mfgValHelpActive;
      case 'rejected':
        return l.mfgValHelpRejected;
      default:
        return l.mfgValHelpDefault;
    }
  }

  static Color _accent(String? raw) {
    switch (raw) {
      case 'active':
        return const Color(0xFF10B981);
      case 'pending_validation':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'pending_info':
      default:
        return const Color(0xFF64748B);
    }
  }

  static bool _canSubmit(String? raw) {
    return raw == 'pending_info' || raw == 'rejected';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final raw = manufacturer['validation_status']?.toString();
    final accent = _accent(raw);
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_outlined, color: accent, size: 22),
                const SizedBox(width: 10),
                Text(
                  l.mfgValidationTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ValidationFlowStrip(status: raw),
            const SizedBox(height: 12),
            Text(
              l.mfgValidationStateLine(localizedManufacturerValidationStatus(l, raw)),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: accent),
            ),
            const SizedBox(height: 8),
            Text(
              _helpText(l, raw),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D), height: 1.4),
            ),
            if (_canSubmit(raw)) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: (loading || !apiOnline) ? null : onRequestValidation,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                child: Text(raw == 'rejected' ? l.mfgBtnResubmitForReview : l.mfgBtnSubmitForReview),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
