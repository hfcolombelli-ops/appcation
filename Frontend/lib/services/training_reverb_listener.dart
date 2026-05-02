import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/material.dart';

/// Fase da ligação WebSocket (Reverb) para indicador na UI — Fase 2.4.
enum TrainingRealtimeLinkPhase {
  /// Sem canal WS (Reverb desligado na API ou ainda não ligado).
  httpOnly,
  connecting,
  live,
  reconnecting,
  connectionLost,
}

TrainingRealtimeLinkPhase trainingRealtimePhaseFromLifecycle(PusherChannelsClientLifeCycleState state) {
  return switch (state) {
    PusherChannelsClientLifeCycleState.establishedConnection => TrainingRealtimeLinkPhase.live,
    PusherChannelsClientLifeCycleState.reconnecting => TrainingRealtimeLinkPhase.reconnecting,
    PusherChannelsClientLifeCycleState.pendingConnection => TrainingRealtimeLinkPhase.connecting,
    PusherChannelsClientLifeCycleState.inactive => TrainingRealtimeLinkPhase.httpOnly,
    PusherChannelsClientLifeCycleState.disposed => TrainingRealtimeLinkPhase.httpOnly,
    PusherChannelsClientLifeCycleState.connectionError => TrainingRealtimeLinkPhase.connectionLost,
    PusherChannelsClientLifeCycleState.disconnected => TrainingRealtimeLinkPhase.connectionLost,
    PusherChannelsClientLifeCycleState.gotPusherError => TrainingRealtimeLinkPhase.connectionLost,
  };
}

/// Subscrição ao canal público `training.{id}` e evento `training.signal` (Laravel Reverb).
/// Mantém o polling HTTP em paralelo como resiliência (Fase 2.3).
class TrainingReverbListener {
  TrainingReverbListener({
    required this.onSeq,
    required this.connectionErrorHandler,
    this.onLifecycle,
  });

  final void Function(int seq) onSeq;
  final void Function(dynamic exception, StackTrace stackTrace, void Function() refresh) connectionErrorHandler;
  final void Function(TrainingRealtimeLinkPhase phase)? onLifecycle;

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connEst;
  StreamSubscription<ChannelReadEvent>? _eventSub;
  StreamSubscription<PusherChannelsClientLifeCycleState>? _lifecycleSub;

  Future<void> connect({
    required String key,
    required String host,
    required int port,
    required bool useTls,
    required int trainingId,
  }) async {
    await dispose();

    final scheme = useTls ? 'wss' : 'ws';
    final options = PusherChannelsOptions.fromHost(
      scheme: scheme,
      host: host,
      key: key,
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
      port: port,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (dynamic exception, StackTrace trace, void Function() refresh) {
        connectionErrorHandler(exception, trace, refresh);
      },
      minimumReconnectDelayDuration: const Duration(seconds: 2),
    );

    _lifecycleSub = _client!.lifecycleStream.listen((state) {
      onLifecycle?.call(trainingRealtimePhaseFromLifecycle(state));
    });

    final channel = _client!.publicChannel('training.$trainingId');
    _eventSub = channel.bind('training.signal').listen((event) {
      final map = event.tryGetDataAsMap();
      if (map == null) {
        return;
      }
      final raw = map['seq'];
      final seq = raw is int ? raw : int.tryParse(raw.toString());
      if (seq != null) {
        onSeq(seq);
      }
    });

    _connEst = _client!.onConnectionEstablished.listen((_) {
      channel.subscribeIfNotUnsubscribed();
    });

    _client!.connect();
  }

  Future<void> dispose() async {
    await _lifecycleSub?.cancel();
    await _eventSub?.cancel();
    await _connEst?.cancel();
    _lifecycleSub = null;
    _eventSub = null;
    _connEst = null;
    _client?.dispose();
    _client = null;
  }
}

/// Indicador compacto para cabeçalho / sala de comando (Fase 2.4).
class TrainingRealtimeLinkChip extends StatelessWidget {
  const TrainingRealtimeLinkChip({super.key, required this.phase});

  final TrainingRealtimeLinkPhase phase;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color fg, IconData icon, String label) = switch (phase) {
      TrainingRealtimeLinkPhase.httpOnly => (
          const Color(0xFFF1F5F9),
          const Color(0xFFCBD5E1),
          const Color(0xFF475569),
          Icons.sync_rounded,
          'Sincronização: HTTP',
        ),
      TrainingRealtimeLinkPhase.connecting => (
          const Color(0xFFEFF6FF),
          const Color(0xFF93C5FD),
          const Color(0xFF1D4ED8),
          Icons.wifi_tethering_rounded,
          'Tempo real: a ligar…',
        ),
      TrainingRealtimeLinkPhase.live => (
          const Color(0xFFE8FFF4),
          const Color(0xFF10B981),
          const Color(0xFF065F46),
          Icons.bolt_rounded,
          'Tempo real: ativo',
        ),
      TrainingRealtimeLinkPhase.reconnecting => (
          const Color(0xFFFFF7ED),
          const Color(0xFFFDBA74),
          const Color(0xFF9A3412),
          Icons.wifi_find_rounded,
          'Tempo real: a reconectar…',
        ),
      TrainingRealtimeLinkPhase.connectionLost => (
          const Color(0xFFFFF7ED),
          const Color(0xFFFBBF24),
          const Color(0xFF92400E),
          Icons.wifi_off_rounded,
          'Tempo real: indisponível (HTTP)',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: fg),
          ),
        ],
      ),
    );
  }
}
