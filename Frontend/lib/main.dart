import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'config.dart';
import 'firebase_bootstrap.dart';
import 'services/api_client.dart';
import 'services/auth_session.dart';
import 'shell/instructor_shell.dart';
import 'shell/trainee_shell.dart';
import 'widgets/version_badge.dart';

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
        return const TraineeShell();
      case 'instructor':
      case 'institution_admin':
      case 'manufacturer_admin':
        return const InstructorShell();
      default:
        return const LoginUniversalScreen();
    }
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

