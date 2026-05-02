import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../widgets/version_badge.dart';

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

  void _go(String route) {
    setState(() => _route = route);
    _navKey.currentState?.pushReplacementNamed(route);
  }

  String _title(String route) {
    switch (route) {
      case '/instructor/comando':
        return 'Sala de Comando';
      case '/instructor/treinamento':
        return 'Novo Treinamento';
      case '/instructor/credenciamento':
        return 'Credenciamento';
      default:
        return 'Visão Geral';
    }
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/instructor/comando':
        page = _ComandoPage(api: _api);
        break;
      case '/instructor/treinamento':
        page = _TreinamentoPage(api: _api);
        break;
      case '/instructor/credenciamento':
        page = _CredenciamentoPage(api: _api);
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
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Row(
            children: [
              _Sidebar(currentRoute: _route, onNavigate: _go),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(title: _title(_route)),
                    Expanded(
                      child: Navigator(
                        key: _navKey,
                        initialRoute: '/instructor/dashboard',
                        onGenerateRoute: _onGenerateRoute,
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
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentRoute, required this.onNavigate});

  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final items = <(String label, String route, IconData icon)>[
      ('Dashboard', '/instructor/dashboard', Icons.dashboard_rounded),
      ('Sala de Comando', '/instructor/comando', Icons.monitor_heart_rounded),
      ('Treinamentos', '/instructor/treinamento', Icons.add_box_rounded),
      ('Credenciamento', '/instructor/credenciamento', Icons.verified_user_rounded),
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
          const Text(
            'App²cation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            'Área do instrutor',
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
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final user = appAuth.user;
    final name = user?['name']?.toString() ?? 'Instrutor';

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
            IconButton(
              tooltip: 'Sair',
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
  Object? _error;

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
      final s = await widget.api.dashboardSummary(t);
      if (mounted) setState(() => _summary = s);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }
    if (_summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final trainingCount = _summary!['training_count']?.toString() ?? '0';
    final participantCount = _summary!['participant_count']?.toString() ?? '0';
    final avg = _summary!['average_score'];
    final avgLabel = avg == null ? '—' : avg.toString();
    final recent = (_summary!['recent_trainings'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Kpi(title: 'Treinamentos', value: trainingCount),
              _Kpi(title: 'Inscrições', value: participantCount),
              _Kpi(title: 'Média (concluídos)', value: avgLabel),
            ],
          ),
          const SizedBox(height: 22),
          Text('Treinamentos recentes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: recent.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum treinamento ainda. Crie um em Treinamentos.'),
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF45464D), fontSize: 13)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
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
    final inst = t['institution'] as Map<String, dynamic>?;
    final instName = inst?['name']?.toString() ?? '—';
    return ListTile(
      title: Text(t['title']?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('$instName · ${t['status'] ?? ''}'),
      trailing: Text(t['join_hash']?.toString() ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF00677D))),
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
  Map<String, dynamic>? _createdTraining;
  bool _loading = false;
  String? _error;

  final List<_QuestionDraft> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
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

  Future<void> _createTraining() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_institutionId == null) {
      setState(() => _error = 'Selecione uma instituição.');
      return;
    }
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Informe o título.');
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
      if (mounted) setState(() => _createdTraining = tr);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
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

    final blocks = <Map<String, dynamic>>[
      {
        'title': 'Avaliação',
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
        setState(() => _error = 'Cada pergunta precisa de uma opção correta.');
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
      setState(() => _error = 'Adicione ao menos uma pergunta válida com 2+ opções.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.syncQuestionnaire(t, tid, {'blocks': blocks});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Questionário salvo.')));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = _createdTraining;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Configuração', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Instituição'),
                  value: _institutionId,
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
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Título do treinamento')),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'official', label: Text('Oficial')),
                    ButtonSegment(value: 'custom', label: Text('Personalizado')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _scheduled,
                  decoration: const InputDecoration(
                    labelText: 'Data/hora (opcional)',
                    hintText: 'AAAA-MM-DD HH:MM',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _createTraining,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF131B2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Criar treinamento'),
                ),
              ],
            ),
          ),
        ),
        if (tr != null) ...[
          const SizedBox(height: 22),
          Card(
            color: const Color(0xFF0F172A),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Código de entrada (repasse aos treinandos)', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  SelectableText(
                    tr['join_hash']?.toString() ?? '',
                    style: const TextStyle(color: Color(0xFF50D9FE), fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text('ID interno: ${_parseInt(tr['id'])}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text('Questionário', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _questions.add(_QuestionDraft())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Pergunta'),
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
          FilledButton(
            onPressed: _loading ? null : _saveQuestionnaire,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D), padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Salvar questionário na API'),
          ),
        ],
      ],
    );
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
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
    final draft = widget.draft;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Pergunta ${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline_rounded)),
              ],
            ),
            TextField(controller: draft.prompt, decoration: const InputDecoration(labelText: 'Enunciado')),
            const SizedBox(height: 12),
            const Text('Opções (marque a correta)', style: TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            const SizedBox(height: 8),
            for (var i = 0; i < draft.optionCtrls.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: draft.correctIndex,
                      onChanged: (v) => setState(() => draft.correctIndex = v ?? 0),
                    ),
                    Expanded(
                      child: TextField(
                        controller: draft.optionCtrls[i],
                        decoration: InputDecoration(labelText: 'Opção ${i + 1}'),
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

  @override
  void initState() {
    super.initState();
    _refreshTrainings().then((_) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 4), (_) => _loadMonitor());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        _loadMonitor();
      }
    } catch (_) {}
  }

  Future<void> _loadMonitor() async {
    final t = appAuth.token;
    final id = _selectedId;
    if (t == null || id == null) return;
    try {
      final m = await widget.api.trainingParticipants(t, id);
      if (mounted) setState(() => _monitor = m);
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
          const SnackBar(content: Text('Próximo bloco liberado (ou já não há blocos pendentes).')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: $status')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = (_monitor?['participants'] as List<dynamic>?) ?? [];
    final training = _monitor?['training'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(labelText: 'Treinamento ativo'),
                            value: _selectedId,
                            items: [
                              for (final tr in _trainings)
                                DropdownMenuItem(
                                  value: _parseInt(tr['id']),
                                  child: Text(tr['title']?.toString() ?? ''),
                                ),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedId = v);
                              _loadMonitor();
                            },
                          ),
                        ),
                        IconButton(onPressed: _refreshTrainings, icon: const Icon(Icons.refresh_rounded)),
                      ],
                    ),
                    if (training != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Status: ${training['status']} · Hash: ${training['join_hash']}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF45464D)),
                        ),
                      ),
                    const SizedBox(height: 14),
                    const Text('Participantes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: participants.isEmpty
                          ? const Center(child: Text('Nenhum participante inscrito.'))
                          : ListView(
                              children: [
                                for (final row in participants)
                                  _ParticipantTile(Map<String, dynamic>.from(row as Map)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Card(
              color: const Color(0xFF0F172A),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Controle da sessão', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton(
                          onPressed: _loading ? null : () => _setTrainingStatus('in_progress'),
                          child: const Text('Iniciar'),
                        ),
                        FilledButton.tonal(
                          onPressed: _loading ? null : _releaseNextBlock,
                          child: const Text('Liberar próximo bloco'),
                        ),
                        FilledButton.tonal(
                          onPressed: _loading ? null : () => _setTrainingStatus('scheduled'),
                          child: const Text('Reagendar'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                          onPressed: _loading ? null : () => _setTrainingStatus('finished'),
                          child: const Text('Encerrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Iniciar libera o questionário para treinandos conectados. Encerrar marca o fim da sessão.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final u = row['user'] as Map<String, dynamic>?;
    final e = row['enrollment'] as Map<String, dynamic>?;
    final name = u?['name']?.toString() ?? '—';
    final answered = row['answered_count']?.toString() ?? '0';
    final total = row['question_count']?.toString() ?? '0';
    final score = e?['score']?.toString();
    return ListTile(
      leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
      title: Text(name),
      subtitle: Text('Respostas $answered / $total · ${e?['status'] ?? ''}'),
      trailing: score != null ? Text(score, style: const TextStyle(fontWeight: FontWeight.w700)) : null,
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
      if (mounted) setState(() => _list = list);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instituição criada.')));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Instituições', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        const Text('Cadastre hospitais ou unidades para vincular aos treinamentos.', style: TextStyle(color: Color(0xFF45464D))),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome da instituição')),
                const SizedBox(height: 12),
                TextField(controller: _cnpj, decoration: const InputDecoration(labelText: 'CNPJ (único)')),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF131B2E), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Cadastrar instituição'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text('Cadastradas (${_list.length})', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Card(
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
      ],
    );
  }
}
