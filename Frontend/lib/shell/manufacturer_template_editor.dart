import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';


/// Editor mínimo de questionário para treinos template (`is_official_template`).
class ManufacturerTemplateEditorScreen extends StatefulWidget {
  const ManufacturerTemplateEditorScreen({
    super.key,
    required this.trainingId,
    required this.title,
  });

  final int trainingId;
  final String title;

  @override
  State<ManufacturerTemplateEditorScreen> createState() => _ManufacturerTemplateEditorScreenState();
}

class _ManufacturerTemplateEditorScreenState extends State<ManufacturerTemplateEditorScreen> {
  final _api = ProductionApi(ApiClient());
  final List<_MfgQuestionDraft> _questions = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _questions.add(_MfgQuestionDraft());
    _bootstrap();
  }

  @override
  void dispose() {
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.questionnaire(t, widget.trainingId);
      if (list.isEmpty || !mounted) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      for (final q in _questions) {
        q.dispose();
      }
      _questions.clear();
      for (final raw in list) {
        final m = Map<String, dynamic>.from(raw as Map);
        final opts = (m['options'] as List<dynamic>?) ?? [];
        final d = _MfgQuestionDraft();
        d.prompt.text = m['prompt']?.toString() ?? '';
        for (var i = 0; i < 4 && i < opts.length; i++) {
          final om = Map<String, dynamic>.from(opts[i] as Map);
          d.optionCtrls[i].text = om['label']?.toString() ?? '';
          if (om['is_correct'] == true) {
            d.correctIndex = i;
          }
        }
        _questions.add(d);
      }
      if (_questions.isEmpty) {
        _questions.add(_MfgQuestionDraft());
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = localizedApiMessage(AppLocalizations.of(context), e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).errApiConnection);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final t = appAuth.token;
    if (t == null) return;
    final lang = AppLocalizations.of(context);
    final blocks = <Map<String, dynamic>>[
      {
        'title': lang.mfgTplOfficialBlockTitle,
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
        setState(() => _error = lang.mfgTplErrNeedCorrect);
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
      setState(() => _error = lang.mfgTplErrMinQuestions);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.syncQuestionnaire(t, widget.trainingId, {'blocks': blocks});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.mfgTplSnackSaved)));
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = localizedApiMessage(lang, e));
    } catch (_) {
      if (mounted) setState(() => _error = lang.errApiConnection);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(lang.mfgBtnSave),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  lang.mfgTplIntro,
                  style: const TextStyle(color: Color(0xFF45464D)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(lang.mfgTplSectionQuestions, style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(() => _questions.add(_MfgQuestionDraft())),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(lang.mfgTplBtnAddQuestion),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _questions.length; i++)
                  _MfgQuestionCard(
                    key: ObjectKey(_questions[i]),
                    index: i,
                    draft: _questions[i],
                    questionHeading: lang.mfgTplQuestionNumber(i + 1),
                    onRemove: _questions.length > 1
                        ? () => setState(() {
                              _questions[i].dispose();
                              _questions.removeAt(i);
                            })
                        : null,
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(lang.mfgTplBtnSaveApi),
                ),
              ],
            ),
    );
  }
}

class _MfgQuestionDraft {
  _MfgQuestionDraft() : prompt = TextEditingController(), optionCtrls = List.generate(4, (_) => TextEditingController());

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

class _MfgQuestionCard extends StatefulWidget {
  const _MfgQuestionCard({
    super.key,
    required this.index,
    required this.draft,
    required this.questionHeading,
    this.onRemove,
  });

  final int index;
  final _MfgQuestionDraft draft;
  final String questionHeading;
  final VoidCallback? onRemove;

  @override
  State<_MfgQuestionCard> createState() => _MfgQuestionCardState();
}

class _MfgQuestionCardState extends State<_MfgQuestionCard> {
  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final lang = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(widget.questionHeading, style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                if (widget.onRemove != null)
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline_rounded)),
              ],
            ),
            TextField(controller: draft.prompt, decoration: InputDecoration(labelText: lang.mfgTplFieldPrompt)),
            const SizedBox(height: 12),
            Text(lang.mfgTplOptionsHint, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: draft.correctIndex,
              onChanged: (v) => setState(() => draft.correctIndex = v ?? 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < draft.optionCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Radio<int>(value: i),
                          Expanded(
                            child: TextField(
                              controller: draft.optionCtrls[i],
                              decoration: InputDecoration(labelText: lang.mfgTplOptionNumber(i + 1)),
                            ),
                          ),
                        ],
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
