import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/api_client.dart';
import '../services/production_api.dart';
import '../widgets/version_badge.dart';

/// Área do fabricante: perfil da empresa e catálogo de equipamentos (instituição nula).
class ManufacturerShell extends StatefulWidget {
  const ManufacturerShell({super.key});

  @override
  State<ManufacturerShell> createState() => _ManufacturerShellState();
}

class _ManufacturerShellState extends State<ManufacturerShell> {
  final _api = ProductionApi(ApiClient());

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _manufacturer;
  List<Map<String, dynamic>> _equipment = [];

  final _name = TextEditingController();
  final _supportEmail = TextEditingController();
  final _cnpj = TextEditingController();

  final _eqName = TextEditingController();
  final _eqModel = TextEditingController();
  final _eqSector = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _name.dispose();
    _supportEmail.dispose();
    _cnpj.dispose();
    _eqName.dispose();
    _eqModel.dispose();
    _eqSector.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prof = await _api.manufacturerProfile(t);
      final m = Map<String, dynamic>.from(prof['manufacturer'] as Map);
      final list = await _api.manufacturerEquipmentList(t);
      if (!mounted) return;
      setState(() {
        _manufacturer = m;
        _equipment = list;
        _name.text = m['name']?.toString() ?? '';
        _supportEmail.text = m['support_email']?.toString() ?? '';
        _cnpj.text = m['cnpj']?.toString() ?? '';
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar dados.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.updateManufacturerProfile(t, {
        'name': _name.text.trim(),
        'support_email': _supportEmail.text.trim().isEmpty ? null : _supportEmail.text.trim(),
        'cnpj': _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _addEquipment() async {
    final t = appAuth.token;
    if (t == null) return;
    if (_eqName.text.trim().isEmpty || _eqModel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e modelo são obrigatórios.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.createManufacturerEquipment(
        t,
        name: _eqName.text.trim(),
        model: _eqModel.text.trim(),
        sector: _eqSector.text.trim().isEmpty ? null : _eqSector.text.trim(),
      );
      _eqName.clear();
      _eqModel.clear();
      _eqSector.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipamento criado.')));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteEquipment(int id) async {
    final t = appAuth.token;
    if (t == null) return;
    setState(() => _loading = true);
    try {
      await _api.deleteManufacturerEquipment(t, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removido.')));
      }
      await _reload();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = appAuth.user;
    final email = user?['email']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.white,
                elevation: 1,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fabricante',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                              ),
                              Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
                            ],
                          ),
                        ),
                        TextButton(onPressed: () => appAuth.logout(), child: const Text('Sair')),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _loading && _manufacturer == null
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _manufacturer == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  FilledButton(onPressed: _reload, child: const Text('Tentar novamente')),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _reload,
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                Text('Empresa', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _name,
                                  decoration: const InputDecoration(labelText: 'Nome'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _supportEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(labelText: 'E-mail de suporte'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _cnpj,
                                  decoration: const InputDecoration(labelText: 'CNPJ'),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: _loading ? null : _saveProfile,
                                  child: const Text('Guardar perfil'),
                                ),
                                const SizedBox(height: 32),
                                Text('Catálogo (homologações)', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(
                                  'Equipamentos aqui ficam sem instituição — visíveis para montagem de treinos.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF45464D)),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _eqName,
                                  decoration: const InputDecoration(labelText: 'Nome do equipamento'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _eqModel,
                                  decoration: const InputDecoration(labelText: 'Modelo'),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _eqSector,
                                  decoration: const InputDecoration(labelText: 'Setor (opcional)'),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _loading ? null : _addEquipment,
                                  child: const Text('Adicionar ao catálogo'),
                                ),
                                const SizedBox(height: 20),
                                if (_equipment.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: Text('Nenhum equipamento ainda.')),
                                  )
                                else
                                  ..._equipment.map((row) {
                                    final id = row['id'];
                                    final iid = id is int ? id : int.tryParse(id.toString());
                                    final title = row['name']?.toString() ?? '';
                                    final model = row['model']?.toString() ?? '';
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        title: Text(title),
                                        subtitle: Text(model),
                                        trailing: iid != null
                                            ? IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                onPressed: _loading ? null : () => _deleteEquipment(iid),
                                              )
                                            : null,
                                      ),
                                    );
                                  }),
                              ],
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
}
