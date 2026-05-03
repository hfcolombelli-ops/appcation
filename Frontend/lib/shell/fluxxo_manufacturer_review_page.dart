import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n/api_exception_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/error_snacks.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../theme/instructor_page_chrome.dart';

/// Revisores Fluxxo (e-mail em MANUFACTURER_REVIEWER_EMAILS): fila e decisão.
class FluxxoManufacturerReviewPage extends StatefulWidget {
  const FluxxoManufacturerReviewPage({super.key, required this.api});

  final ProductionApi api;

  @override
  State<FluxxoManufacturerReviewPage> createState() => _FluxxoManufacturerReviewPageState();
}

class _FluxxoManufacturerReviewPageState extends State<FluxxoManufacturerReviewPage> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;
  final _busy = <int>{};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.api.manufacturerReviewQueue(t);
      if (mounted) {
        setState(() {
          _rows = list;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = localizedApiMessage(AppLocalizations.of(context), e);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).errApiConnection;
          _loading = false;
        });
      }
    }
  }

  Future<void> _decide(int id, String status) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _busy.add(id));
    try {
      await widget.api.patchManufacturerReview(t, id, validationStatus: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).fluxRevSnackStatusUpdated)),
        );
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) context.showLocalizedApiExceptionSnack(e);
    } catch (_) {
      if (mounted) context.showErrApiConnectionSnack();
    } finally {
      if (mounted) {
        setState(() => _busy.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) {
      return instructorShellScaffold(child: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return instructorShellScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: _reload, child: Text(l.actionRetry)),
              ],
            ),
          ),
        ),
      );
    }
    if (_rows.isEmpty) {
      return instructorShellScaffold(
        child: Center(
          child: Text(
            l.fluxRevEmpty,
            style: const TextStyle(color: Color(0xFF45464D)),
          ),
        ),
      );
    }
    return instructorShellScaffold(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
        Text(
          l.fluxRevQueueTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          l.fluxRevIntro,
          style: const TextStyle(color: Color(0xFF45464D)),
        ),
        const SizedBox(height: 20),
        ..._rows.expand((row) {
          final id = _parseId(row['id']);
          if (id == null) {
            return <Widget>[];
          }
          return [
            _ReviewCard(
              row: row,
              busy: _busy.contains(id),
              onApprove: () => _decide(id, 'active'),
              onReject: () => _decide(id, 'rejected'),
              onInfo: () => _decide(id, 'pending_info'),
            ),
          ];
        }),
      ],
    ),
    );
  }

  int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.row,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onInfo,
  });

  final Map<String, dynamic> row;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = row['name']?.toString() ?? l.trainReqDashNone;
    final id = row['id']?.toString() ?? '';
    final cnpj = row['cnpj']?.toString();
    final email = row['support_email']?.toString();

    return instructorShellCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 6),
            Text(l.fluxRevIdLine(id), style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
            if (cnpj != null && cnpj.isNotEmpty) Text(l.fluxRevCnpjLine(cnpj), style: const TextStyle(fontSize: 13)),
            if (email != null && email.isNotEmpty) Text(l.fluxRevSupportLine(email), style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: busy ? null : onApprove,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                  child: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.credBtnApprove),
                ),
                FilledButton.tonal(
                  onPressed: busy ? null : onInfo,
                  child: Text(l.fluxRevBtnRequestInfo),
                ),
                OutlinedButton(
                  onPressed: busy ? null : onReject,
                  child: Text(l.credBtnReject),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
