import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../services/google_sign_in_helper.dart';
import '../widgets/version_badge.dart';

/// Shell treinando: cabeçalho fixo; conteúdo troca por etapa real da API.
class TraineeShell extends StatefulWidget {
  const TraineeShell({super.key});

  @override
  State<TraineeShell> createState() => _TraineeShellState();
}

class _TraineeShellState extends State<TraineeShell> {
  final _api = ProductionApi(ApiClient());

  bool _loading = true;
  String? _error;

  int _step = 0;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _enrollment;

  List<Map<String, dynamic>> _institutions = [];
  final _sector = TextEditingController();
  final _equipment = TextEditingController();
  final _sessionAt = TextEditingController();
  int? _institutionId;

  final _joinHash = TextEditingController();

  List<Map<String, dynamic>> _questions = [];
  int _questionPos = 0;
  int? _pickedOptionId;

  Timer? _waitPoll;
  Timer? _livePoll;
  int? _liveCommandSeq;
  Timer? _healthTimer;
  bool _apiOnline = true;

  bool _needsLgpdConsent = false;
  bool _lgpdCheckbox = false;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
    _bootstrap();
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
    _waitPoll?.cancel();
    _livePoll?.cancel();
    _healthTimer?.cancel();
    _sector.dispose();
    _equipment.dispose();
    _sessionAt.dispose();
    _joinHash.dispose();
    super.dispose();
  }

  Future<void> _loadInstitutions() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final list = await _api.institutions(t);
      if (mounted) {
        setState(() {
          _institutions = list;
          _institutionId ??= list.isNotEmpty ? _parseInt(list.first['id']) : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _bootstrap() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await _api.traineeState(t);
      _applyRemoteState(s);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
          _step = 0;
        });
      }
    }
  }

  void _applyRemoteState(Map<String, dynamic> s) {
    final needsConsent = s['needs_lgpd_consent'] == true;
    if (needsConsent) {
      _waitPoll?.cancel();
      _livePoll?.cancel();
      setState(() {
        _needsLgpdConsent = true;
        _lgpdCheckbox = false;
        _loading = false;
        _error = null;
      });
      return;
    }

    final profile = s['profile'] as Map<String, dynamic>?;
    final enrollment = s['enrollment'] as Map<String, dynamic>?;

    _waitPoll?.cancel();

    if (profile != null) {
      _sector.text = profile['sector']?.toString() ?? '';
      _equipment.text = profile['equipment_label']?.toString() ?? '';
      _sessionAt.text = profile['session_at']?.toString() ?? '';
      _institutionId = _parseInt(profile['institution_id']);
    }

    var step = 0;
    if (profile == null) {
      step = 0;
    } else if (enrollment == null) {
      step = 1;
    } else {
      final st = enrollment['status']?.toString();
      final tr = enrollment['training'] as Map<String, dynamic>?;
      final trSt = tr?['status']?.toString();
      if (st == 'completed') {
        step = 4;
      } else if (trSt == 'in_progress') {
        step = 3;
      } else {
        step = 2;
      }
    }

    setState(() {
      _needsLgpdConsent = false;
      _profile = profile;
      _enrollment = enrollment;
      _step = step;
      _loading = false;
      _error = null;
    });

    if (step != 3) {
      _livePoll?.cancel();
      _liveCommandSeq = null;
    }

    if (step == 2) {
      _waitPoll = Timer.periodic(const Duration(seconds: 3), (_) => _pollWaiting());
    }
    if (step == 3) {
      _loadQuestionnaire();
    }
  }

  Future<void> _pollWaiting() async {
    final t = appAuth.token;
    final e = _enrollment;
    if (t == null || e == null) return;
    final id = _parseInt(e['id']);
    if (id == null) return;
    try {
      final fresh = await _api.getEnrollment(t, id);
      final tr = fresh['training'] as Map<String, dynamic>?;
      if (tr?['status']?.toString() == 'in_progress') {
        _waitPoll?.cancel();
        _applyRemoteState({'profile': _profile, 'enrollment': fresh});
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_sector.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o setor.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.putTraineeProfile(t, {
        'sector': _sector.text.trim(),
        if (_institutionId != null) 'institution_id': _institutionId,
        if (_equipment.text.trim().isNotEmpty) 'equipment_label': _equipment.text.trim(),
        if (_sessionAt.text.trim().isNotEmpty) 'session_at': _sessionAt.text.trim(),
      });
      if (mounted) await _bootstrap();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _doJoin() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_joinHash.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o código.')));
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _api.joinTraining(t, _joinHash.text);
      final en = Map<String, dynamic>.from(res['enrollment'] as Map);
      if (mounted) {
        setState(() => _loading = false);
        _applyRemoteState({'profile': _profile, 'enrollment': en});
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _loadQuestionnaire({bool quiet = false}) async {
    final t = appAuth.token;
    final e = _enrollment;
    if (t == null || e == null) return;
    final tr = e['training'] as Map<String, dynamic>?;
    final tid = _parseInt(tr?['id']);
    if (tid == null) return;
    if (!quiet && mounted) setState(() => _loading = true);
    try {
      final list = await _api.questionnaire(t, tid);
      Map<String, dynamic> live;
      try {
        live = await _api.trainingLiveState(t, tid);
      } catch (_) {
        live = {};
      }
      final seqRaw = live['command_seq'];
      final seq = seqRaw is int ? seqRaw : int.tryParse(seqRaw.toString());
      if (mounted) {
        setState(() {
          _questions = list;
          if (!quiet) {
            _questionPos = 0;
            _pickedOptionId = null;
          } else if (_questionPos >= _questions.length) {
            _questionPos = _questions.isEmpty ? 0 : _questions.length - 1;
            _pickedOptionId = null;
          }
          _liveCommandSeq = seq ?? _liveCommandSeq;
          _loading = false;
        });
      }
      _ensureLivePolling(t, tid);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = 2;
        });
        _livePoll?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _ensureLivePolling(String token, int trainingId) {
    _livePoll?.cancel();
    if (_step != 3) {
      return;
    }
    _livePoll = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollTrainingLive(token, trainingId);
    });
  }

  Future<void> _pollTrainingLive(String token, int trainingId) async {
    if (_step != 3 || !mounted) {
      return;
    }
    try {
      final live = await _api.trainingLiveState(token, trainingId);
      final status = live['status']?.toString();
      if (status == 'finished') {
        _livePoll?.cancel();
        await _bootstrap();
        return;
      }
      final seqRaw = live['command_seq'];
      final seq = seqRaw is int ? seqRaw : int.tryParse(seqRaw.toString());
      if (seq != null && _liveCommandSeq != null && seq != _liveCommandSeq) {
        _liveCommandSeq = seq;
        await _loadQuestionnaire(quiet: true);
      } else if (seq != null) {
        _liveCommandSeq = seq;
      }
    } catch (_) {}
  }

  Future<void> _submitAnswer() async {
    final t = appAuth.token;
    final e = _enrollment;
    if (t == null || e == null || _questions.isEmpty) return;
    if (_pickedOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma opção.')));
      return;
    }
    final q = _questions[_questionPos];
    final qid = _parseInt(q['id']);
    final eid = _parseInt(e['id']);
    if (qid == null || eid == null) return;

    setState(() => _loading = true);
    try {
      await _api.submitAnswer(t, {
        'enrollment_id': eid,
        'question_id': qid,
        'question_option_id': _pickedOptionId,
      });
      if (_questionPos >= _questions.length - 1) {
        await _bootstrap();
        return;
      }
      if (mounted) {
        setState(() {
          _questionPos++;
          _pickedOptionId = null;
          _loading = false;
        });
      }
    } on ApiException catch (ex) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ex.message)));
      }
    }
  }

  void _goJoinAnother() {
    _waitPoll?.cancel();
    setState(() {
      _step = 1;
      _enrollment = null;
      _questions = [];
      _joinHash.clear();
    });
  }

  Future<void> _submitLgpdConsent() async {
    final t = appAuth.token;
    if (t == null) return;
    if (!_lgpdCheckbox) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marque a caixa para confirmar que leu e concorda.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.submitLgpdConsent(t, accepted: true);
      if (mounted) await _bootstrap();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _exportPersonalJson() async {
    final t = appAuth.token;
    if (t == null) return;
    try {
      final data = await _api.exportPersonalData(t);
      final text = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados copiados para a área de transferência (JSON).')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final t = appAuth.token;
    if (t == null) return;
    final googleLinked = appAuth.user?['google_sub'] != null;
    final pwd = TextEditingController();
    final confirm = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excluir conta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  googleLinked
                      ? 'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). '
                          'Confirme com EXCLUIR e autentique novamente com Google.'
                      : 'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). '
                          'Digite EXCLUIR em maiúsculas e a sua senha.',
                ),
                if (!googleLinked) ...[
                  const SizedBox(height: 12),
                  TextField(controller: pwd, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
                ],
                const SizedBox(height: 8),
                TextField(controller: confirm, decoration: const InputDecoration(labelText: 'Confirmar (digite EXCLUIR)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      if (googleLinked) {
        final idToken = await obtainGoogleIdToken(forceAccountPicker: true);
        if (idToken == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancelado.')));
          }
          return;
        }
        await _api.requestAccountDeletion(t, idToken: idToken, confirmText: confirm.text.trim());
      } else {
        await _api.requestAccountDeletion(t, password: pwd.text, confirmText: confirm.text.trim());
      }
      await appAuth.logout();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } on StateError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      pwd.dispose();
      confirm.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = appAuth.user;
    final name = user?['name']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Stack(
        children: [
          Column(
            children: [
              _TraineeHeader(
                apiOnline: _apiOnline,
                userName: name,
                showPrivacyMenu: !_needsLgpdConsent,
                onLogout: () => appAuth.logout(),
                onExportData: _exportPersonalJson,
                onDeleteAccount: _confirmDeleteAccount,
              ),
              Expanded(
                child: _needsLgpdConsent
                    ? _LgpdConsentPanel(
                        checked: _lgpdCheckbox,
                        onChanged: (v) => setState(() => _lgpdCheckbox = v ?? false),
                        loading: _loading,
                        onSubmit: _submitLgpdConsent,
                      )
                    : _loading && _step != 2 && _step != 3
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _profile == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  FilledButton(onPressed: _bootstrap, child: const Text('Recarregar')),
                                ],
                              ),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _stepBody(),
                            ),
                          ),
              ),
            ],
          ),
          const Positioned(left: 16, bottom: 16, child: VersionBadge()),
        ],
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 1:
        return _JoinPanel(joinHash: _joinHash, loading: _loading, onJoin: _doJoin);
      case 2:
        return _WaitingPanel(enrollment: _enrollment);
      case 3:
        return _QuestionnairePanel(
          questions: _questions,
          position: _questionPos,
          pickedOptionId: _pickedOptionId,
          onPick: (id) => setState(() => _pickedOptionId = id),
          onConfirm: _submitAnswer,
          loading: _loading,
        );
      case 4:
        return _ResultPanel(enrollment: _enrollment, onAgain: _goJoinAnother);
      case 0:
      default:
        return _ProfilePanel(
          sector: _sector,
          equipment: _equipment,
          sessionAt: _sessionAt,
          institutions: _institutions,
          institutionId: _institutionId,
          onInstitution: (v) => setState(() => _institutionId = v),
          onSubmit: _saveProfile,
          loading: _loading,
        );
    }
  }
}

class _TraineeHeader extends StatelessWidget {
  const _TraineeHeader({
    required this.apiOnline,
    required this.userName,
    required this.showPrivacyMenu,
    required this.onLogout,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  final bool apiOnline;
  final String userName;
  final bool showPrivacyMenu;
  final VoidCallback onLogout;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x140F172A),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE6E8EA))),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.medical_services_rounded, color: Color(0xFF00677D), size: 28),
              const SizedBox(width: 10),
              Text(
                'App²cation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: apiOnline ? const Color(0xFFE8FFF4) : const Color(0xFFFFF4F4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: apiOnline ? const Color(0xFF10B981) : const Color(0xFFF87171)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: apiOnline ? const Color(0xFF10B981) : const Color(0xFFB91C1C)),
                    const SizedBox(width: 8),
                    Text(
                      apiOnline ? 'API ok' : 'Sem API',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: apiOnline ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (userName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(userName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              if (showPrivacyMenu)
                PopupMenuButton<String>(
                  tooltip: 'Privacidade',
                  icon: const Icon(Icons.privacy_tip_outlined),
                  onSelected: (v) {
                    if (v == 'export') onExportData();
                    if (v == 'delete') onDeleteAccount();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'export', child: Text('Exportar meus dados (JSON)')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir minha conta')),
                  ],
                ),
              IconButton(tooltip: 'Sair', onPressed: onLogout, icon: const Icon(Icons.logout_rounded)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Consentimento LGPD — checkbox obrigatório não pré-marcado (documento de conformidade).
class _LgpdConsentPanel extends StatelessWidget {
  const _LgpdConsentPanel({
    required this.checked,
    required this.onChanged,
    required this.loading,
    required this.onSubmit,
  });

  final bool checked;
  final ValueChanged<bool?> onChanged;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Privacidade e dados',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 12),
        const Text(
          'Antes de usar o treinamento, precisamos do seu consentimento explícito (LGPD — Lei 13.709/2018):',
          style: TextStyle(color: Color(0xFF45464D), height: 1.45),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '• Finalidade: identificação em treinamentos, certificados e relatórios agregados da instituição.\n'
                  '• Compartilhamento: dados individuais apenas com o instrutor durante a sessão; à instituição, de forma agregada.\n'
                  '• Retenção: até 5 anos após o último treinamento para auditoria, salvo exclusão ou anonimização a seu pedido.\n'
                  '• Direitos: acesso, correção, portabilidade e exclusão pelo menu Privacidade (ícone no topo).\n'
                  '• Google: ao usar login Google, dados também são tratados segundo a política do Google.',
                  style: TextStyle(height: 1.5, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: checked,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Li e concordo com o tratamento dos meus dados pessoais conforme a Política de Privacidade do App²cation.',
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF131B2E),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Continuar'),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.sector,
    required this.equipment,
    required this.sessionAt,
    required this.institutions,
    required this.institutionId,
    required this.onInstitution,
    required this.onSubmit,
    required this.loading,
  });

  final TextEditingController sector;
  final TextEditingController equipment;
  final TextEditingController sessionAt;
  final List<Map<String, dynamic>> institutions;
  final int? institutionId;
  final ValueChanged<int?> onInstitution;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Pré-registro', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 8),
        const Text('Dados reais gravados na sua conta.', style: TextStyle(color: Color(0xFF45464D))),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Instituição (opcional)'),
                  value: institutionId,
                  items: [
                    for (final i in institutions)
                      DropdownMenuItem(value: _parseInt(i['id']), child: Text(i['name']?.toString() ?? '')),
                  ],
                  onChanged: onInstitution,
                ),
                const SizedBox(height: 14),
                TextField(controller: sector, decoration: const InputDecoration(labelText: 'Setor / equipe *')),
                const SizedBox(height: 14),
                TextField(controller: equipment, decoration: const InputDecoration(labelText: 'Equipamento / contexto')),
                const SizedBox(height: 14),
                TextField(
                  controller: sessionAt,
                  decoration: const InputDecoration(
                    labelText: 'Data e hora da sessão (opcional)',
                    hintText: 'AAAA-MM-DD HH:MM',
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: loading ? null : onSubmit,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF131B2E), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Salvar e continuar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JoinPanel extends StatelessWidget {
  const _JoinPanel({required this.joinHash, required this.loading, required this.onJoin});

  final TextEditingController joinHash;
  final bool loading;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Entrar no treinamento', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 8),
        const Text('Use o código fornecido pelo instrutor.', style: TextStyle(color: Color(0xFF45464D))),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: joinHash,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Código de acesso'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loading ? null : onJoin,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirmar entrada'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel({required this.enrollment});

  final Map<String, dynamic>? enrollment;

  @override
  Widget build(BuildContext context) {
    final tr = enrollment?['training'] as Map<String, dynamic>?;
    final title = tr?['title']?.toString() ?? 'Treinamento';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 64, color: Color(0xFF00677D)),
                const SizedBox(height: 20),
                Text('Sala de espera', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                const Text(
                  'Assim que o instrutor iniciar, o questionário abre automaticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF45464D), height: 1.5),
                ),
                const SizedBox(height: 20),
                const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionnairePanel extends StatelessWidget {
  const _QuestionnairePanel({
    required this.questions,
    required this.position,
    required this.pickedOptionId,
    required this.onPick,
    required this.onConfirm,
    required this.loading,
  });

  final List<Map<String, dynamic>> questions;
  final int position;
  final int? pickedOptionId;
  final ValueChanged<int> onPick;
  final VoidCallback onConfirm;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: Text('Nenhuma questão disponível.'));
    }
    final q = questions[position];
    final prompt = q['prompt']?.toString() ?? '';
    final options = (q['options'] as List<dynamic>?) ?? [];
    final total = questions.length;

    return Row(
      children: [
        Container(
          width: 300,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E3E5)),
            boxShadow: const [BoxShadow(color: Color(0x080F172A), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PROGRESSO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00677D), letterSpacing: 1.2)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (position + 1) / total,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE0E3E5),
                  color: const Color(0xFF50D9FE),
                ),
              ),
              const SizedBox(height: 10),
              Text('Questão ${position + 1} de $total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 28, 24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF191C1E), width: 1.2)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(prompt, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35)),
                    const SizedBox(height: 18),
                    Expanded(
                      child: ListView(
                        children: [
                          ...options.map((raw) {
                            final o = Map<String, dynamic>.from(raw as Map);
                            final oid = _parseInt(o['id']);
                            if (oid == null) return const SizedBox.shrink();
                            return _OptionTile(
                              id: oid,
                              label: o['label']?.toString() ?? '',
                              selected: pickedOptionId == oid,
                              onTap: () => onPick(oid),
                            );
                          }),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: loading ? null : onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF131B2E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Confirmar resposta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.id, required this.label, required this.selected, required this.onTap});

  final int id;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xFFEAF9FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? const Color(0xFF00677D) : const Color(0xFFC6C6CD), width: 2),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.enrollment, required this.onAgain});

  final Map<String, dynamic>? enrollment;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final score = enrollment?['score']?.toString() ?? '—';
    final tr = enrollment?['training'] as Map<String, dynamic>?;
    final title = tr?['title']?.toString() ?? '';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 72, color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                Text('Treinamento concluído', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Text('Nota (0–10)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF45464D))),
                Text(score, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onAgain,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                  child: const Text('Entrar em outro treinamento'),
                ),
              ],
            ),
          ),
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
