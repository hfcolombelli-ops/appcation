import 'dart:async';
import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../l10n/google_sign_in_localizations.dart';
import '../l10n/status_labels.dart';
import '../services/google_sign_in_errors.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../services/training_reverb_listener.dart';
import '../services/google_sign_in_helper.dart';
import '../widgets/fluxo_premium_panel.dart';
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
  bool _sessionPaused = false;
  String? _scorePolicyHint;
  int? _liveCommandSeq;
  TrainingReverbListener? _reverbListener;
  int? _reverbTrainingId;
  TrainingRealtimeLinkPhase _rtPhase = TrainingRealtimeLinkPhase.httpOnly;
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

  Future<void> _disconnectTrainingReverb() async {
    _reverbTrainingId = null;
    if (mounted) {
      setState(() => _rtPhase = TrainingRealtimeLinkPhase.httpOnly);
    }
    final l = _reverbListener;
    _reverbListener = null;
    await l?.dispose();
  }

  Future<void> _attachReverbListener(int trainingId) async {
    if (!mounted || _step != 3) {
      return;
    }
    if (_reverbTrainingId == trainingId && _reverbListener != null) {
      return;
    }

    await _disconnectTrainingReverb();
    if (!mounted || _step != 3) {
      return;
    }

    Map<String, dynamic> cfg;
    try {
      cfg = await _api.realtimeClientConfig();
    } catch (_) {
      return;
    }

    if (cfg['enabled'] != true) {
      return;
    }
    final raw = cfg['reverb'];
    if (raw is! Map) {
      return;
    }
    final r = Map<String, dynamic>.from(raw);
    final key = r['key']?.toString() ?? '';
    if (key.isEmpty) {
      return;
    }
    final host = r['host']?.toString() ?? '127.0.0.1';
    final port = r['port'] is int ? r['port'] as int : int.tryParse(r['port']?.toString() ?? '') ?? 8080;
    final useTls = r['use_tls'] == true;

    final listener = TrainingReverbListener(
      onSeq: (seq) {
        if (!mounted || _step != 3) {
          return;
        }
        if (_liveCommandSeq == seq) {
          return;
        }
        _liveCommandSeq = seq;
        final t = appAuth.token;
        if (t != null) {
          unawaited(_loadQuestionnaire(quiet: true));
        }
      },
      connectionErrorHandler: (e, st, refresh) {
        refresh();
      },
      onLifecycle: (phase) {
        if (mounted) {
          setState(() => _rtPhase = phase);
        }
      },
    );

    try {
      await listener.connect(
        key: key,
        host: host,
        port: port,
        useTls: useTls,
        trainingId: trainingId,
      );
    } catch (_) {
      await listener.dispose();
      return;
    }

    if (!mounted || _step != 3) {
      await listener.dispose();
      return;
    }

    _reverbTrainingId = trainingId;
    _reverbListener = listener;
  }

  @override
  void dispose() {
    unawaited(_disconnectTrainingReverb());
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
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedApiMessage(AppLocalizations.of(context), e);
          _loading = false;
          _step = 0;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).errApiConnection;
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
      unawaited(_disconnectTrainingReverb());
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
      if (step != 3) {
        _sessionPaused = false;
        _scorePolicyHint = null;
      }
    });

    if (step != 3) {
      _livePoll?.cancel();
      unawaited(_disconnectTrainingReverb());
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackSectorRequired)));
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
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  Future<void> _doJoin() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_joinHash.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackCodeRequired)));
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
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
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
      final paused =
          live['session_paused'] == true || live['last_command']?.toString() == 'pause';
      final hint = live['post_repescage_score_policy_label_pt']?.toString();
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
          _sessionPaused = paused;
          if (hint != null && hint.isNotEmpty) {
            _scorePolicyHint = hint;
          }
          _loading = false;
        });
        if (list.isEmpty && _step == 3 && _enrollment?['in_recovery'] == true) {
          unawaited(_bootstrap());
        }
      }
      _ensureLivePolling(t, tid);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = 2;
        });
        _livePoll?.cancel();
        unawaited(_disconnectTrainingReverb());
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = 2;
        });
        _livePoll?.cancel();
        unawaited(_disconnectTrainingReverb());
        context.showErrApiConnectionSnack();
      }
    }
  }

  void _ensureLivePolling(String token, int trainingId) {
    _livePoll?.cancel();
    if (_step != 3) {
      unawaited(_disconnectTrainingReverb());
      return;
    }
    _livePoll = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollTrainingLive(token, trainingId);
    });
    unawaited(_attachReverbListener(trainingId));
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
      final paused =
          live['session_paused'] == true || live['last_command']?.toString() == 'pause';
      final hint = live['post_repescage_score_policy_label_pt']?.toString();
      if (mounted) {
        setState(() {
          _sessionPaused = paused;
          if (hint != null && hint.isNotEmpty) {
            _scorePolicyHint = hint;
          }
        });
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
    if (_sessionPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).trnSnackSessionPaused)),
      );
      return;
    }
    if (_pickedOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackPickOption)));
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
        context.showLocalizedApiExceptionSnack(ex);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
      }
    }
  }

  void _goJoinAnother() {
    _waitPoll?.cancel();
    _livePoll?.cancel();
    unawaited(_disconnectTrainingReverb());
    setState(() {
      _step = 1;
      _enrollment = null;
      _questions = [];
      _sessionPaused = false;
      _joinHash.clear();
    });
  }

  Future<void> _submitLgpdConsent() async {
    final t = appAuth.token;
    if (t == null) return;
    if (!_lgpdCheckbox) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).trnSnackLgpdCheckbox)),
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
        context.showLocalizedApiExceptionSnack(e);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        context.showErrApiConnectionSnack();
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
          SnackBar(content: Text(AppLocalizations.of(context).trnSnackJsonCopied)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
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
        builder: (ctx) {
          final lang = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(lang.trnDeleteAccountTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    googleLinked ? lang.trnDeleteAccountBodyGoogle : lang.trnDeleteAccountBodyPassword,
                  ),
                  if (!googleLinked) ...[
                    const SizedBox(height: 12),
                    TextField(controller: pwd, obscureText: true, decoration: InputDecoration(labelText: lang.trnFieldPassword)),
                  ],
                  const SizedBox(height: 8),
                  TextField(controller: confirm, decoration: InputDecoration(labelText: lang.trnFieldConfirmDelete)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(lang.mfgBtnCancel)),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(lang.trnBtnConfirm),
              ),
            ],
          );
        },
      );
      if (ok != true || !mounted) return;
      if (googleLinked) {
        final idToken = await obtainGoogleIdToken(forceAccountPicker: true);
        if (idToken == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackCancelled)));
          }
          return;
        }
        await _api.requestAccountDeletion(t, idToken: idToken, confirmText: confirm.text.trim());
      } else {
        await _api.requestAccountDeletion(t, password: pwd.text, confirmText: confirm.text.trim());
      }
      await appAuth.logout();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } on GoogleSignInFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizedGoogleSignInFailure(AppLocalizations.of(context), e))),
        );
      }
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
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
                realtimeLinkPhase: !_needsLgpdConsent && _step == 3 ? _rtPhase : null,
              ),
              Expanded(
                child: _needsLgpdConsent
                    ? _LgpdConsentPanel(
                        checked: _lgpdCheckbox,
                        onChanged: (v) => setState(() => _lgpdCheckbox = v ?? false),
                        loading: _loading,
                        onSubmit: _submitLgpdConsent,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: FluxoPremiumPanel(dense: false),
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
                                              FilledButton(onPressed: _bootstrap, child: Text(AppLocalizations.of(context).actionRetry)),
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
          inRecovery: _enrollment?['in_recovery'] == true,
          sessionPaused: _sessionPaused,
          scorePolicyHint: _scorePolicyHint,
        );
      case 4:
        return _ResultPanel(enrollment: _enrollment, onAgain: _goJoinAnother);
      case 0:
      default:
        return _ProfilePanel(
          api: _api,
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
    this.realtimeLinkPhase,
  });

  final bool apiOnline;
  final String userName;
  final bool showPrivacyMenu;
  final VoidCallback onLogout;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;
  final TrainingRealtimeLinkPhase? realtimeLinkPhase;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                l.loginBrandTitle,
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
                      apiOnline ? l.trnApiOk : l.trnApiOffline,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: apiOnline ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              if (realtimeLinkPhase != null) ...[
                const SizedBox(width: 10),
                TrainingRealtimeLinkChip(phase: realtimeLinkPhase!),
              ],
              const Spacer(),
              if (userName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(userName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              if (showPrivacyMenu)
                PopupMenuButton<String>(
                  tooltip: l.trnTooltipPrivacy,
                  icon: const Icon(Icons.privacy_tip_outlined),
                  onSelected: (v) {
                    if (v == 'export') onExportData();
                    if (v == 'delete') onDeleteAccount();
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'export', child: Text(l.trnMenuExportJson)),
                    PopupMenuItem(value: 'delete', child: Text(l.trnMenuDeleteAccount)),
                  ],
                ),
              IconButton(tooltip: l.trnTooltipSignOut, onPressed: onLogout, icon: const Icon(Icons.logout_rounded)),
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
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l.trnPrivacyTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 12),
        Text(
          l.trnLgpdIntro,
          style: const TextStyle(color: Color(0xFF45464D), height: 1.45),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.trnLgpdBullets,
                  style: const TextStyle(height: 1.5, fontSize: 14),
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
          title: Text(l.trnLgpdCheckboxTitle),
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
              : Text(l.trnBtnContinue),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatefulWidget {
  const _ProfilePanel({
    required this.api,
    required this.sector,
    required this.equipment,
    required this.sessionAt,
    required this.institutions,
    required this.institutionId,
    required this.onInstitution,
    required this.onSubmit,
    required this.loading,
  });

  final ProductionApi api;
  final TextEditingController sector;
  final TextEditingController equipment;
  final TextEditingController sessionAt;
  final List<Map<String, dynamic>> institutions;
  final int? institutionId;
  final ValueChanged<int?> onInstitution;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  State<_ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<_ProfilePanel> {
  final _desiredDate = TextEditingController();
  final _latestAcceptableDate = TextEditingController();
  final _reqNotes = TextEditingController();
  List<Map<String, dynamic>> _certs = [];
  List<Map<String, dynamic>> _followUps = [];
  List<Map<String, dynamic>> _reqs = [];
  List<Map<String, dynamic>> _reasonOptions = [];
  List<Map<String, dynamic>> _priorityOptions = [];
  String? _reasonCodeId;
  String _priorityId = 'normal';
  bool _loadingExtra = false;
  List<Map<String, dynamic>> _parkEquipment = [];
  int? _selectedParkEquipmentId;

  @override
  void initState() {
    super.initState();
    _reloadExtras();
  }

  @override
  void dispose() {
    _desiredDate.dispose();
    _latestAcceptableDate.dispose();
    _reqNotes.dispose();
    super.dispose();
  }

  Future<void> _reloadExtras() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loadingExtra = true);
    try {
      final c = await widget.api.myCertificates(t);
      List<Map<String, dynamic>> fu = [];
      try {
        fu = await widget.api.myFollowUpAssessments(t);
      } catch (_) {
        fu = [];
      }
      final r = await widget.api.myTrainingRequests(t);
      Map<String, dynamic>? opt;
      try {
        opt = await widget.api.trainingRequestOptions(t);
      } catch (_) {
        opt = null;
      }
      List<Map<String, dynamic>> park = [];
      try {
        park = await widget.api.traineeInstitutionParkEquipment(t);
      } catch (_) {
        park = [];
      }
      if (mounted) {
        setState(() {
          _certs = c;
          _followUps = fu;
          _reqs = r;
          _parkEquipment = park;
          if (opt != null) {
            _reasonOptions = List<Map<String, dynamic>>.from(
              (opt['reason_codes'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
            );
            _priorityOptions = List<Map<String, dynamic>>.from(
              (opt['priorities'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
            );
            _reasonCodeId ??= _reasonOptions.isNotEmpty ? _reasonOptions.first['id']?.toString() : null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _certs = [];
          _followUps = [];
          _reqs = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  Future<void> _openFollowUpAssessment(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loadingExtra = true);
    Map<String, dynamic>? detail;
    try {
      detail = await widget.api.followUpAssessmentDetail(t, id);
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackFormOpenFailed)));
      }
      return;
    } finally {
      if (mounted) setState(() => _loadingExtra = false);
    }
    if (!mounted) return;
    if (detail['can_submit'] != true) {
      final fu = detail['follow_up'];
      final due = fu is Map ? fu['due_at']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            due != null ? AppLocalizations.of(context).trnSnackFollowUpAvailableFrom(due) : AppLocalizations.of(context).trnSnackFollowUpNotYet,
          ),
        ),
      );
      return;
    }
    final questions = List<Map<String, dynamic>>.from(
      (detail['questions'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)) ?? [],
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).trnFollowUpDialogTitle),
        content: SizedBox(
          width: 440,
          child: _FollowUpFormContent(
            questions: questions,
            onSubmit: (responses) async {
              await widget.api.submitFollowUpAssessment(t, id, responses);
              if (ctx.mounted) Navigator.of(ctx).pop();
              await _reloadExtras();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackResponsesSaved)));
            },
          ),
        ),
      ),
    );
  }

  String _followUpTrainingTitle(AppLocalizations l, Map<String, dynamic> fu) {
    final en = fu['enrollment'];
    if (en is Map) {
      final tr = en['training'];
      if (tr is Map) {
        return tr['title']?.toString() ?? l.mfgTrainingFallbackTitle;
      }
    }
    return l.mfgTrainingFallbackTitle;
  }

  String _trainingRequestSubtitle(AppLocalizations l, Map<String, dynamic> r) {
    final eq = r['equipment'];
    String? eqLine;
    if (eq is Map) {
      final n = eq['name']?.toString();
      final m = eq['model']?.toString();
      if (n != null && n.isNotEmpty) {
        eqLine = m != null && m.isNotEmpty ? '$n ($m)' : n;
      }
    }
    final parts = <String>[
      if (eqLine != null) l.trnRequestListPark(eqLine),
      if (r['reason_label'] != null && r['reason_label'].toString().isNotEmpty)
        r['reason_label'].toString()
      else if (r['reason'] != null && r['reason'].toString().isNotEmpty)
        r['reason'].toString(),
      if (r['priority_label'] != null) r['priority_label'].toString(),
      if (r['desired_date'] != null) l.trnRequestListPref(r['desired_date'].toString()),
      if (r['latest_acceptable_date'] != null) l.trnRequestListLimit(r['latest_acceptable_date'].toString()),
    ];
    return parts.isEmpty ? l.trainReqDashNone : parts.join(' · ');
  }

  Future<void> _downloadCertificatePdf(Map<String, dynamic> c) async {
    final lang = AppLocalizations.of(context);
    final t = appAuth.token;
    final idRaw = c['id'];
    final cid = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
    final code = c['certificate_code']?.toString() ?? lang.trnCertCodeFallback;
    if (t == null || cid == null) return;
    setState(() => _loadingExtra = true);
    try {
      final bytes = await widget.api.downloadMyCertificatePdf(t, cid);
      if (!mounted) return;
      final safe = code.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '-');
      await FileSaver.instance.saveFile(
        name: lang.trnCertDownloadFilename(safe),
        fileExtension: 'pdf',
        bytes: bytes,
        mimeType: MimeType.pdf,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackCertPdfDownloaded)));
      }
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackCertPdfFailed)));
      }
    } finally {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  Future<void> _submitTrainingRequest() async {
    final t = appAuth.token;
    final iid = widget.institutionId;
    final rc = _reasonCodeId;
    if (t == null || iid == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackPickInstitution)));
      return;
    }
    if (rc == null || rc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackPickReason)));
      return;
    }
    setState(() => _loadingExtra = true);
    try {
      await widget.api.createTrainingRequest(
        t,
        institutionId: iid,
        reasonCode: rc,
        equipmentId: _selectedParkEquipmentId,
        priority: _priorityId,
        desiredDate: _desiredDate.text.trim().isEmpty ? null : _desiredDate.text.trim(),
        latestAcceptableDate: _latestAcceptableDate.text.trim().isEmpty ? null : _latestAcceptableDate.text.trim(),
        notes: _reqNotes.text.trim().isEmpty ? null : _reqNotes.text.trim(),
      );
      _desiredDate.clear();
      _latestAcceptableDate.clear();
      _reqNotes.clear();
      await _reloadExtras();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).trnSnackRequestSent)));
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.trnPreregTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 8),
        Text(l.trnPreregSubtitle, style: const TextStyle(color: Color(0xFF45464D))),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: l.trnFieldInstitutionOptional),
                  initialValue: widget.institutionId,
                  items: [
                    for (final i in widget.institutions)
                      DropdownMenuItem(value: _parseInt(i['id']), child: Text(i['name']?.toString() ?? '')),
                  ],
                  onChanged: widget.onInstitution,
                ),
                const SizedBox(height: 14),
                TextField(controller: widget.sector, decoration: InputDecoration(labelText: l.trnFieldSectorTeam)),
                const SizedBox(height: 14),
                TextField(controller: widget.equipment, decoration: InputDecoration(labelText: l.trnFieldEquipmentContext)),
                const SizedBox(height: 14),
                TextField(
                  controller: widget.sessionAt,
                  decoration: InputDecoration(
                    labelText: l.trnFieldSessionAtOptional,
                    hintText: l.trnHintDatetime,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: widget.loading ? null : widget.onSubmit,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF131B2E), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: widget.loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.trnBtnSaveContinue),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.trnCertificatesTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_loadingExtra)
          const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_certs.isEmpty)
          Text(l.trnCertificatesEmpty, style: const TextStyle(color: Color(0xFF45464D)))
        else
          Card(
            child: Column(
              children: [
                for (final c in _certs)
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC5A572)),
                    title: Text(c['certificate_code']?.toString() ?? ''),
                    subtitle: Text(
                      l.trnCertScoreValid(
                        c['score']?.toString() ?? l.trainReqDashNone,
                        c['expires_at']?.toString() ?? l.trainReqDashNone,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: l.trnTooltipCertPdf,
                      onPressed: _loadingExtra ? null : () => _downloadCertificatePdf(Map<String, dynamic>.from(c)),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(l.trnFollowUpsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l.trnFollowUpsIntro,
          style: const TextStyle(color: Color(0xFF45464D), fontSize: 13),
        ),
        const SizedBox(height: 8),
        if (_loadingExtra)
          const SizedBox.shrink()
        else if (_followUps.isEmpty)
          Text(l.trnFollowUpsEmpty, style: const TextStyle(color: Color(0xFF45464D)))
        else
          Card(
            child: Column(
              children: [
                for (final fu in _followUps)
                  ListTile(
                    leading: Icon(
                      fu['status']?.toString() == 'completed' ? Icons.check_circle_rounded : Icons.event_note_rounded,
                      color: fu['status']?.toString() == 'completed' ? const Color(0xFF059669) : const Color(0xFF00677D),
                    ),
                    title: Text(_followUpTrainingTitle(l, Map<String, dynamic>.from(fu))),
                    subtitle: Text(
                      l.trnFollowUpListSubtitle(
                        fu['days_offset']?.toString() ?? l.trainReqDashNone,
                        localizedFollowUpStatus(l, fu['status']?.toString()),
                        fu['due_at']?.toString() ?? l.trainReqDashNone,
                      ),
                    ),
                    trailing: fu['status']?.toString() == 'pending'
                        ? TextButton(
                            onPressed: _loadingExtra
                                ? null
                                : () {
                                    final i = _parseInt(fu['id']);
                                    if (i != null) unawaited(_openFollowUpAssessment(i));
                                  },
                            child: Text(l.trnFollowUpRespond),
                          )
                        : null,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(l.trnTrainingRequestTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l.trnTrainingRequestIntro,
          style: const TextStyle(color: Color(0xFF45464D), fontSize: 13),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_reasonOptions.isEmpty)
                  Text(l.trnLoadingOptions, style: const TextStyle(color: Color(0xFF45464D), fontSize: 13))
                else ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: l.trnFieldReason),
                    initialValue: _reasonCodeId,
                    items: [
                      for (final o in _reasonOptions)
                        DropdownMenuItem<String>(
                          value: o['id']?.toString(),
                          child: Text(o['label']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: _loadingExtra
                        ? null
                        : (v) => setState(() => _reasonCodeId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: l.trnFieldPriority),
                    initialValue: _priorityId,
                    items: [
                      for (final o in _priorityOptions)
                        DropdownMenuItem<String>(
                          value: o['id']?.toString() ?? 'normal',
                          child: Text(o['label']?.toString() ?? ''),
                        ),
                    ],
                    onChanged: _loadingExtra
                        ? null
                        : (v) => setState(() => _priorityId = v ?? 'normal'),
                  ),
                  const SizedBox(height: 12),
                  if (_parkEquipment.isNotEmpty)
                    DropdownButtonFormField<int?>(
                      decoration: InputDecoration(
                        labelText: l.trnFieldParkUnitOptional,
                        helperText: l.trnParkUnitHelper,
                      ),
                      initialValue: _selectedParkEquipmentId,
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text(l.trainReqDashNone)),
                        for (final row in _parkEquipment)
                          DropdownMenuItem<int?>(
                            value: _parseInt(row['id']),
                            child: Text(
                              '${row['name']?.toString() ?? ''} (${row['model']?.toString() ?? ''})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _loadingExtra
                          ? null
                          : (v) => setState(() => _selectedParkEquipmentId = v),
                    )
                  else if (!_loadingExtra)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        l.trnParkEmptyHint,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF45464D)),
                      ),
                    ),
                  if (_parkEquipment.isNotEmpty) const SizedBox(height: 12),
                  TextField(
                    controller: _desiredDate,
                    decoration: InputDecoration(
                      labelText: l.trnFieldPreferredDate,
                      hintText: l.trnHintDate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _latestAcceptableDate,
                    decoration: InputDecoration(
                      labelText: l.trnFieldLatestAcceptable,
                      hintText: l.trnHintDate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reqNotes,
                    decoration: InputDecoration(
                      labelText: l.trnFieldNotesOptional,
                      hintText: l.trnNotesHint,
                    ),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (_loadingExtra || _reasonOptions.isEmpty) ? null : _submitTrainingRequest,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D)),
                  child: Text(l.trnBtnSendRequest),
                ),
              ],
            ),
          ),
        ),
        if (_reqs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l.trnMyRequests, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                for (final r in _reqs)
                  ListTile(
                    title: Text(localizedTrainingRequestStatus(l, r['status']?.toString())),
                    subtitle: Text(_trainingRequestSubtitle(l, r)),
                  ),
              ],
            ),
          ),
        ],
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
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.trnJoinTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26)),
        const SizedBox(height: 8),
        Text(l.trnJoinIntro, style: const TextStyle(color: Color(0xFF45464D))),
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
                  decoration: InputDecoration(labelText: l.trnFieldAccessCode),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: loading ? null : onJoin,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00677D), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.trnBtnConfirmJoin),
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
    final l = AppLocalizations.of(context);
    final tr = enrollment?['training'] as Map<String, dynamic>?;
    final title = tr?['title']?.toString() ?? l.trnTrainingDefaultTitle;

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
                Text(l.trnWaitingRoomTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                Text(
                  l.trnWaitingRoomBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF45464D), height: 1.5),
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
    this.inRecovery = false,
    this.sessionPaused = false,
    this.scorePolicyHint,
  });

  final List<Map<String, dynamic>> questions;
  final int position;
  final int? pickedOptionId;
  final ValueChanged<int> onPick;
  final VoidCallback onConfirm;
  final bool loading;
  final bool inRecovery;
  final bool sessionPaused;
  final String? scorePolicyHint;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (inRecovery) ...[
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Text(
                inRecovery ? l.trnEmptyRecoverySync : l.trnEmptyNoQuestions,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF45464D)),
              ),
            ],
          ),
        ),
      );
    }
    final q = questions[position];
    final prompt = q['prompt']?.toString() ?? '';
    final options = (q['options'] as List<dynamic>?) ?? [];
    final total = questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sessionPaused)
          Material(
            color: const Color(0xFFFFF4E5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFB45309), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.trnPausedSessionBanner,
                      style: TextStyle(fontSize: 13, color: Colors.brown.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (inRecovery)
          Material(
            color: const Color(0xFFFFF7ED),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.refresh_rounded, color: Color(0xFFC2410C), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.trnRecoveryBanner,
                      style: TextStyle(fontSize: 13, color: Colors.brown.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (scorePolicyHint != null && scorePolicyHint!.trim().isNotEmpty)
          Material(
            color: const Color(0xFFF0F9FF),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue.shade800, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      scorePolicyHint!,
                      style: TextStyle(fontSize: 12, height: 1.35, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: Row(
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
              Text(l.trnProgressLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00677D), letterSpacing: 1.2)),
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
              Text(l.trnQuestionProgress(position + 1, total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                              enabled: !sessionPaused,
                              onTap: () => onPick(oid),
                            );
                          }),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: loading || sessionPaused ? null : onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF131B2E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(l.trnBtnConfirmAnswer),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final int id;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? const Color(0xFFE5E5E5)
        : (selected ? const Color(0xFF00677D) : const Color(0xFFC6C6CD));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: !enabled
            ? const Color(0xFFF5F5F5)
            : (selected ? const Color(0xFFEAF9FF) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _FollowUpFormContent extends StatefulWidget {
  const _FollowUpFormContent({required this.questions, required this.onSubmit});

  final List<Map<String, dynamic>> questions;
  final Future<void> Function(Map<String, dynamic> responses) onSubmit;

  @override
  State<_FollowUpFormContent> createState() => _FollowUpFormContentState();
}

class _FollowUpFormContentState extends State<_FollowUpFormContent> {
  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _textCtrls = {};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    for (final q in widget.questions) {
      final k = q['key']?.toString() ?? '';
      if ((q['type']?.toString() ?? '') == 'text') {
        _textCtrls[k] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    try {
      final out = <String, dynamic>{};
      for (final q in widget.questions) {
        final k = q['key']?.toString() ?? '';
        final t = q['type']?.toString() ?? 'text';
        if (t == 'text') {
          out[k] = _textCtrls[k]?.text ?? '';
        } else {
          out[k] = _values[k];
        }
      }
      await widget.onSubmit(out);
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final q in widget.questions) ...[
            Text(q['prompt']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputFor(context, q),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF131B2E)),
            child: _sending
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l.trnBtnSubmitResponses),
          ),
        ],
      ),
    );
  }

  Widget _inputFor(BuildContext context, Map<String, dynamic> q) {
    final k = q['key']?.toString() ?? '';
    switch (q['type']?.toString()) {
      case 'likert_5':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 1; i <= 5; i++)
              ChoiceChip(
                label: Text('$i'),
                selected: _values[k] == i,
                onSelected: (_) => setState(() => _values[k] = i),
              ),
          ],
        );
      case 'choice':
        final opts = (q['options'] as List?) ?? [];
        return RadioGroup<String>(
          groupValue: _values[k] as String?,
          onChanged: (v) => setState(() => _values[k] = v),
          child: Column(
            children: opts.map((raw) {
              final o = Map<String, dynamic>.from(raw as Map);
              final val = o['value']?.toString() ?? '';
              return RadioListTile<String>(
                value: val,
                title: Text(o['label']?.toString() ?? val),
              );
            }).toList(),
          ),
        );
      case 'text':
      default:
        final c = _textCtrls[k] ??= TextEditingController();
        return TextField(
          controller: c,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: AppLocalizations.of(context).trnOptionalHint,
          ),
        );
    }
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.enrollment, required this.onAgain});

  final Map<String, dynamic>? enrollment;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final score = enrollment?['score']?.toString() ?? l.trainReqDashNone;
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
                Text(l.trnResultTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Text(l.trnScoreLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF45464D))),
                Text(score, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onAgain,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                  child: Text(l.trnBtnJoinAnother),
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
