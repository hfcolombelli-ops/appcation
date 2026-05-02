import 'package:flutter/material.dart';
import 'config.dart';
import 'app_version.dart';
import 'firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebaseWeb();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const primaryContainer = Color(0xFF131B2E);
    const secondary = Color(0xFF00677D);
    const secondaryContainer = Color(0xFF50D9FE);

    return MaterialApp(
      title: 'Appcation',
      theme: ThemeData(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: secondary,
          surface: background,
          primaryContainer: primaryContainer,
          secondaryContainer: secondaryContainer,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Color(0xFF191C1E),
        ),
      ),
      routes: {
        '/login': (_) => const LoginUniversalScreen(),
        '/trainee/pre-cadastro': (_) => const PreCadastroScreen(),
        '/trainee/waiting': (_) => const SalaEsperaScreen(),
        '/trainee/questionario': (_) => const QuestionarioScreen(),
        '/instructor/dashboard': (_) => const DashboardInstrutorScreen(),
        '/instructor/treinamento': (_) => const CriarTreinamentoScreen(),
        '/instructor/credenciamento': (_) => const CredenciamentoScreen(),
        '/instructor/comando': (_) => const SalaComandoScreen(),
      },
      initialRoute: '/login',
    );
  }
}

class VersionBadge extends StatelessWidget {
  const VersionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC6C6CD)),
      ),
      child: Text(
        AppVersion.current,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF45464D),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.child,
    super.key,
    this.showAppBar = true,
  });

  final String title;
  final Widget child;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Stack(
        children: [
          SafeArea(child: child),
          const Positioned(left: 16, bottom: 16, child: VersionBadge()),
        ],
      ),
    );
  }
}

class LoginUniversalScreen extends StatelessWidget {
  const LoginUniversalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Login Universal',
      showAppBar: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services, size: 54, color: Color(0xFF00677D)),
            const SizedBox(height: 12),
            Text(
              'Acesse o App²cation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF131B2E),
                  ),
            ),
            const SizedBox(height: 24),
            _primaryButton(
              context,
              label: 'Continuar com Google',
              icon: Icons.login,
              onPressed: () => Navigator.pushNamed(context, '/trainee/pre-cadastro'),
            ),
            const SizedBox(height: 12),
            _secondaryButton(
              context,
              label: 'Sou Instrutor ou Gestor',
              onPressed: () => Navigator.pushNamed(context, '/instructor/dashboard'),
            ),
            const SizedBox(height: 12),
            _secondaryButton(
              context,
              label: 'Sou Fabricante',
              onPressed: () => Navigator.pushNamed(context, '/instructor/dashboard'),
            ),
            const SizedBox(height: 16),
            Text('API: ${AppConfig.apiBaseUrl}'),
          ],
        ),
      ),
    );
  }
}

class PreCadastroScreen extends StatelessWidget {
  const PreCadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Pré-Cadastro',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'Pré-Registro do Treinando',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Confirme seus dados para acessar a sala de treinamento.'),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(labelText: 'Nome completo')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Setor')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Instituição')),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/trainee/waiting'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Confirmar e entrar na sala de espera'),
            ),
          ],
        ),
      ),
    );
  }
}

class SalaEsperaScreen extends StatelessWidget {
  const SalaEsperaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Sala de Espera',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 96, color: Color(0xFF00677D)),
            const SizedBox(height: 16),
            Text(
              'Aguardando início do treinamento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('O instrutor iniciará em breve.'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/trainee/questionario'),
              icon: const Icon(Icons.network_check),
              label: const Text('Testar conexão'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionarioScreen extends StatelessWidget {
  const QuestionarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Questionário Progressivo',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: 0.2,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: const Color(0xFFE0E3E5),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Questão 3 de 15'),
                    const SizedBox(height: 8),
                    const Text(
                      'Qual o valor considerado normal para o débito cardíaco?',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    for (final option in const [
                      '1.5 a 3.0 L/min',
                      '4.0 a 8.0 L/min',
                      '10.0 a 12.5 L/min',
                      'Depende apenas da frequência cardíaca',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(option),
                          ),
                        ),
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

class DashboardInstrutorScreen extends StatelessWidget {
  const DashboardInstrutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Dashboard do Instrutor',
      child: Row(
        children: [
          _InstructorSidebar(current: '/instructor/dashboard'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text('Visão Geral', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _KpiCard(title: 'Treinamentos', value: '32'),
                      _KpiCard(title: 'Média de Notas', value: '8.2'),
                      _KpiCard(title: 'Participantes', value: '147'),
                      _KpiCard(title: 'Status', value: 'Homologado'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CriarTreinamentoScreen extends StatelessWidget {
  const CriarTreinamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Criar Treinamento',
      child: Row(
        children: [
          _InstructorSidebar(current: '/instructor/treinamento'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: const [
                  Text('Configuração Geral', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Título do treinamento')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Equipamento')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Data e horário')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CredenciamentoScreen extends StatelessWidget {
  const CredenciamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Credenciamento e Vínculo',
      child: Row(
        children: [
          _InstructorSidebar(current: '/instructor/credenciamento'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: const [
                  Text('Primeiro Acesso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Hospital/Instituição')),
                  SizedBox(height: 12),
                  TextField(decoration: InputDecoration(labelText: 'Observação para gestor')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SalaComandoScreen extends StatelessWidget {
  const SalaComandoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Sala de Comando',
      child: Row(
        children: [
          _InstructorSidebar(current: '/instructor/comando'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sessão em tempo real', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(onPressed: () {}, child: const Text('Iniciar')),
                      FilledButton.tonal(onPressed: () {}, child: const Text('Pausar')),
                      OutlinedButton(onPressed: () {}, child: const Text('Encerrar')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Monitoramento de participantes, blocos e repescagem em tempo real.'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructorSidebar extends StatelessWidget {
  const _InstructorSidebar({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData)>[
      ('Dashboard', '/instructor/dashboard', Icons.dashboard),
      ('Sala de Comando', '/instructor/comando', Icons.monitor_heart),
      ('Treinamentos', '/instructor/treinamento', Icons.add_box),
      ('Credenciamento', '/instructor/credenciamento', Icons.verified_user),
    ];

    return Container(
      width: 280,
      color: const Color(0xFF0F172A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          const Text(
            'MedTraining',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
          ),
          const SizedBox(height: 24),
          for (final item in items)
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: item.$2 == current ? const Color(0x334CD6FB) : null,
              leading: Icon(item.$3, color: item.$2 == current ? const Color(0xFF50D9FE) : const Color(0xFF94A3B8)),
              title: Text(
                item.$1,
                style: TextStyle(
                  color: item.$2 == current ? const Color(0xFF50D9FE) : const Color(0xFFCBD5E1),
                ),
              ),
              onTap: () => Navigator.pushReplacementNamed(context, item.$2),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF45464D))),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _primaryButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 360,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
      ),
    ),
  );
}

Widget _secondaryButton(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 360,
    child: OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}
