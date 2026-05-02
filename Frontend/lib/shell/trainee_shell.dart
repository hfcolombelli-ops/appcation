import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
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
  Timer? _healthTimer;
  bool _apiOnline = true;

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
      _profile = profile;
      _enrollment = enrollment;
      _step = step;
      _loading = false;
      _error = null;
    });

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

  Future<void> _loadQuestionnaire() async {
    final t = appAuth.token;
    final e = _enrollment;
    if (t == null || e == null) return;
    final tr = e['training'] as Map<String, dynamic>?;
    final tid = _parseInt(tr?['id']);
    if (tid == null) return;
    setState(() => _loading = true);
    try {
      final list = await _api.questionnaire(t, tid);
      if (mounted) {
        setState(() {
          _questions = list;
          _questionPos = 0;
          _pickedOptionId = null;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
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
                onLogout: () => appAuth.logout(),
              ),
              Expanded(
                child: _loading && _step != 2 && _step != 3
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
    required this.onLogout,
  });

  final bool apiOnline;
  final String userName;
  final VoidCallback onLogout;

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
              IconButton(tooltip: 'Sair', onPressed: onLogout, icon: const Icon(Icons.logout_rounded)),
            ],
          ),
        ),
      ),
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
