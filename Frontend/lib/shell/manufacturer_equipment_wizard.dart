import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';

class _SpecRow {
  _SpecRow()
      : label = TextEditingController(),
        value = TextEditingController();

  final TextEditingController label;
  final TextEditingController value;

  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class _PendingFile {
  const _PendingFile({required this.filename, this.bytes, this.path});

  final String filename;
  final List<int>? bytes;
  final String? path;
}

/// Fluxo em 2 passos: identificação/ficha e pré-definições + anexos.
/// Criação (`editEquipment` nulo) ou edição (`editEquipment` preenchido).
class ManufacturerEquipmentWizardScreen extends StatefulWidget {
  const ManufacturerEquipmentWizardScreen({
    super.key,
    required this.api,
    required this.categoryCatalog,
    this.parentEquipmentId,
    this.initialName,
    this.initialModel,
    this.initialCategoryId,
    this.editEquipment,
  }) : assert(
          editEquipment == null || parentEquipmentId == null,
          'Use editEquipment ou parentEquipmentId, não ambos.',
        );

  final ProductionApi api;
  final List<Map<String, dynamic>> categoryCatalog;
  final int? parentEquipmentId;
  final String? initialName;
  final String? initialModel;
  final String? initialCategoryId;

  /// Registo actual do catálogo (para modo edição).
  final Map<String, dynamic>? editEquipment;

  @override
  State<ManufacturerEquipmentWizardScreen> createState() => _ManufacturerEquipmentWizardScreenState();
}

class _ManufacturerEquipmentWizardScreenState extends State<ManufacturerEquipmentWizardScreen> {
  int _step = 0;
  bool _busy = false;
  bool _catsLoading = false;
  List<Map<String, dynamic>> _cats = [];

  int? _editId;
  bool _isDerivedVersion = false;

  final _name = TextEditingController();
  final _model = TextEditingController();
  final _firmware = TextEditingController();
  final _serial = TextEditingController();
  final _sector = TextEditingController();
  final _introVideoUrl = TextEditingController();
  final _defaultHours = TextEditingController();
  final _defaultPass = TextEditingController();
  final _defaultCertMo = TextEditingController();
  final _defaultReassess = TextEditingController();
  final _quantity = TextEditingController();

  String? _categoryId;
  String _status = 'active';

  final List<_SpecRow> _specRows = [];

  final Map<String, _PendingFile?> _pending = {
    'image': null,
    'operator_manual': null,
    'maintenance_manual': null,
    'datasheet': null,
    'intro_video': null,
  };

  bool get _isEdit => _editId != null;

  bool get _categoryRequired => widget.parentEquipmentId == null && !_isDerivedVersion;

  @override
  void initState() {
    super.initState();
    _cats = List<Map<String, dynamic>>.from(widget.categoryCatalog);

    if (widget.editEquipment != null) {
      _hydrateFromEquipment(Map<String, dynamic>.from(widget.editEquipment!));
    } else {
      _name.text = widget.initialName ?? '';
      _model.text = widget.initialModel ?? '';
      _categoryId = widget.initialCategoryId;
    }

    if (_cats.isEmpty) {
      _catsLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_loadCategories()));
    }
  }

  void _hydrateFromEquipment(Map<String, dynamic> eq) {
    final rawId = eq['id'];
    _editId = rawId is int ? rawId : int.tryParse(rawId.toString());
    _isDerivedVersion = eq['parent_equipment_id'] != null;

    _name.text = eq['name']?.toString() ?? '';
    _model.text = eq['model']?.toString() ?? '';
    _firmware.text = eq['firmware_version']?.toString() ?? '';
    _serial.text = eq['serial_number']?.toString() ?? '';
    _sector.text = eq['sector']?.toString() ?? '';
    _introVideoUrl.text = eq['intro_video_url']?.toString() ?? '';
    _categoryId = eq['category']?.toString();
    final st = eq['status']?.toString().trim();
    _status = (st != null && st.isNotEmpty) ? st : 'active';

    void putInt(TextEditingController c, dynamic v) {
      if (v == null) {
        c.text = '';
        return;
      }
      c.text = v.toString();
    }

    putInt(_defaultHours, eq['default_training_hours']);
    putInt(_defaultPass, eq['default_passing_score_percent']);
    putInt(_defaultCertMo, eq['default_certificate_validity_months']);
    putInt(_defaultReassess, eq['default_reassessment_days']);
    putInt(_quantity, eq['quantity']);

    final specs = eq['technical_specs'];
    if (specs is List<dynamic>) {
      for (final item in specs) {
        if (item is Map) {
          final row = _SpecRow();
          row.label.text = item['label']?.toString() ?? '';
          row.value.text = item['value']?.toString() ?? '';
          _specRows.add(row);
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    final t = appAuth.token;
    if (t == null || !mounted) return;
    try {
      final list = await widget.api.equipmentCategoriesCatalog(t);
      if (!mounted) return;
      setState(() {
        _cats = list;
        _catsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _catsLoading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _model.dispose();
    _firmware.dispose();
    _serial.dispose();
    _sector.dispose();
    _introVideoUrl.dispose();
    _defaultHours.dispose();
    _defaultPass.dispose();
    _defaultCertMo.dispose();
    _defaultReassess.dispose();
    _quantity.dispose();
    for (final r in _specRows) {
      r.dispose();
    }
    super.dispose();
  }

  int? _parseOptionalInt(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  String? _trimOrNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Map<String, dynamic> _collectUpdateBody() {
    final specs = <Map<String, String>>[];
    for (final row in _specRows) {
      final lb = row.label.text.trim();
      final vl = row.value.text.trim();
      if (lb.isNotEmpty && vl.isNotEmpty) {
        specs.add({'label': lb, 'value': vl});
      }
    }

    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'model': _model.text.trim(),
      'firmware_version': _trimOrNull(_firmware.text),
      'serial_number': _trimOrNull(_serial.text),
      'sector': _trimOrNull(_sector.text),
      'category': (_categoryId == null || _categoryId!.isEmpty) ? null : _categoryId,
      'technical_specs': specs.isEmpty ? null : specs,
      'intro_video_url': _trimOrNull(_introVideoUrl.text),
      'default_training_hours': _parseOptionalInt(_defaultHours),
      'default_passing_score_percent': _parseOptionalInt(_defaultPass),
      'default_certificate_validity_months': _parseOptionalInt(_defaultCertMo),
      'default_reassessment_days': _parseOptionalInt(_defaultReassess),
      'status': _status,
    };

    final q = _parseOptionalInt(_quantity);
    if (q != null) {
      body['quantity'] = q;
    }

    return body;
  }

  Future<void> _pick(String key, List<String> extensions) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.single;
    final name = f.name;
    if (f.bytes != null && f.bytes!.isNotEmpty) {
      setState(() => _pending[key] = _PendingFile(filename: name, bytes: f.bytes));
    } else if (f.path != null && f.path!.isNotEmpty) {
      setState(() => _pending[key] = _PendingFile(filename: name, path: f.path));
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final t = appAuth.token;
    if (t == null) return;

    if (_name.text.trim().isEmpty || _model.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgSnackNameModelRequired)));
      return;
    }

    if (_categoryRequired && (_categoryId == null || _categoryId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgEquipSnackCategoryRequired)));
      return;
    }

    final specs = <Map<String, String>>[];
    for (final row in _specRows) {
      final lb = row.label.text.trim();
      final vl = row.value.text.trim();
      if (lb.isNotEmpty && vl.isNotEmpty) {
        specs.add({'label': lb, 'value': vl});
      }
    }

    setState(() => _busy = true);
    var navigated = false;
    var uploadFailed = false;
    try {
      late final int id;

      if (_editId != null) {
        await widget.api.updateManufacturerEquipment(t, _editId!, _collectUpdateBody());
        id = _editId!;
      } else {
        final created = await widget.api.createManufacturerEquipment(
          t,
          name: _name.text.trim(),
          model: _model.text.trim(),
          sector: _sector.text.trim().isEmpty ? null : _sector.text.trim(),
          category: _categoryRequired ? _categoryId : ((_categoryId?.isEmpty ?? true) ? null : _categoryId),
          parentEquipmentId: widget.parentEquipmentId,
          firmwareVersion: _firmware.text.trim().isEmpty ? null : _firmware.text.trim(),
          serialNumber: _serial.text.trim().isEmpty ? null : _serial.text.trim(),
          technicalSpecs: specs.isEmpty ? null : specs,
          introVideoUrl: _introVideoUrl.text.trim().isEmpty ? null : _introVideoUrl.text.trim(),
          defaultTrainingHours: _parseOptionalInt(_defaultHours),
          defaultPassingScorePercent: _parseOptionalInt(_defaultPass),
          defaultCertificateValidityMonths: _parseOptionalInt(_defaultCertMo),
          defaultReassessmentDays: _parseOptionalInt(_defaultReassess),
          quantity: _parseOptionalInt(_quantity),
          status: _status,
        );

        final rawId = created['id'];
        final parsed = rawId is int ? rawId : int.tryParse(rawId.toString());
        if (parsed == null) {
          throw ApiException(l.mfgLoadFailedData, 0, reason: LocalizedApiReason.operationIncomplete);
        }
        id = parsed;
      }

      Future<void> up(String type, _PendingFile? file) async {
        if (file == null) return;
        await widget.api.uploadManufacturerEquipmentAttachment(
          t,
          id,
          attachmentType: type,
          filename: file.filename,
          fileBytes: file.bytes,
          filePath: file.path,
        );
      }

      for (final e in _pending.entries) {
        try {
          await up(e.key, e.value);
        } catch (_) {
          uploadFailed = true;
        }
      }

      if (!mounted) return;
      if (uploadFailed) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgEquipSnackPartialUpload)));
      }
      Navigator.of(context).pop(true);
      navigated = true;
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted && !navigated) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.mfgEquipWizardEditTitle : l.mfgEquipWizardTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            _step == 0 ? l.mfgEquipWizardStep1 : l.mfgEquipWizardStep2,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_step == 0) ...[
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l.mfgFieldEquipmentName),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _model,
              decoration: InputDecoration(labelText: l.mfgFieldModel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _firmware,
              decoration: InputDecoration(labelText: l.mfgEquipFieldFirmware),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serial,
              decoration: InputDecoration(labelText: l.mfgEquipFieldSerial),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sector,
              decoration: InputDecoration(labelText: l.mfgFieldSectorOptionalCatalog),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _categoryRequired ? l.mfgEquipCategoryRequired : l.mfgCategoryOptionalLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 4),
            if (_catsLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DropdownButtonFormField<String?>(
                value: _categoryId,
                decoration: InputDecoration(
                  hintText: l.trainReqDashNone,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l.trainReqDashNone),
                  ),
                  ..._cats.map((c) {
                    final cid = c['id']?.toString() ?? '';
                    return DropdownMenuItem<String?>(
                      value: cid,
                      child: Text(c['label']?.toString() ?? cid),
                    );
                  }),
                ],
                onChanged: _busy
                    ? null
                    : (v) => setState(() => _categoryId = v),
              ),
            const SizedBox(height: 16),
            Text(l.mfgEquipSpecsTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ..._specRows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: row.label,
                        decoration: InputDecoration(labelText: l.mfgEquipSpecLabel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row.value,
                        decoration: InputDecoration(labelText: l.mfgEquipSpecValue),
                      ),
                    ),
                    IconButton(
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                row.dispose();
                                _specRows.remove(row);
                              });
                            },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => setState(() => _specRows.add(_SpecRow())),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.mfgEquipAddSpecRow),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _introVideoUrl,
              decoration: InputDecoration(labelText: l.mfgEquipFieldIntroVideoUrl),
            ),
          ] else ...[
            Text(l.mfgEquipDefaultsTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _defaultHours,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mfgEquipDefaultTrainingHours),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _defaultPass,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mfgEquipDefaultPassingScore),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _defaultCertMo,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mfgEquipDefaultCertMonths),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _defaultReassess,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mfgEquipDefaultReassessmentDays),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.mfgEquipFieldQuantity),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l.mfgEquipFieldStatus, style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _status,
              items: [
                DropdownMenuItem(value: 'active', child: Text(l.mfgEquipStatusActive)),
                DropdownMenuItem(value: 'inactive', child: Text(l.mfgEquipStatusInactive)),
              ],
              onChanged: _busy ? null : (v) => setState(() => _status = v ?? 'active'),
            ),
            const SizedBox(height: 20),
            Text(l.mfgEquipAttachmentsTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _attachmentRow(l.mfgEquipAttachImage, 'image', const ['jpg', 'jpeg', 'png']),
            _attachmentRow(l.mfgEquipAttachManualOp, 'operator_manual', const ['pdf']),
            _attachmentRow(l.mfgEquipAttachManualMaint, 'maintenance_manual', const ['pdf']),
            _attachmentRow(l.mfgEquipAttachDatasheet, 'datasheet', const ['pdf']),
            _attachmentRow(l.mfgEquipAttachIntroVideo, 'intro_video', const ['mp4']),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: _busy ? null : () => setState(() => _step -= 1),
                  child: Text(l.mfgEquipWizardBack),
                ),
              const Spacer(),
              if (_step == 0)
                FilledButton(
                  onPressed: _busy ? null : () => setState(() => _step = 1),
                  child: Text(l.mfgEquipWizardNext),
                )
              else
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? l.mfgEquipWizardSaveChanges : l.mfgEquipWizardSubmit),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attachmentRow(String label, String key, List<String> ext) {
    final loc = AppLocalizations.of(context);
    final picked = _pending[key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                if (picked != null)
                  Text(
                    picked.filename,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _busy ? null : () => unawaited(_pick(key, ext)),
            child: Text(loc.mfgEquipPickFile),
          ),
          TextButton(
            onPressed: _busy || picked == null ? null : () => setState(() => _pending[key] = null),
            child: Text(loc.mfgEquipClearFile),
          ),
        ],
      ),
    );
  }
}
