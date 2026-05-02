import 'dart:async';

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
import 'manufacturer_template_editor.dart';

/// Área do fabricante: perfil da empresa e catálogo de equipamentos (instituição nula).
class ManufacturerShell extends StatefulWidget {
  const ManufacturerShell({super.key});

  @override
  State<ManufacturerShell> createState() => _ManufacturerShellState();
}

class _ManufacturerShellState extends State<ManufacturerShell> {
  final _api = ProductionApi(ApiClient());

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _manufacturer;
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _prizes = [];
  List<Map<String, dynamic>> _categoryCatalog = [];
  Map<String, dynamic>? _dashboardSummary;

  /// Secção principal (menu inferior): 0 Início, 1 Empresa, 2 Produtos, 3 Operações.
  int _mfgNavIndex = 0;

  final ScrollController _mfgScrollController = ScrollController();

  /// Filtro do catálogo (id da categoria ou null = todos).
  String? _equipmentCategoryFilter;

  /// Categoria escolhida para o próximo registo (id alinhado à API).
  String? _eqCategoryId;

  /// Se não nulo, o próximo «Adicionar ao catálogo» cria uma nova versão (POST com parent_equipment_id).
  int? _eqVersionParentId;

  final _name = TextEditingController();
  final _supportEmail = TextEditingController();
  final _cnpj = TextEditingController();

  final _eqName = TextEditingController();
  final _eqModel = TextEditingController();
  final _eqSector = TextEditingController();
  final _templateTitle = TextEditingController();
  final _docKind = TextEditingController();
  final _docNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _supportEmail.dispose();
    _cnpj.dispose();
    _eqName.dispose();
    _eqModel.dispose();
    _eqSector.dispose();
    _templateTitle.dispose();
    _docKind.dispose();
    _docNotes.dispose();
    _mfgScrollController.dispose();
    super.dispose();
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
      Map<String, dynamic>? dash;
      try {
        dash = await _api.manufacturerDashboardSummary(t);
      } catch (_) {
        dash = null;
      }
      var cats = _categoryCatalog;
      if (cats.isEmpty) {
        try {
          cats = await _api.equipmentCategoriesCatalog(t);
        } catch (_) {
          cats = [];
        }
      }
      final list = await _api.manufacturerEquipmentList(t, category: _equipmentCategoryFilter);
      final templates = await _api.manufacturerTemplates(t);
      final docs = await _api.listManufacturerDocuments(t);
      List<Map<String, dynamic>> seasons = [];
      try {
        seasons = await _api.manufacturerSeasons(t);
      } catch (_) {
        seasons = [];
      }
      List<Map<String, dynamic>> prizes = [];
      try {
        prizes = await _api.manufacturerPrizes(t);
      } catch (_) {
        prizes = [];
      }
      if (!mounted) return;
      setState(() {
        _manufacturer = m;
        _dashboardSummary = dash;
        _categoryCatalog = cats;
        _equipment = list;
        _templates = templates;
        _documents = docs;
        _seasons = seasons;
        _prizes = prizes;
        _name.text = m['name']?.toString() ?? '';
        _supportEmail.text = m['support_email']?.toString() ?? '';
        _cnpj.text = m['cnpj']?.toString() ?? '';
        _loading = false;
      });
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
    if (!downloadBytesSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).dashExportCsvWebOnly)),
        );
      }
      return;
    }
    try {
      final bytes = await _api.manufacturerDashboardExportCsv(t);
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
    if (!downloadBytesSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).dashExportPdfWebOnly)),
        );
      }
      return;
    }
    try {
      final bytes = await _api.manufacturerDashboardExportPdf(t);
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

  void _cancelEquipmentVersionDraft() {
    setState(() {
      _eqVersionParentId = null;
    });
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
    _reload();
  }

  void _startNewEquipmentVersion(int parentId, String name, String model, String? categoryId) {
    setState(() {
      _eqVersionParentId = parentId;
      _eqName.text = name;
      _eqModel.text = model;
      _eqCategoryId = categoryId;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).mfgSnackVersionDraftHint(parentId))),
    );
  }

  Future<void> _addEquipment() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_eqName.text.trim().isEmpty || _eqModel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mfgSnackNameModelRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final wasVersion = _eqVersionParentId != null;
      await _api.createManufacturerEquipment(
        t,
        name: _eqName.text.trim(),
        model: _eqModel.text.trim(),
        sector: _eqSector.text.trim().isEmpty ? null : _eqSector.text.trim(),
        category: _eqCategoryId,
        parentEquipmentId: _eqVersionParentId,
      );
      if (mounted) {
        setState(() {
          _eqName.clear();
          _eqModel.clear();
          _eqSector.clear();
          _eqCategoryId = null;
          _eqVersionParentId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasVersion ? AppLocalizations.of(context).mfgSnackNewVersionRegistered : AppLocalizations.of(context).mfgSnackEquipmentCreated,
            ),
          ),
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
                        TextButton(onPressed: () => appAuth.logout(), child: Text(l.actionSignOut)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _loading && _manufacturer == null
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _manufacturer == null
                        ? Center(
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
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _MfgSideNav(
                                selectedIndex: _mfgNavIndex,
                                onSelect: (i) {
                                  setState(() {
                                    _mfgNavIndex = i;
                                    if (_mfgScrollController.hasClients) {
                                      _mfgScrollController.jumpTo(0);
                                    }
                                  });
                                },
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
                                      if (_mfgNavIndex == 0) ...[
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
                                                onPressed: _loading ? null : () => unawaited(_exportManufacturerDashboardCsv()),
                                                icon: const Icon(Icons.table_chart_outlined, size: 20),
                                                label: Text(l.dashExportCsv),
                                              ),
                                              OutlinedButton.icon(
                                                onPressed: _loading ? null : () => unawaited(_exportManufacturerDashboardPdf()),
                                                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                                label: Text(l.dashExportPdf),
                                              ),
                                            ],
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
                                  onRequestValidation: _requestValidation,
                                ),
                                const SizedBox(height: 16),
                                      ],
                                      if (_mfgNavIndex == 3) ...[
                                Row(
                                  children: [
                                    Expanded(child: Text(l.mfgSeasonsSectionTitle, style: Theme.of(context).textTheme.titleLarge)),
                                    TextButton.icon(
                                      onPressed: _loading ? null : _showCreateSeasonDialog,
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
                                    child: Text(
                                      l.mfgSeasonsEmpty,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
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
                                                  onPressed: _loading
                                                      ? null
                                                      : () {
                                                          final id = _parseTrainingId(s['id']);
                                                          if (id != null) unawaited(_showSeasonLeaderboard(id));
                                                        },
                                                ),
                                                IconButton(
                                                  tooltip: l.mfgTooltipRecompute,
                                                  icon: const Icon(Icons.refresh_rounded),
                                                  onPressed: _loading
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
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: Text(l.mfgPrizesSectionTitle, style: Theme.of(context).textTheme.titleLarge)),
                                    TextButton.icon(
                                      onPressed: _loading ? null : _showAddPrizeDialog,
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
                                      l.mfgPrizesEmpty,
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
                                              onPressed: _loading
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
                                  onPressed: _loading ? null : _pickAndUploadDocument,
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: Text(l.mfgBtnSendFile),
                                ),
                                const SizedBox(height: 16),
                                if (_documents.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      l.mfgDocumentsEmpty,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                    ),
                                  )
                                else
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
                                              onPressed: _loading || iid == null ? null : () => _downloadDocument(row),
                                            ),
                                            IconButton(
                                              tooltip: l.mfgBtnRemove,
                                              icon: const Icon(Icons.delete_outline),
                                              onPressed: _loading || iid == null ? null : () => _deleteDocument(iid),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
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
                                  onPressed: _loading ? null : _saveProfile,
                                  child: Text(l.mfgBtnSaveProfile),
                                ),
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
                                  onPressed: _loading ? null : _createOfficialTemplate,
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                                  child: Text(l.mfgBtnCreateTemplateDraft),
                                ),
                                const SizedBox(height: 20),
                                Text(l.mfgYourTemplates, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                if (_templates.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      l.mfgTemplatesEmpty,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                    ),
                                  )
                                else
                                  ..._templates.map((row) {
                                    final id = _parseTrainingId(row['id']);
                                    final ttitle = row['title']?.toString() ?? l.mfgTrainingFallbackTitle;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(ttitle),
                                        subtitle: Text(localizedTrainingLifecycleStatus(l, row['status']?.toString())),
                                        trailing: id != null
                                            ? TextButton(
                                                onPressed: _loading ? null : () => _openTemplateEditor(id, ttitle),
                                                child: Text(l.mfgBtnEditQuestionnaire),
                                              )
                                            : null,
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 32),
                                Text(l.mfgCatalogSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  l.mfgCatalogIntro,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                if (_eqVersionParentId != null) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      spacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          l.mfgNewVersionFromRecord(_eqVersionParentId!),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                        TextButton(onPressed: _cancelEquipmentVersionDraft, child: Text(l.mfgBtnCancel)),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _eqName,
                                  decoration: InputDecoration(labelText: l.mfgFieldEquipmentName),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _eqModel,
                                  decoration: InputDecoration(labelText: l.mfgFieldModel),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _eqSector,
                                  decoration: InputDecoration(labelText: l.mfgFieldSectorOptionalCatalog),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.mfgCategoryOptionalLabel,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButton<String?>(
                                  isExpanded: true,
                                  value: _eqCategoryId,
                                  hint: Text(l.trainReqDashNone),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(l.trainReqDashNone),
                                    ),
                                    ..._categoryCatalog.map((c) {
                                      final cid = c['id']?.toString() ?? '';
                                      return DropdownMenuItem<String?>(
                                        value: cid,
                                        child: Text(c['label']?.toString() ?? cid),
                                      );
                                    }),
                                  ],
                                  onChanged: _loading
                                      ? null
                                      : (v) => setState(() => _eqCategoryId = v),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _loading ? null : _addEquipment,
                                  child: Text(l.mfgBtnAddToCatalog),
                                ),
                                const SizedBox(height: 16),
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
                                        onSelected: _loading
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
                                            onSelected: _loading
                                                ? null
                                                : (_) => _setEquipmentCategoryFilter(cid),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_equipment.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: Text(l.mfgEquipmentEmpty)),
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
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(title),
                                        subtitle: Text(lineage),
                                        trailing: iid == null
                                            ? null
                                            : Wrap(
                                                spacing: 0,
                                                children: [
                                                  TextButton(
                                                    onPressed: _loading
                                                        ? null
                                                        : () => _startNewEquipmentVersion(
                                                              iid,
                                                              title,
                                                              model,
                                                              catRaw,
                                                            ),
                                                    child: Text(l.mfgBtnNewVersion),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline),
                                                    onPressed: _loading ? null : () => _deleteEquipment(iid),
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
    required this.onRequestValidation,
  });

  final Map<String, dynamic> manufacturer;
  final bool loading;
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
                onPressed: loading ? null : onRequestValidation,
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
