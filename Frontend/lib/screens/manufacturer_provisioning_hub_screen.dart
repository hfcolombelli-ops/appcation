import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';

/// Consola mínima: instituições do fabricante e convites (criar / revogar).
class ManufacturerProvisioningHubScreen extends StatefulWidget {
  const ManufacturerProvisioningHubScreen({super.key, required this.apiToken});

  final String apiToken;

  @override
  State<ManufacturerProvisioningHubScreen> createState() => _ManufacturerProvisioningHubScreenState();
}

class _ManufacturerProvisioningHubScreenState extends State<ManufacturerProvisioningHubScreen> {
  final _api = ProductionApi.instance;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _institutions = [];
  List<Map<String, dynamic>> _invitations = [];

  final _instName = TextEditingController();
  final _instCnpj = TextEditingController();
  final _invEmail = TextEditingController();
  final _invCpf = TextEditingController();
  final _invName = TextEditingController();
  int? _inviteInstitutionId;
  String _inviteRole = 'institution_admin';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _instName.dispose();
    _instCnpj.dispose();
    _invEmail.dispose();
    _invCpf.dispose();
    _invName.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final inst = await _api.manufacturerInstitutionsList(widget.apiToken);
      final inv = await _api.manufacturerInvitationsList(widget.apiToken);
      if (!mounted) {
        return;
      }
      setState(() {
        _institutions = inst;
        _invitations = inv;
        _inviteInstitutionId ??= inst.isNotEmpty ? _rowId(inst.first) : null;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _snackErr(BuildContext context, Object e) {
    if (!context.mounted) {
      return;
    }
    if (e is ApiException) {
      context.showLocalizedApiExceptionSnack(e);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _snackOk(BuildContext context, String msg) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  int? _rowId(Map<String, dynamic> e) {
    final raw = e['id'];
    if (raw is int) {
      return raw;
    }
    return int.tryParse(raw?.toString() ?? '');
  }

  Future<void> _createInstitution(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _api.manufacturerCreateInstitution(
        widget.apiToken,
        name: _instName.text,
        cnpj: _instCnpj.text,
      );
      if (!context.mounted) {
        return;
      }
      _snackOk(context, l10n.mfgProvisioningSuccessInstitution);
      _instName.clear();
      _instCnpj.clear();
      await _reload();
    } catch (e) {
      if (context.mounted) {
        _snackErr(context, e);
      }
    }
  }

  Future<void> _createInvite(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final iid = _inviteInstitutionId;
    if (iid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.mfgProvisioningNeedInstitutionFirst)));
      }
      return;
    }
    try {
      await _api.manufacturerInvitationCreate(
        widget.apiToken,
        invitedEmail: _invEmail.text,
        role: _inviteRole,
        institutionId: iid,
        invitedName: _invName.text.trim().isEmpty ? null : _invName.text,
        invitedCpf: _invCpf.text.trim().isEmpty ? null : _invCpf.text,
      );
      if (!context.mounted) {
        return;
      }
      _snackOk(context, l10n.mfgProvisioningSuccessInvite);
      _invEmail.clear();
      _invCpf.clear();
      _invName.clear();
      await _reload();
    } catch (e) {
      if (context.mounted) {
        _snackErr(context, e);
      }
    }
  }

  Future<void> _revokeInvite(BuildContext context, int id) async {
    try {
      await _api.manufacturerInvitationRevoke(widget.apiToken, id);
      if (!context.mounted) {
        return;
      }
      await _reload();
    } catch (e) {
      if (context.mounted) {
        _snackErr(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mfgProvisioningNavTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  Text(l10n.mfgProvisioningCreateInstitutionTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(controller: _instName, decoration: InputDecoration(labelText: l10n.mfgProvisioningFieldName)),
                  const SizedBox(height: 8),
                  TextField(controller: _instCnpj, decoration: InputDecoration(labelText: l10n.mfgProvisioningFieldCnpj)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _createInstitution(context),
                    child: Text(l10n.mfgProvisioningSubmitCreateInstitution),
                  ),
                  const SizedBox(height: 28),
                  Text(l10n.mfgProvisioningInstitutionListTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_institutions.isEmpty)
                    Text(l10n.mfgProvisioningEmptyInstitutions)
                  else
                    ..._institutions.map(
                      (row) => ListTile(
                        dense: true,
                        title: Text(row['name']?.toString() ?? ''),
                        subtitle: Text('CNPJ ${row['cnpj'] ?? ''}'),
                      ),
                    ),
                  const SizedBox(height: 28),
                  Text(l10n.mfgProvisioningInviteCreateTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_institutions.isEmpty)
                    Text(l10n.mfgProvisioningPickInstitution)
                  else ...[
                    InputDecorator(
                      decoration: InputDecoration(labelText: l10n.mfgProvisioningInstitutionDropdownLabel),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _inviteInstitutionId,
                          items: [
                            for (final e in _institutions)
                              if (_rowId(e) != null)
                                DropdownMenuItem<int>(
                                  value: _rowId(e),
                                  child: Text(e['name']?.toString() ?? ''),
                                ),
                          ],
                          onChanged: (v) => setState(() => _inviteInstitutionId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(labelText: l10n.mfgProvisioningInviteRoleLabel),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _inviteRole,
                          items: [
                            DropdownMenuItem(value: 'institution_admin', child: Text(l10n.mfgProvisioningRoleGestor)),
                            DropdownMenuItem(value: 'instructor', child: Text(l10n.mfgProvisioningRoleInstructor)),
                          ],
                          onChanged: (v) => setState(() => _inviteRole = v ?? 'institution_admin'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _invEmail,
                      decoration: InputDecoration(labelText: l10n.mfgProvisioningFieldInviteEmail),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _invName,
                      decoration: InputDecoration(labelText: l10n.mfgProvisioningFieldInviteNameOptional),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _invCpf,
                      decoration: InputDecoration(labelText: l10n.mfgProvisioningFieldInviteCpfOptional),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => _createInvite(context),
                      child: Text(l10n.mfgProvisioningSubmitCreateInvite),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(l10n.mfgProvisioningInvitationListTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._invitations.map((inv) {
                    final id = inv['id'] as int?;
                    final status = inv['status']?.toString() ?? '';
                    final canRevoke = status == 'pending';
                    return ListTile(
                      title: Text(inv['invited_email']?.toString() ?? ''),
                      subtitle: Text('${inv['role']} · $status'),
                      trailing: canRevoke && id != null
                          ? TextButton(
                              onPressed: () => _revokeInvite(context, id),
                              child: Text(l10n.mfgProvisioningRevokeInvite),
                            )
                          : null,
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
