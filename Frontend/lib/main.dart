import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_version.dart';
import 'config.dart';
import 'firebase_bootstrap.dart';
import 'services/api_client.dart';
import 'services/auth_session.dart';

late final AuthSession appAuth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebaseWeb();
  appAuth = AuthSession();
  await appAuth.restore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF7F9FB);
    const onSurface = Color(0xFF191C1E);
    const outline = Color(0xFFC6C6CD);
    const primaryContainer = Color(0xFF131B2E);
    const secondary = Color(0xFF00677D);
    const secondaryContainer = Color(0xFF50D9FE);

    return AnimatedBuilder(
      animation: appAuth,
      builder: (context, _) {
        return MaterialApp(
      title: 'Appcation',
      theme: ThemeData(
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          headlineLarge: GoogleFonts.manrope(
            fontSize: 36,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: onSurface,
          ),
          headlineMedium: GoogleFonts.manrope(
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleLarge: GoogleFonts.manrope(
            fontSize: 20,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 18,
            height: 1.6,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF45464D),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF45464D),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: secondary,
          surface: background,
          primaryContainer: primaryContainer,
          secondaryContainer: secondaryContainer,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.08),
          elevation: 6,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondary, width: 1.2),
          ),
        ),
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
      home: appAuth.isAuthenticated ? const RoleHome() : const LoginUniversalScreen(),
        );
      },
    );
  }
}

/// Destino pós-login conforme perfil IAM da API.
class RoleHome extends StatelessWidget {
  const RoleHome({super.key});

  @override
  Widget build(BuildContext context) {
    switch (appAuth.role) {
      case 'trainee':
        return const PreCadastroScreen();
      case 'instructor':
      case 'institution_admin':
      case 'manufacturer_admin':
        return const DashboardInstrutorScreen();
      default:
        return const LoginUniversalScreen();
    }
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

class LoginUniversalScreen extends StatefulWidget {
  const LoginUniversalScreen({super.key});

  @override
  State<LoginUniversalScreen> createState() => _LoginUniversalScreenState();
}

class _LoginUniversalScreenState extends State<LoginUniversalScreen> {
  final _formLogin = GlobalKey<FormState>();
  final _emailLogin = TextEditingController();
  final _passwordLogin = TextEditingController();

  final _formRegister = GlobalKey<FormState>();
  final _nameRegister = TextEditingController();
  final _emailRegister = TextEditingController();
  final _passwordRegister = TextEditingController();

  bool _loadingLogin = false;
  bool _loadingRegister = false;
  String? _errorLogin;
  String? _errorRegister;

  @override
  void dispose() {
    _emailLogin.dispose();
    _passwordLogin.dispose();
    _nameRegister.dispose();
    _emailRegister.dispose();
    _passwordRegister.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
    });
    if (!(_formLogin.currentState?.validate() ?? false)) return;
    setState(() => _loadingLogin = true);
    try {
      await appAuth.login(_emailLogin.text, _passwordLogin.text);
    } on ApiException catch (e) {
      setState(() => _errorLogin = e.message);
    } catch (_) {
      setState(() => _errorLogin = 'Falha de conexão com a API.');
    } finally {
      if (mounted) setState(() => _loadingLogin = false);
    }
  }

  Future<void> _submitRegisterTrainee() async {
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
    });
    if (!(_formRegister.currentState?.validate() ?? false)) return;
    setState(() => _loadingRegister = true);
    try {
      await appAuth.register(
        name: _nameRegister.text,
        email: _emailRegister.text,
        password: _passwordRegister.text,
        role: 'trainee',
      );
    } on ApiException catch (e) {
      setState(() => _errorRegister = e.message);
    } catch (_) {
      setState(() => _errorRegister = 'Falha de conexão com a API.');
    } finally {
      if (mounted) setState(() => _loadingRegister = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Login Universal',
      showAppBar: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FB), Color(0xFFECEEF0)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/ADBb0uiBfLRiTNXO08j1P2IZWvshAg7Z9Cov-vEofM75n72DNP2GySWtw6G4jCFgDxrk5P41_SrvHlHfRfnovqLb-MHUJek6pEbWNdhDTeFq1SRfs8CEhqWds7APs33Meva5ib0gL8d5XtzADnwgs_bNsz2_fuLC1XlMqg9jWCaREZBjWGWMDmFajYRN3L4QAeEcmGKaWH1438zk9Q2hfrdT4lEzD7poZuProyJ_AJgjV1loVF22d9PH2WVm',
                        height: 56,
                        errorBuilder: (_, error, stackTrace) => const Icon(
                          Icons.medical_services,
                          size: 52,
                          color: Color(0xFF00677D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Acesse o App²cation', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Seu treinamento, sua evolução', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    _primaryButton(
                      context,
                      label: 'Continuar com Google',
                      icon: Icons.login,
                      onPressed: () => _snack('Login Google será habilitado na próxima entrega.'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFC6C6CD))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou selecione seu perfil de acesso',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFC6C6CD))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _profileTile(
                      context,
                      icon: Icons.note_alt_outlined,
                      title: 'Sou Instrutor ou Gestor',
                      subtitle: 'Gerenciamento administrativo e treinamentos',
                      onTap: () => _snack('Use e-mail e senha cadastrados na área abaixo.'),
                    ),
                    const SizedBox(height: 10),
                    _profileTile(
                      context,
                      icon: Icons.factory,
                      title: 'Sou Fabricante',
                      subtitle: 'Publicação de manuais e homologações',
                      onTap: () => _snack('Use e-mail e senha com perfil de fabricante.'),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFC6C6CD))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('acesso institucional', style: TextStyle(fontSize: 13, color: Color(0xFF76777D))),
                        ),
                        Expanded(child: Divider(color: Color(0xFFC6C6CD))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formLogin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailLogin,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(labelText: 'E-mail'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                              if (!v.contains('@')) return 'E-mail inválido.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordLogin,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            decoration: const InputDecoration(labelText: 'Senha'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe a senha.';
                              return null;
                            },
                          ),
                          if (_errorLogin != null) ...[
                            const SizedBox(height: 8),
                            Text(_errorLogin!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
                          ],
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _loadingLogin ? null : _submitLogin,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF131B2E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _loadingLogin
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Entrar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Primeiro acesso — treinando',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crie sua conta para seguir ao pré-registro.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Form(
                      key: _formRegister,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameRegister,
                            decoration: const InputDecoration(labelText: 'Nome completo'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailRegister,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'E-mail'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                              if (!v.contains('@')) return 'E-mail inválido.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordRegister,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Senha (mín. 8 caracteres)'),
                            validator: (v) {
                              if (v == null || v.length < 8) return 'Senha com pelo menos 8 caracteres.';
                              return null;
                            },
                          ),
                          if (_errorRegister != null) ...[
                            const SizedBox(height: 8),
                            Text(_errorRegister!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
                          ],
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _loadingRegister ? null : _submitRegisterTrainee,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF00677D), width: 1.2),
                            ),
                            child: _loadingRegister
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00677D)),
                                  )
                                : const Text('Cadastrar e continuar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'API: ${AppConfig.apiBaseUrl}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF76777D)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PreCadastroScreen extends StatefulWidget {
  const PreCadastroScreen({super.key});

  @override
  State<PreCadastroScreen> createState() => _PreCadastroScreenState();
}

class _PreCadastroScreenState extends State<PreCadastroScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _sector;
  late final TextEditingController _institution;
  late final TextEditingController _schedule;
  late final TextEditingController _equipment;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    final u = appAuth.user;
    _name = TextEditingController(text: u?['name']?.toString() ?? '');
    _email = TextEditingController(text: u?['email']?.toString() ?? '');
    _sector = TextEditingController();
    _institution = TextEditingController();
    _schedule = TextEditingController();
    _equipment = TextEditingController();
    _name.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _sector.dispose();
    _institution.dispose();
    _schedule.dispose();
    _equipment.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aceite os termos para continuar.')),
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed('/trainee/waiting');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Pré-Cadastro',
      showAppBar: false,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE6E8EA))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF00677D)),
                    const SizedBox(width: 10),
                    Text('Etapa 1 de 3', style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    TextButton(onPressed: () => appAuth.logout(), child: const Text('Sair')),
                    const SizedBox(width: 8),
                    Text('Pré-Registro', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    value: 0.33,
                    minHeight: 7,
                    backgroundColor: Color(0xFFE0E3E5),
                    color: Color(0xFF50D9FE),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text('Pré-Registro do Treinando', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Confirme seus dados para acessar a sala de treinamento.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name.text.isEmpty ? 'Treinando' : _name.text,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(_email.text.isEmpty ? '—' : _email.text),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome completo')),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: _sector, decoration: const InputDecoration(labelText: 'Setor')),
                  const SizedBox(height: 10),
                  TextField(controller: _institution, decoration: const InputDecoration(labelText: 'Instituição')),
                  const SizedBox(height: 10),
                  TextField(controller: _schedule, decoration: const InputDecoration(labelText: 'Data e Hora')),
                  const SizedBox(height: 10),
                  TextField(controller: _equipment, decoration: const InputDecoration(labelText: 'Equipamento')),
                  const SizedBox(height: 14),
                  CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Li e concordo com os termos de uso e política de privacidade.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.login),
                    label: const Text('Confirmar e entrar na sala de espera'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF131B2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
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

class SalaEsperaScreen extends StatelessWidget {
  const SalaEsperaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Sala de Espera',
      showAppBar: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFFEAF9FF), Color(0xFFF7F9FB)],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white70,
                border: Border(bottom: BorderSide(color: Color(0xFFE0E3E5))),
              ),
              child: const Row(
                children: [
                  Icon(Icons.medical_services, color: Color(0xFF00677D)),
                  SizedBox(width: 8),
                  Text('App²cation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                  Spacer(),
                  Chip(
                    avatar: Icon(Icons.wifi, color: Color(0xFF00677D), size: 16),
                    label: Text('Conexão Estável'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [BoxShadow(color: Color(0x220F172A), blurRadius: 30)],
                      ),
                      child: const Icon(Icons.schedule, size: 90, color: Color(0xFF00677D)),
                    ),
                    const SizedBox(height: 24),
                    Text('Aguardando início do treinamento', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'O instrutor iniciará em breve. Mantenha esta janela aberta.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/trainee/questionario'),
                      icon: const Icon(Icons.network_check),
                      label: const Text('Testar conexão e periféricos'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF131B2E),
                        foregroundColor: Colors.white,
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

class QuestionarioScreen extends StatelessWidget {
  const QuestionarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Questionário Progressivo',
      child: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE0E3E5)))),
            child: Row(
              children: [
                const Icon(Icons.monitor_heart, color: Color(0xFF00677D)),
                const SizedBox(width: 10),
                const Text('Avaliação Teórica: Monitorização Hemodinâmica'),
                const Spacer(),
                Chip(
                  avatar: const Icon(Icons.wifi, size: 16, color: Color(0xFF00677D)),
                  label: const Text('Tempo real'),
                  backgroundColor: const Color(0x3350D9FE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: const BorderSide(color: Color(0xFFB3EBFF))),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 310,
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PROGRESSO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF00677D))),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: .2,
                                borderRadius: BorderRadius.circular(8),
                                minHeight: 10,
                                backgroundColor: const Color(0xFFE0E3E5),
                              ),
                              const SizedBox(height: 8),
                              const Text('Questão 3 de 15 respondidas', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF191C1E), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Questão 03', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            const Text(
                              'Qual o valor considerado normal para o débito cardíaco (DC) em um adulto em repouso?',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView(
                                children: [
                                  for (final option in const [
                                    '1.5 a 3.0 L/min',
                                    '4.0 a 8.0 L/min',
                                    '10.0 a 12.5 L/min',
                                    'Depende apenas da frequência cardíaca',
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.all(16),
                                          side: const BorderSide(color: Color(0xFFC6C6CD), width: 2),
                                        ),
                                        child: Text(option, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check_circle),
                              label: const Text('CONFIRMAR RESPOSTA'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF131B2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              ),
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
          Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E3E5)))),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text('Aguardando liberação do instrutor', style: TextStyle(fontWeight: FontWeight.w700)),
                Spacer(),
                Icon(Icons.group, size: 18, color: Color(0xFF45464D)),
                SizedBox(width: 8),
                Text('42 Profissionais Conectados'),
              ],
            ),
          ),
        ],
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
            child: Column(
              children: [
                const _InstructorTopBar(title: 'Visão Geral'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ListView(
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            _KpiCard(title: 'Treinamentos', value: '32'),
                            _KpiCard(title: 'Média de Notas', value: '8.2'),
                            _KpiCard(title: 'Participantes', value: '147'),
                            _KpiCard(title: 'Status', value: 'Homologado ArtMed'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: SizedBox(
                            height: 240,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Últimos Treinamentos', style: Theme.of(context).textTheme.titleLarge),
                                  SizedBox(height: 12),
                                  Expanded(
                                    child: ListView(
                                      children: const [
                                        _DataRow('12 Out, 2023', 'Ventilador G5', 'Hospital Albert Einstein', '9.4'),
                                        _DataRow('08 Out, 2023', 'Monitor Multiparamétrico', 'InCor FMUSP', '8.7'),
                                        _DataRow('05 Out, 2023', 'Desfibrilador Pro', 'Santa Casa SP', '7.2'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow(this.date, this.equipment, this.institution, this.score);
  final String date;
  final String equipment;
  final String institution;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(date)),
          Expanded(child: Text(equipment, style: const TextStyle(fontWeight: FontWeight.w600))),
          SizedBox(width: 180, child: Text(institution)),
          SizedBox(width: 50, child: Text(score, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _InstructorTopBar extends StatelessWidget {
  const _InstructorTopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E3E5))),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 320,
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Buscar treinamentos ou participantes...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            tooltip: 'Sair',
            onPressed: () => appAuth.logout(),
            icon: const Icon(Icons.logout),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const CircleAvatar(child: Icon(Icons.person)),
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
            child: Column(
              children: [
                const _InstructorTopBar(title: 'Criar Novo Treinamento'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView(
                            children: const [
                              Text('Configuração Geral', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              SizedBox(height: 12),
                              TextField(decoration: InputDecoration(labelText: 'Fabricante')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Equipamento')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Treinamento padrão')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Data e horário')),
                              SizedBox(height: 16),
                              Text('Editor de Questionário', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Pergunta')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Opção A')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Opção B')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 300,
                          child: Card(
                            color: const Color(0xFF0F172A),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text('Acesso Rápido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  Container(
                                    color: Colors.white,
                                    width: 190,
                                    height: 190,
                                    child: const Icon(Icons.qr_code_2, size: 120),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('medtr.ai/vivid-e95-03', style: TextStyle(color: Color(0xFF50D9FE))),
                                ],
                              ),
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
            child: Column(
              children: [
                const _InstructorTopBar(title: 'Primeiro Acesso'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView(
                            children: const [
                              Text('Buscar Instituição', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Nome do Hospital ou CNPJ')),
                              SizedBox(height: 10),
                              TextField(decoration: InputDecoration(labelText: 'Observação para o gestor')),
                              SizedBox(height: 14),
                              FilledButton(onPressed: null, child: Text('Solicitar vínculo')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 320,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Status de Homologação', style: TextStyle(fontWeight: FontWeight.w700)),
                                  SizedBox(height: 10),
                                  ListTile(leading: Icon(Icons.domain), title: Text('Instituição'), subtitle: Text('Em análise')),
                                  ListTile(leading: Icon(Icons.precision_manufacturing), title: Text('Fabricantes'), subtitle: Text('Pendente')),
                                  ListTile(leading: Icon(Icons.history_edu), title: Text('Conselho Profissional'), subtitle: Text('Revisão')),
                                ],
                              ),
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
            child: Column(
              children: [
                const _InstructorTopBar(title: 'Sala de Comando'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Participantes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView(
                                      children: const [
                                        ListTile(leading: CircleAvatar(child: Text('AN')), title: Text('Amanda Nogueira'), subtitle: Text('Respondeu 4/10 questões'), trailing: Text('8.5')),
                                        ListTile(leading: CircleAvatar(child: Text('LB')), title: Text('Lucas Bezerra'), subtitle: Text('Digitando resposta...'), trailing: Text('7.2')),
                                        ListTile(leading: CircleAvatar(child: Text('RP')), title: Text('Renata Portela'), subtitle: Text('Respondeu 9/10 questões'), trailing: Text('9.8')),
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
                          flex: 6,
                          child: Card(
                            color: const Color(0xFF0F172A),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Painel de Controle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      FilledButton(onPressed: () {}, child: const Text('Iniciar')),
                                      FilledButton.tonal(onPressed: () {}, child: const Text('Pausar')),
                                      OutlinedButton(onPressed: () {}, child: const Text('Encerrar')),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Text('Bloco 1: Anatomia Cardíaca', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  const LinearProgressIndicator(value: .45, minHeight: 8, borderRadius: BorderRadius.all(Radius.circular(99))),
                                ],
                              ),
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

Widget _profileTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF2F4F6),
        border: Border.all(color: const Color(0xFFE0E3E5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00677D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF45464D))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF00677D)),
        ],
      ),
    ),
  );
}

