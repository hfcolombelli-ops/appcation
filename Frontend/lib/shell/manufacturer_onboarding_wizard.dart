import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../services/api_client.dart' show ApiClient, ApiException;
import '../services/production_api.dart';
import '../util/br_document_input_formatters.dart';

const _kManufacturerDocKinds = ['cnpj_proof', 'articles_of_incorporation', 'address_proof'];

/// Assistente em 3 passos — cadastro inicial do fabricante (`pending_info` / `rejected`).
class ManufacturerOnboardingWizard extends StatefulWidget {
  const ManufacturerOnboardingWizard({
    super.key,
    required this.manufacturer,
    required this.onCompleted,
    required this.onLogout,
  });

  final Map<String, dynamic> manufacturer;
  final VoidCallback onCompleted;
  final VoidCallback onLogout;

  @override
  State<ManufacturerOnboardingWizard> createState() => _ManufacturerOnboardingWizardState();
}

class _ManufacturerOnboardingWizardState extends State<ManufacturerOnboardingWizard> {
  final _api = ProductionApi(ApiClient());

  int _step = 0;
  bool _busy = false;
  List<Map<String, dynamic>> _documents = [];

  final _legalName = TextEditingController();
  final _tradeName = TextEditingController();
  final _cnpj = TextEditingController();
  final _stateReg = TextEditingController();
  final _website = TextEditingController();
  final _commercialPhone = TextEditingController();
  final _supportEmail = TextEditingController();
  final _cep = TextEditingController();
  final _street = TextEditingController();
  final _neighborhood = TextEditingController();
  final _city = TextEditingController();
  final _stateUf = TextEditingController();

  final _repName = TextEditingController();
  final _repCpf = TextEditingController();
  final _repRole = TextEditingController();
  final _repPhone = TextEditingController();

  bool _declaration = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromManufacturer();
    unawaited(_loadDocuments());
  }

  void _hydrateFromManufacturer() {
    final m = widget.manufacturer;
    _legalName.text = m['name']?.toString() ?? '';
    _tradeName.text = m['trade_name']?.toString() ?? '';
    _cnpj.text = m['cnpj']?.toString() ?? '';
    _stateReg.text = m['state_registration']?.toString() ?? '';
    _website.text = m['website']?.toString() ?? '';
    _commercialPhone.text = m['commercial_phone']?.toString() ?? '';
    _supportEmail.text = m['support_email']?.toString() ?? appAuth.user?['email']?.toString() ?? '';
    _cep.text = m['address_postal_code']?.toString() ?? '';
    _street.text = m['address_street']?.toString() ?? '';
    _neighborhood.text = m['address_neighborhood']?.toString() ?? '';
    _city.text = m['address_city']?.toString() ?? '';
    _stateUf.text = m['address_state']?.toString() ?? '';
    _repName.text = m['legal_rep_full_name']?.toString() ?? '';
    _repCpf.text = m['legal_rep_cpf']?.toString() ?? '';
    _repRole.text = m['legal_rep_role']?.toString() ?? '';
    _repPhone.text = m['legal_rep_phone']?.toString() ?? '';
    _declaration = m['declaration_accepted_at'] != null;
  }

  @override
  void dispose() {
    _legalName.dispose();
    _tradeName.dispose();
    _cnpj.dispose();
    _stateReg.dispose();
    _website.dispose();
    _commercialPhone.dispose();
    _supportEmail.dispose();
    _cep.dispose();
    _street.dispose();
    _neighborhood.dispose();
    _city.dispose();
    _stateUf.dispose();
    _repName.dispose();
    _repCpf.dispose();
    _repRole.dispose();
    _repPhone.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await _api.listManufacturerDocuments(t);
      if (mounted) setState(() => _documents = list);
    } catch (_) {
      /* ignorado — utilizador pode tentar novamente ao mudar de passo */
    }
  }

  String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  Future<void> _lookupCep(AppLocalizations l) async {
    final cep = _digits(_cep.text);
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgCepInvalid)));
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (!mounted) return;
      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgCepNotFound)));
        return;
      }
      final map = jsonDecode(res.body);
      if (map is! Map<String, dynamic> || map['erro'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgCepNotFound)));
        return;
      }
      setState(() {
        _street.text = map['logradouro']?.toString() ?? _street.text;
        _neighborhood.text = map['bairro']?.toString() ?? _neighborhood.text;
        _city.text = map['localidade']?.toString() ?? _city.text;
        _stateUf.text = map['uf']?.toString() ?? _stateUf.text;
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgCepNotFound)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _hasDocKind(String kind) =>
      _documents.any((d) => d['document_kind']?.toString() == kind);

  String _kindTitle(AppLocalizations l, String kind) {
    switch (kind) {
      case 'cnpj_proof':
        return l.mfgDocCnpjProof;
      case 'articles_of_incorporation':
        return l.mfgDocArticles;
      case 'address_proof':
        return l.mfgDocAddressProof;
      default:
        return kind;
    }
  }

  Future<void> _pickAndUpload(String kind, AppLocalizations l) async {
    final t = appAuth.token;
    if (t == null) return;
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (pick == null || pick.files.isEmpty) return;
    final f = pick.files.first;
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (mounted) context.showErrApiConnectionSnack();
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.uploadManufacturerDocument(
        t,
        filename: f.name,
        fileBytes: bytes,
        documentKind: kind,
      );
      await _loadDocuments();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteDoc(int id, AppLocalizations l) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _busy = true);
    try {
      await _api.deleteManufacturerDocument(t, id);
      await _loadDocuments();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _saveStep1(AppLocalizations l) async {
    final t = appAuth.token;
    if (t == null) return false;
    final cnpj = _digits(_cnpj.text);
    if (_legalName.text.trim().isEmpty ||
        _tradeName.text.trim().isEmpty ||
        cnpj.length != 14 ||
        _commercialPhone.text.trim().isEmpty ||
        _supportEmail.text.trim().isEmpty ||
        _digits(_cep.text).length != 8 ||
        _street.text.trim().isEmpty ||
        _neighborhood.text.trim().isEmpty ||
        _city.text.trim().isEmpty ||
        _stateUf.text.trim().length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgOnboardFieldsRequired)));
      return false;
    }

    setState(() => _busy = true);
    try {
      await _api.updateManufacturerProfile(t, {
        'name': _legalName.text.trim(),
        'trade_name': _tradeName.text.trim(),
        'cnpj': cnpj,
        if (_stateReg.text.trim().isNotEmpty) 'state_registration': _stateReg.text.trim(),
        if (_website.text.trim().isNotEmpty) 'website': _website.text.trim(),
        'commercial_phone': _commercialPhone.text.trim(),
        'support_email': _supportEmail.text.trim(),
        'address_postal_code': _digits(_cep.text),
        'address_street': _street.text.trim(),
        'address_neighborhood': _neighborhood.text.trim(),
        'address_city': _city.text.trim(),
        'address_state': _stateUf.text.trim().toUpperCase(),
      });
      return true;
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
      return false;
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _saveStep2(AppLocalizations l) async {
    final t = appAuth.token;
    if (t == null) return false;
    final cpf = _digits(_repCpf.text);
    if (_repName.text.trim().isEmpty ||
        cpf.length != 11 ||
        _repRole.text.trim().isEmpty ||
        _repPhone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.valNameRequired)));
      return false;
    }

    setState(() => _busy = true);
    try {
      await _api.updateManufacturerProfile(t, {
        'legal_rep_full_name': _repName.text.trim(),
        'legal_rep_cpf': cpf,
        'legal_rep_role': _repRole.text.trim(),
        'legal_rep_phone': _repPhone.text.trim(),
      });
      return true;
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
      return false;
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitFinal(AppLocalizations l) async {
    final t = appAuth.token;
    if (t == null) return;

    if (!_declaration) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgAcceptDeclaration)));
      return;
    }

    for (final k in _kManufacturerDocKinds) {
      if (!_hasDocKind(k)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfgDocMissingKind(_kindTitle(l, k)))));
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await _api.updateManufacturerProfile(t, {'declaration_accepted': true});
      await _api.requestManufacturerValidation(t);
      if (mounted) widget.onCompleted();
    } on ApiException catch (e) {
      if (mounted) {
        final msg = localizedApiMessage(l, e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onContinue(AppLocalizations l) async {
    if (_step == 0) {
      final ok = await _saveStep1(l);
      if (ok && mounted) setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      final ok = await _saveStep2(l);
      if (ok && mounted) {
        await _loadDocuments();
        setState(() => _step = 2);
      }
      return;
    }
  }

  void _onBack() {
    if (_step > 0) setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(l.mfgOnboardTitle),
        actions: [
          TextButton(onPressed: _busy ? null : widget.onLogout, child: Text(l.mfgLogout)),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.mfgOnboardStepCounter(_step + 1, 3),
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF0F766E)),
                    ),
                    const SizedBox(height: 16),
                    if (_step == 0) ...[
                      Text(l.mfgOnboardCorporateSection, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _legalName,
                        decoration: InputDecoration(labelText: '${l.mfgFieldLegalName} *'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tradeName,
                        decoration: InputDecoration(labelText: '${l.mfgFieldTradeName} *'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cnpj,
                              decoration: InputDecoration(labelText: 'CNPJ *'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [CnpjInputFormatter()],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _stateReg,
                              decoration: InputDecoration(labelText: l.mfgFieldStateRegistration),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _website,
                              decoration: InputDecoration(labelText: l.mfgFieldWebsite),
                              keyboardType: TextInputType.url,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _commercialPhone,
                              decoration: InputDecoration(labelText: '${l.mfgFieldCommercialPhone} *'),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _supportEmail,
                        decoration: InputDecoration(labelText: '${l.mfgFieldSupportEmail} *'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      Text(l.mfgAddressSection, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: _cep,
                              decoration: InputDecoration(labelText: '${l.mfgFieldCep} *'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : () => unawaited(_lookupCep(l)),
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: Text(l.mfgCepLookup),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _street,
                        decoration: InputDecoration(labelText: '${l.mfgFieldStreet} *'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _neighborhood,
                              decoration: InputDecoration(labelText: '${l.mfgFieldNeighborhood} *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _city,
                              decoration: InputDecoration(labelText: '${l.mfgFieldCity} *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 72,
                            child: TextField(
                              controller: _stateUf,
                              decoration: InputDecoration(labelText: '${l.mfgFieldState} *'),
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_step == 1) ...[
                      Text(l.mfgOnboardLegalRepSection, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _repName,
                        decoration: InputDecoration(labelText: '${l.mfgFieldLegalRepName} *'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _repCpf,
                              decoration: InputDecoration(labelText: '${l.mfgFieldLegalRepCpf} *'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [CpfInputFormatter()],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _repRole,
                              decoration: InputDecoration(labelText: '${l.mfgFieldLegalRepRole} *'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _repPhone,
                        decoration: InputDecoration(labelText: '${l.mfgFieldLegalRepPhone} *'),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                    if (_step == 2) ...[
                      Text(l.mfgOnboardDocsSection, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(l.mfgDocFormatsHint, style: tt.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      for (final kind in _kManufacturerDocKinds) ...[
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blueGrey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(_kindTitle(l, kind), style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                ...[
                                  for (final d in _documents.where((x) => x['document_kind']?.toString() == kind))
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.attach_file_rounded, size: 20),
                                      title: Text(d['original_filename']?.toString() ?? '—'),
                                      subtitle: Text(
                                        '${((int.tryParse(d['size_bytes']?.toString() ?? '0') ?? 0) / 1024).toStringAsFixed(0)} KB',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded),
                                        onPressed: _busy
                                            ? null
                                            : () => unawaited(_deleteDoc(int.parse(d['id'].toString()), l)),
                                        tooltip: l.mfgRemoveDoc,
                                      ),
                                    ),
                                ],
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _busy ? null : () => unawaited(_pickAndUpload(kind, l)),
                                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                                    label: Text(l.mfgPickDoc),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      CheckboxListTile(
                        value: _declaration,
                        onChanged: _busy ? null : (v) => setState(() => _declaration = v ?? false),
                        title: Text(l.mfgDeclarationLabel, style: const TextStyle(fontSize: 14, height: 1.35)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(onPressed: _busy ? null : _onBack, child: Text(l.actionBack)),
                      const Spacer(),
                      if (_step < 2)
                        FilledButton(
                          onPressed: _busy ? null : () => unawaited(_onContinue(l)),
                          child: Text(l.trnBtnContinue),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _busy ? null : () => unawaited(_submitFinal(l)),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(l.mfgSendForReview),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_busy) const Positioned.fill(child: IgnorePointer(child: ModalBarrier(dismissible: false, color: Color(0x11000000)))),
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
