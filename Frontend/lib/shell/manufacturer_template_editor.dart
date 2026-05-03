import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';

const int _kTemplateOptionMin = 2;
const int _kTemplateOptionMax = 12;

enum _TplEditorView { edit, preview }

/// Editor de questionário para treinos template (`is_official_template`): vários blocos e pré-visualização.
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
  final List<_MfgBlockDraft> _blocks = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _dirty = false;
  _TplEditorView _view = _TplEditorView.edit;

  @override
  void initState() {
    super.initState();
    _blocks.add(_MfgBlockDraft.empty());
    _bootstrap();
  }

  @override
  void dispose() {
    for (final b in _blocks) {
      b.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  void _disposeAllBlocks() {
    for (final b in _blocks) {
      b.dispose();
    }
    _blocks.clear();
  }

  int _globalQuestionOrdinal(int blockIdx, int qIdx) {
    var n = 0;
    for (var bi = 0; bi < blockIdx; bi++) {
      n += _blocks[bi].questions.length;
    }
    return n + qIdx + 1;
  }

  Future<void> _bootstrap({bool blockUi = true}) async {
    final t = appAuth.token;
    if (t == null) return;
    if (blockUi) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _error = null);
    }
    try {
      final list = await _api.questionnaire(t, widget.trainingId);
      if (!mounted) return;
      _disposeAllBlocks();
      if (list.isEmpty) {
        _blocks.add(_MfgBlockDraft.empty());
        setState(() {
          _dirty = false;
          if (blockUi) _loading = false;
        });
        return;
      }
      final flat = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final groups = <List<Map<String, dynamic>>>[];
      int? lastBlockId;
      for (final m in flat) {
        final tb = m['training_block'];
        var blockId = 0;
        if (tb is Map) {
          final id = tb['id'];
          blockId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        } else {
          final id = m['training_block_id'];
          blockId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        }
        if (groups.isEmpty || blockId != lastBlockId) {
          groups.add(<Map<String, dynamic>>[m]);
          lastBlockId = blockId;
        } else {
          groups.last.add(m);
        }
      }
      for (final g in groups) {
        _blocks.add(_MfgBlockDraft.fromGroupedRows(g));
      }
      if (_blocks.isEmpty) {
        _blocks.add(_MfgBlockDraft.empty());
      }
      setState(() {
        _dirty = false;
        if (blockUi) _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedApiMessage(AppLocalizations.of(context), e);
          if (blockUi) _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).errApiConnection;
          if (blockUi) _loading = false;
        });
      }
    }
  }

  void _moveQuestionWithinBlock(int blockIdx, int from, int to) {
    if (to < 0 || to >= _blocks[blockIdx].questions.length || from == to) return;
    setState(() {
      final list = _blocks[blockIdx].questions;
      final q = list.removeAt(from);
      list.insert(to, q);
      _dirty = true;
    });
  }

  void _moveBlock(int from, int to) {
    if (to < 0 || to >= _blocks.length || from == to) return;
    setState(() {
      final b = _blocks.removeAt(from);
      _blocks.insert(to, b);
      _dirty = true;
    });
  }

  void _addBlock() {
    setState(() {
      _blocks.add(_MfgBlockDraft.empty());
      _dirty = true;
    });
  }

  void _removeBlockAt(int bi) {
    if (_blocks.length <= 1) return;
    setState(() {
      final removed = _blocks.removeAt(bi);
      final mergeIdx = bi > 0 ? bi - 1 : 0;
      _blocks[mergeIdx].questions.addAll(removed.questions);
      removed.questions.clear();
      removed.title.dispose();
      _dirty = true;
    });
  }

  Future<void> _confirmDiscardAndPop() async {
    final lang = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.mfgTplDiscardTitle),
        content: Text(lang.mfgTplDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(lang.mfgTplKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lang.mfgTplDiscardLeave),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    final t = appAuth.token;
    if (t == null) return;
    final lang = AppLocalizations.of(context);
    final blocksPayload = <Map<String, dynamic>>[];
    var blockOrder = 1;
    for (var bi = 0; bi < _blocks.length; bi++) {
      final b = _blocks[bi];
      final titleTrim = b.title.text.trim();
      final blockTitle = titleTrim.isEmpty
          ? (bi == 0 ? lang.mfgTplOfficialBlockTitle : lang.mfgTplBlockDefaultTitle(bi + 1))
          : titleTrim;
      final questionsPayload = <Map<String, dynamic>>[];
      var order = 1;
      for (final q in b.questions) {
        final prompt = q.prompt.text.trim();
        if (prompt.isEmpty) continue;
        final indices = <int>[];
        for (var i = 0; i < q.optionCtrls.length; i++) {
          if (q.optionCtrls[i].text.trim().isNotEmpty) {
            indices.add(i);
          }
        }
        if (indices.length < _kTemplateOptionMin) {
          setState(() => _error = lang.mfgTplErrQuestionNeedTwoOptions);
          return;
        }
        final correctPos = indices.indexOf(q.correctIndex);
        if (correctPos < 0) {
          setState(() => _error = lang.mfgTplErrCorrectMustHaveLabel);
          return;
        }
        final opts = <Map<String, dynamic>>[];
        for (var p = 0; p < indices.length; p++) {
          final i = indices[p];
          opts.add({
            'label': q.optionCtrls[i].text.trim(),
            'is_correct': p == correctPos,
            'sort_order': p + 1,
          });
        }
        questionsPayload.add({
          'prompt': prompt,
          'sort_order': order,
          'options': opts,
        });
        order++;
      }
      if (questionsPayload.isEmpty) continue;
      blocksPayload.add({
        'title': blockTitle,
        'sort_order': blockOrder,
        'questions': questionsPayload,
      });
      blockOrder++;
    }
    if (blocksPayload.isEmpty) {
      setState(() => _error = lang.mfgTplErrMinQuestions);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.syncQuestionnaire(t, widget.trainingId, {'blocks': blocksPayload});
      if (mounted) {
        setState(() => _dirty = false);
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

  Widget _buildPreview(AppLocalizations lang) {
    var shownCount = 0;
    final children = <Widget>[
      Material(
        color: const Color(0xFFF0F9FF),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.visibility_outlined, color: Colors.blue.shade800, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang.mfgTplPreviewBanner,
                  style: TextStyle(fontSize: 13, height: 1.35, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
    for (var bi = 0; bi < _blocks.length; bi++) {
      final b = _blocks[bi];
      final titleTrim = b.title.text.trim();
      final bt = titleTrim.isEmpty
          ? (bi == 0 ? lang.mfgTplOfficialBlockTitle : lang.mfgTplBlockDefaultTitle(bi + 1))
          : titleTrim;
      var blockHasContent = false;
      for (final q in b.questions) {
        if (q.prompt.text.trim().isNotEmpty) {
          blockHasContent = true;
          break;
        }
      }
      if (!blockHasContent) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            bt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );
      for (var qi = 0; qi < b.questions.length; qi++) {
        final q = b.questions[qi];
        final prompt = q.prompt.text.trim();
        if (prompt.isEmpty) continue;
        shownCount++;
        final ord = shownCount;
        final labels = <String>[];
        for (final c in q.optionCtrls) {
          final tx = c.text.trim();
          if (tx.isNotEmpty) labels.add(tx);
        }
        children.add(
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(lang.mfgTplQuestionNumber(ord), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(prompt),
                  const SizedBox(height: 12),
                  for (var li = 0; li < labels.length; li++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${li + 1}. ', style: const TextStyle(color: Color(0xFF64748B))),
                          Expanded(child: Text(labels[li])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
    if (shownCount == 0) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(lang.mfgTplPreviewEmpty, style: const TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_confirmDiscardAndPop());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: lang.mfgTplReloadTooltip,
              onPressed: _loading || _saving ? null : () => unawaited(_bootstrap()),
              icon: const Icon(Icons.refresh_rounded),
            ),
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: SegmentedButton<_TplEditorView>(
                      segments: [
                        ButtonSegment(
                          value: _TplEditorView.edit,
                          label: Text(lang.mfgTplViewEdit),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: _TplEditorView.preview,
                          label: Text(lang.mfgTplViewPreview),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                        ),
                      ],
                      selected: {_view},
                      onSelectionChanged: (s) {
                        setState(() => _view = s.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _bootstrap(blockUi: false),
                      child: _view == _TplEditorView.preview
                          ? _buildPreview(lang)
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
                              children: [
                                Text(
                                  lang.mfgTplIntro,
                                  style: const TextStyle(color: Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lang.mfgTplRefreshHint,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(lang.mfgTplSectionBlocks, style: Theme.of(context).textTheme.titleLarge),
                                    ),
                                    TextButton.icon(
                                      onPressed: _saving ? null : _addBlock,
                                      icon: const Icon(Icons.add_rounded),
                                      label: Text(lang.mfgTplBtnAddBlock),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                for (var bi = 0; bi < _blocks.length; bi++) ...[
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: _blocks[bi].title,
                                                  decoration: InputDecoration(
                                                    labelText: lang.mfgTplFieldBlockTitle,
                                                    hintText: bi == 0 ? lang.mfgTplOfficialBlockTitle : null,
                                                  ),
                                                  onChanged: (_) => _markDirty(),
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: lang.mfgTplMoveBlockUpTooltip,
                                                onPressed: bi > 0 ? () => _moveBlock(bi, bi - 1) : null,
                                                icon: const Icon(Icons.arrow_upward_rounded),
                                              ),
                                              IconButton(
                                                tooltip: lang.mfgTplMoveBlockDownTooltip,
                                                onPressed: bi < _blocks.length - 1 ? () => _moveBlock(bi, bi + 1) : null,
                                                icon: const Icon(Icons.arrow_downward_rounded),
                                              ),
                                              if (_blocks.length > 1)
                                                IconButton(
                                                  tooltip: lang.mfgTplRemoveBlockTooltip,
                                                  onPressed: _saving ? null : () => _removeBlockAt(bi),
                                                  icon: const Icon(Icons.delete_outline_rounded),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(lang.mfgTplSectionQuestions, style: Theme.of(context).textTheme.titleMedium),
                                              const Spacer(),
                                              TextButton.icon(
                                                onPressed: _saving
                                                    ? null
                                                    : () => setState(() {
                                                          _blocks[bi].questions.add(_MfgQuestionDraft.empty());
                                                          _dirty = true;
                                                        }),
                                                icon: const Icon(Icons.add_rounded),
                                                label: Text(lang.mfgTplBtnAddQuestion),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          for (var qi = 0; qi < _blocks[bi].questions.length; qi++)
                                            _MfgQuestionCard(
                                              key: ObjectKey(_blocks[bi].questions[qi]),
                                              index: qi,
                                              draft: _blocks[bi].questions[qi],
                                              questionHeading: lang.mfgTplQuestionNumber(_globalQuestionOrdinal(bi, qi)),
                                              onEdited: _markDirty,
                                              onMoveUp: qi > 0 ? () => _moveQuestionWithinBlock(bi, qi, qi - 1) : null,
                                              onMoveDown: qi < _blocks[bi].questions.length - 1
                                                  ? () => _moveQuestionWithinBlock(bi, qi, qi + 1)
                                                  : null,
                                              onRemove: _blocks[bi].questions.length > 1
                                                  ? () => setState(() {
                                                        _blocks[bi].questions[qi].dispose();
                                                        _blocks[bi].questions.removeAt(qi);
                                                        _dirty = true;
                                                      })
                                                  : null,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
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
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MfgBlockDraft {
  _MfgBlockDraft._(this.title) {
    questions.add(_MfgQuestionDraft.empty());
  }

  factory _MfgBlockDraft.empty() => _MfgBlockDraft._(TextEditingController());

  factory _MfgBlockDraft.fromGroupedRows(List<Map<String, dynamic>> rows) {
    var initialTitle = '';
    if (rows.isNotEmpty) {
      final tb = rows.first['training_block'];
      if (tb is Map) {
        initialTitle = tb['title']?.toString() ?? '';
      }
    }
    final b = _MfgBlockDraft._(TextEditingController(text: initialTitle));
    b.questions.clear();
    for (final m in rows) {
      b.questions.add(_MfgQuestionDraft.fromApiRow(m));
    }
    if (b.questions.isEmpty) {
      b.questions.add(_MfgQuestionDraft.empty());
    }
    return b;
  }

  final TextEditingController title;
  final List<_MfgQuestionDraft> questions = [];

  void dispose() {
    title.dispose();
    for (final q in questions) {
      q.dispose();
    }
  }
}

class _MfgQuestionDraft {
  _MfgQuestionDraft.empty() : prompt = TextEditingController() {
    optionCtrls.add(TextEditingController());
    optionCtrls.add(TextEditingController());
  }

  _MfgQuestionDraft._loaded(String promptText, List<dynamic> opts) : prompt = TextEditingController(text: promptText) {
    final count = opts.length < _kTemplateOptionMin ? _kTemplateOptionMin : opts.length;
    for (var i = 0; i < count; i++) {
      optionCtrls.add(TextEditingController());
    }
    for (var i = 0; i < opts.length && i < optionCtrls.length; i++) {
      final om = Map<String, dynamic>.from(opts[i] as Map);
      optionCtrls[i].text = om['label']?.toString() ?? '';
      if (om['is_correct'] == true) {
        correctIndex = i;
      }
    }
  }

  factory _MfgQuestionDraft.fromApiRow(Map<String, dynamic> m) {
    final opts = (m['options'] as List<dynamic>?) ?? [];
    return _MfgQuestionDraft._loaded(m['prompt']?.toString() ?? '', opts);
  }

  final TextEditingController prompt;
  final List<TextEditingController> optionCtrls = [];
  int correctIndex = 0;

  void dispose() {
    prompt.dispose();
    for (final c in optionCtrls) {
      c.dispose();
    }
  }

  void addOption() {
    if (optionCtrls.length >= _kTemplateOptionMax) return;
    optionCtrls.add(TextEditingController());
  }

  void removeOptionAt(int i) {
    if (optionCtrls.length <= _kTemplateOptionMin || i < 0 || i >= optionCtrls.length) return;
    optionCtrls[i].dispose();
    optionCtrls.removeAt(i);
    if (correctIndex == i) {
      correctIndex = 0;
    } else if (correctIndex > i) {
      correctIndex--;
    }
    if (correctIndex >= optionCtrls.length) {
      correctIndex = optionCtrls.length - 1;
    }
    if (correctIndex < 0) {
      correctIndex = 0;
    }
  }
}

class _MfgQuestionCard extends StatefulWidget {
  const _MfgQuestionCard({
    super.key,
    required this.index,
    required this.draft,
    required this.questionHeading,
    required this.onEdited,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
  });

  final int index;
  final _MfgQuestionDraft draft;
  final String questionHeading;
  final VoidCallback onEdited;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
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
                Expanded(child: Text(widget.questionHeading, style: const TextStyle(fontWeight: FontWeight.w800))),
                if (widget.onMoveUp != null)
                  IconButton(
                    tooltip: lang.mfgTplMoveUpTooltip,
                    onPressed: widget.onMoveUp,
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                if (widget.onMoveDown != null)
                  IconButton(
                    tooltip: lang.mfgTplMoveDownTooltip,
                    onPressed: widget.onMoveDown,
                    icon: const Icon(Icons.arrow_downward_rounded),
                  ),
                if (widget.onRemove != null)
                  IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline_rounded)),
              ],
            ),
            TextField(
              controller: draft.prompt,
              decoration: InputDecoration(labelText: lang.mfgTplFieldPrompt),
              onChanged: (_) => widget.onEdited(),
            ),
            const SizedBox(height: 12),
            Text(lang.mfgTplOptionsHint, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            const SizedBox(height: 4),
            Text(
              lang.mfgTplOptionsCountHint,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: draft.correctIndex,
              onChanged: (v) {
                setState(() => draft.correctIndex = v ?? 0);
                widget.onEdited();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < draft.optionCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Radio<int>(value: i),
                          ),
                          Expanded(
                            child: TextField(
                              controller: draft.optionCtrls[i],
                              decoration: InputDecoration(labelText: lang.mfgTplOptionNumber(i + 1)),
                              onChanged: (_) => widget.onEdited(),
                            ),
                          ),
                          if (draft.optionCtrls.length > _kTemplateOptionMin)
                            IconButton(
                              tooltip: lang.mfgTplRemoveOptionTooltip,
                              onPressed: () {
                                setState(() {
                                  draft.removeOptionAt(i);
                                  widget.onEdited();
                                });
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  if (draft.optionCtrls.length >= _kTemplateOptionMax) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(lang.mfgTplMaxOptionsSnack)),
                    );
                    return;
                  }
                  setState(() {
                    draft.addOption();
                    widget.onEdited();
                  });
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(lang.mfgTplBtnAddOption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
