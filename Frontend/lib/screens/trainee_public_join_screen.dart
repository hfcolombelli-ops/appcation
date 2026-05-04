import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/production_api.dart';
import '../util/training_join_hash.dart';

/// Inscrição pública num treino via `join_hash` (Web: `/join-training?hash=…`).
class TraineePublicJoinScreen extends StatefulWidget {
  const TraineePublicJoinScreen({super.key, this.joinHash});

  final String? joinHash;

  @override
  State<TraineePublicJoinScreen> createState() => _TraineePublicJoinScreenState();
}

class _TraineePublicJoinScreenState extends State<TraineePublicJoinScreen> {
  final _api = ProductionApi.instance;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _loadingPreview = true;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic>? _preview;

  String? get _hash =>
      (widget.joinHash?.trim().isNotEmpty ?? false)
          ? widget.joinHash!.trim().toLowerCase()
          : readTrainingJoinHashFromLaunchUri();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreview());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final h = _hash;
    if (h == null || h.isEmpty) {
      setState(() {
        _loadingPreview = false;
        _error = AppLocalizations.of(context).traineeJoinMissingHash;
      });
      return;
    }
    setState(() {
      _loadingPreview = true;
      _error = null;
    });
    try {
      final data = await _api.publicTrainingJoinPreview(h);
      setState(() {
        _preview = data;
        _loadingPreview = false;
      });
    } catch (e) {
      setState(() {
        _loadingPreview = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    final h = _hash;
    if (h == null || h.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    if (_password.text != _password2.text) {
      setState(() => _error = l10n.invitePasswordMismatch);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final body = await _api.publicTraineeRegisterAndJoin(
        joinHash: h,
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        passwordConfirmation: _password2.text,
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
    final h = _hash;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.traineeJoinTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loadingPreview
              ? const Center(child: CircularProgressIndicator())
              : h == null || h.isEmpty
                  ? Text(_error ?? l10n.traineeJoinMissingHash)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.traineeJoinSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                          if (_preview != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _preview!['title']?.toString() ?? '',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_preview!['institution_name'] != null)
                              Text(
                                _preview!['institution_name'].toString(),
                                style: const TextStyle(color: Color(0xFF45464D)),
                              ),
                          ],
                          const SizedBox(height: 24),
                          TextField(
                            controller: _name,
                            decoration: InputDecoration(labelText: l10n.traineeJoinName),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: l10n.traineeJoinEmail),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: true,
                            decoration: InputDecoration(labelText: l10n.traineeJoinPassword),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password2,
                            obscureText: true,
                            decoration: InputDecoration(labelText: l10n.traineeJoinPasswordConfirm),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.traineeJoinSubmit),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
