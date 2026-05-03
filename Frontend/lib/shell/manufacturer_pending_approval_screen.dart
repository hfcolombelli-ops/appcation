import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Ecrã dedicado enquanto `validation_status == pending_validation`.
class ManufacturerPendingApprovalScreen extends StatelessWidget {
  const ManufacturerPendingApprovalScreen({
    super.key,
    required this.manufacturer,
    required this.userEmail,
    required this.onLogout,
    required this.onRefresh,
  });

  final Map<String, dynamic> manufacturer;
  final String userEmail;
  final VoidCallback onLogout;
  /// Re-lê perfil fabricante (ex.: após aprovação passar a `active`).
  final Future<void> Function() onRefresh;

  String _fmtSubmitted(dynamic raw) {
    if (raw == null) return '—';
    final s = raw.toString();
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    final local = dt.toLocal();
    final d =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final t =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$d às $t';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final protocol = manufacturer['validation_protocol']?.toString() ?? '—';
    final submitted = manufacturer['validation_submitted_at'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.schedule_rounded, size: 48, color: Colors.amber.shade800),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              l.mfgPendingTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l.mfgPendingBody,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF45464D)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.mfgPendingSla,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '${l.mfgPendingEmailNotice}\n$userEmail',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF45464D)),
                            ),
                            const SizedBox(height: 28),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.blueGrey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '${l.mfgPendingProtocol}: $protocol',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(l.mfgPendingStatusReview, style: const TextStyle(color: Color(0xFF45464D))),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${l.mfgPendingSubmittedAt}: ${_fmtSubmitted(submitted)}',
                                      style: const TextStyle(color: Color(0xFF45464D)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              l.mfgPendingSupport,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
                            ),
                            const SizedBox(height: 28),
                            OutlinedButton.icon(
                              onPressed: onLogout,
                              icon: const Icon(Icons.logout_rounded),
                              label: Text(l.mfgLogout),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
