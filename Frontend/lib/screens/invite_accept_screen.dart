import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/production_api.dart';
import '../util/invite_token.dart';

/// Aceitação de convite (fabricante → gestor / instrutor). Web: `/invite?token=…`.
class InviteAcceptScreen extends StatefulWidget {
  const InviteAcceptScreen({super.key, this.token});

  final String? token;

  @override
  State<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends State<InviteAcceptScreen> {
  final _api = ProductionApi.instance;
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final _cpf = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _invite;

  String? get _token =>
      (widget.token?.trim().isNotEmpty ?? false)
          ? widget.token!.trim()
          : readInviteTokenFromLaunchUri();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _password2.dispose();
    _cpf.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final t = _token;
    if (t == null || t.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).inviteMissingToken;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.publicInvitationShow(t);
      setState(() {
        _invite = data;
        _loading = false;
        final n = data['invited_name']?.toString();
        if (n != null && n.trim().isNotEmpty) {
          _name.text = n.trim();
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  bool get _requiresCpf => _invite?['requires_cpf'] == true;

  Future<void> _accept() async {
    final t = _token;
    if (t == null || t.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.inviteNameRequired);
      return;
    }
    if (_password.text != _password2.text) {
      setState(() => _error = l10n.invitePasswordMismatch);
      return;
    }
    if (_requiresCpf && _cpf.text.trim().isEmpty) {
      setState(() => _error = l10n.inviteCpfRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final body = await _api.publicInvitationAccept(
        t,
        name: _name.text.trim(),
        password: _password.text,
        passwordConfirmation: _password2.text,
        cpf: _requiresCpf ? _cpf.text.trim() : (_cpf.text.trim().isEmpty ? null : _cpf.text.trim()),
      );
      final token = body['token'] as String?;
      final user = body['user'] as Map<String, dynamic>?;
      if (token == null || user == null) {
        throw StateError('Resposta inválida');
      }
      await appAuth.absorbInviteSession(token, user);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/role-home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = _token;
    final status = _invite?['status']?.toString();
    final pending = _invite != null && status == 'pending';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inviteAcceptTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : t == null || t.isEmpty
                  ? Text(_error ?? l10n.inviteMissingToken)
                  : !pending
                      ? Text(_error ?? l10n.inviteStatusNotPending(status ?? ''))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_invite != null) ...[
                                Text(
                                  '${l10n.inviteRoleLabel}: ${_invite!['role']}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text('${l10n.inviteEmailLabel}: ${_invite!['invited_email']}'),
                                if (_invite!['institution_name'] != null)
                                  Text('${l10n.inviteInstitutionLabel}: ${_invite!['institution_name']}'),
                                const SizedBox(height: 24),
                              ],
                              TextField(
                                controller: _name,
                                decoration: InputDecoration(labelText: l10n.inviteNameLabel),
                              ),
                              if (_requiresCpf) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _cpf,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: l10n.inviteCpfLabel),
                                ),
                              ],
                              const SizedBox(height: 12),
                              TextField(
                                controller: _password,
                                obscureText: true,
                                decoration: InputDecoration(labelText: l10n.invitePasswordLabel),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _password2,
                                obscureText: true,
                                decoration: InputDecoration(labelText: l10n.invitePasswordConfirmLabel),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ],
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _submitting ? null : _accept,
                                child: _submitting
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(l10n.inviteActivate),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}
