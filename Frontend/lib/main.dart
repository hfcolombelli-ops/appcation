import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'config.dart';
import 'firebase_bootstrap.dart';
import 'services/api_client.dart';
import 'services/auth_session.dart';
import 'shell/instructor_shell.dart';
import 'shell/manufacturer_shell.dart';
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
      case 'manufacturer_admin':
        return const ManufacturerShell();
      case 'instructor':
      case 'institution_admin':
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

enum _AuthPhase { entry, register }

class _LoginUniversalScreenState extends State<LoginUniversalScreen> {
  final _formLogin = GlobalKey<FormState>();
  final _emailLogin = TextEditingController();
  final _passwordLogin = TextEditingController();

  final _formRegister = GlobalKey<FormState>();
  final _nameRegister = TextEditingController();
  final _emailRegister = TextEditingController();
  final _passwordRegister = TextEditingController();
  final _mfgNameRegister = TextEditingController();
  final _mfgCnpjRegister = TextEditingController();

  final _mfgNameGoogle = TextEditingController();
  final _mfgCnpjGoogle = TextEditingController();

  _AuthPhase _phase = _AuthPhase.entry;
  /// Conta por e-mail: treinando ou fabricante.
  String _registerAccountType = 'trainee';

  bool _loadingLogin = false;
  bool _loadingRegister = false;
  bool _loadingGoogle = false;
  String? _errorLogin;
  String? _errorRegister;
  String? _errorRegisterManufacturer;
  String _googleRole = 'trainee';

  @override
  void dispose() {
    _emailLogin.dispose();
    _passwordLogin.dispose();
    _nameRegister.dispose();
    _emailRegister.dispose();
    _passwordRegister.dispose();
    _mfgNameRegister.dispose();
    _mfgCnpjRegister.dispose();
    _mfgNameGoogle.dispose();
    _mfgCnpjGoogle.dispose();
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

  void _openRegisterCard() {
    setState(() {
      _phase = _AuthPhase.register;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
  }

  void _backToEntry() {
    setState(() {
      _phase = _AuthPhase.entry;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
  }

  Future<void> _submitRegister() async {
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
    if (!(_formRegister.currentState?.validate() ?? false)) return;
    if (_registerAccountType == 'manufacturer_admin' && _mfgNameRegister.text.trim().isEmpty) {
      setState(() => _errorRegisterManufacturer = 'Informe o nome da empresa.');
      return;
    }
    setState(() => _loadingRegister = true);
    try {
      if (_registerAccountType == 'trainee') {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'trainee',
        );
      } else {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'manufacturer_admin',
          manufacturerName: _mfgNameRegister.text.trim(),
          manufacturerCnpj: _mfgCnpjRegister.text.trim().isEmpty ? null : _mfgCnpjRegister.text.trim(),
        );
      }
    } on ApiException catch (e) {
      if (_registerAccountType == 'manufacturer_admin') {
        setState(() => _errorRegisterManufacturer = e.message);
      } else {
        setState(() => _errorRegister = e.message);
      }
    } catch (_) {
      if (_registerAccountType == 'manufacturer_admin') {
        setState(() => _errorRegisterManufacturer = 'Falha de conexão com a API.');
      } else {
        setState(() => _errorRegister = 'Falha de conexão com a API.');
      }
    } finally {
      if (mounted) setState(() => _loadingRegister = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
    if (AppConfig.googleWebClientId.trim().isEmpty) {
      _snack(
        'Configure GOOGLE_WEB_CLIENT_ID ao executar o Flutter (mesmo ID que GOOGLE_CLIENT_ID no servidor).',
      );
      return;
    }
    if (_googleRole == 'manufacturer_admin' && _mfgNameGoogle.text.trim().isEmpty) {
      _snack('Informe o nome do fabricante antes de continuar com Google.');
      return;
    }
    setState(() => _loadingGoogle = true);
    try {
      await appAuth.loginWithGoogle(
        role: _googleRole,
        manufacturerName: _mfgNameGoogle.text.trim().isEmpty ? null : _mfgNameGoogle.text.trim(),
        manufacturerCnpj: _mfgCnpjGoogle.text.trim().isEmpty ? null : _mfgCnpjGoogle.text.trim(),
      );
    } on ApiException catch (e) {
      setState(() => _errorLogin = e.message);
    } on StateError catch (e) {
      _snack(e.message);
    } catch (_) {
      setState(() => _errorLogin = 'Falha de conexão com a API.');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static const _googleRoles = <({String id, String label, IconData icon})>[
    (id: 'trainee', label: 'Treinando', icon: Icons.school_outlined),
    (id: 'instructor', label: 'Instrutor', icon: Icons.verified_user_outlined),
    (id: 'institution_admin', label: 'Gestor', icon: Icons.apartment_outlined),
    (id: 'manufacturer_admin', label: 'Fabricante', icon: Icons.precision_manufacturing_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AppShell(
      key: const ValueKey('login-universal'),
      title: 'Login Universal',
      showAppBar: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4F8), Color(0xFFE8EEF3), Color(0xFFF7F9FB)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: _phase == _AuthPhase.entry
                  ? _buildEntryCard(context, tt, key: const ValueKey('card-entry'))
                  : _buildRegisterCard(context, tt, key: const ValueKey('card-register')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, TextTheme tt, {Key? key}) {
    return Card(
      key: key,
      elevation: 1.5,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: const Color(0xFF0F172A).withValues(alpha: 0.06)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida/ADBb0uiBfLRiTNXO08j1P2IZWvshAg7Z9Cov-vEofM75n72DNP2GySWtw6G4jCFgDxrk5P41_SrvHlHfRfnovqLb-MHUJek6pEbWNdhDTeFq1SRfs8CEhqWds7APs33Meva5ib0gL8d5XtzADnwgs_bNsz2_fuLC1XlMqg9jWCaREZBjWGWMDmFajYRN3L4QAeEcmGKaWH1438zk9Q2hfrdT4lEzD7poZuProyJ_AJgjV1loVF22d9PH2WVm',
                  height: 48,
                  errorBuilder: (_, _, _) => const Icon(Icons.medical_services, size: 44, color: Color(0xFF00677D)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('App²cation', textAlign: TextAlign.center, style: tt.headlineMedium?.copyWith(fontSize: 26, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(
              'Treino clínico com ritmo e clareza',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: const Color(0xFF5C5E66), height: 1.35),
            ),
            const SizedBox(height: 16),
            Text(
              'Perfil (primeiro acesso Google)',
              style: tt.labelMedium?.copyWith(
                color: const Color(0xFF45464D),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: _googleRoles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final r = _googleRoles[i];
                  return _GoogleRoleChip(
                    label: r.label,
                    icon: r.icon,
                    selected: _googleRole == r.id,
                    onTap: _loadingGoogle ? null : () => setState(() => _googleRole = r.id),
                  );
                },
              ),
            ),
            if (_googleRole == 'manufacturer_admin') ...[
              const SizedBox(height: 14),
              TextField(
                controller: _mfgNameGoogle,
                decoration: const InputDecoration(
                  labelText: 'Empresa (fabricante)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mfgCnpjGoogle,
                decoration: const InputDecoration(
                  labelText: 'CNPJ (opcional)',
                  isDense: true,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _primaryButton(
              context,
              label: _loadingGoogle ? 'A ligar ao Google…' : 'Continuar com Google',
              icon: Icons.login_rounded,
              onPressed: _loadingGoogle ? null : _submitGoogle,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: Divider(height: 1, color: Color(0xFFDCE0E5))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('ou e-mail', style: tt.labelMedium?.copyWith(color: const Color(0xFF76777D))),
                ),
                const Expanded(child: Divider(height: 1, color: Color(0xFFDCE0E5))),
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
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      isDense: true,
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      isDense: true,
                    ),
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
                    key: const ValueKey('login-submit'),
                    onPressed: _loadingLogin ? null : _submitLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF131B2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 8),
            Text(
              'Instrutor e gestor institucional: use o e-mail e senha fornecidos pela sua organização.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: const Color(0xFF8E9099), height: 1.35),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _openRegisterCard,
              icon: const Icon(Icons.person_add_outlined, size: 20),
              label: const Text('Criar conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00677D),
                side: const BorderSide(color: Color(0xFF00677D)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 14),
              Text(
                'API: ${AppConfig.apiBaseUrl}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard(BuildContext context, TextTheme tt, {Key? key}) {
    return Card(
      key: key,
      elevation: 1.5,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: const Color(0xFF0F172A).withValues(alpha: 0.06)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  key: const ValueKey('register-back'),
                  onPressed: _backToEntry,
                  style: IconButton.styleFrom(foregroundColor: const Color(0xFF45464D)),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Voltar',
                ),
                Expanded(
                  child: Text(
                    'Criar conta',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Escolha o tipo de conta e preencha os dados.',
              style: tt.bodyMedium?.copyWith(color: const Color(0xFF5C5E66)),
            ),
            const SizedBox(height: 20),
            Text(
              'Tipo de conta',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AccountTypeMiniCard(
                    label: 'Treinando',
                    icon: Icons.school_outlined,
                    selected: _registerAccountType == 'trainee',
                    onTap: () => setState(() => _registerAccountType = 'trainee'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AccountTypeMiniCard(
                    label: 'Fabricante',
                    icon: Icons.precision_manufacturing_outlined,
                    selected: _registerAccountType == 'manufacturer_admin',
                    onTap: () => setState(() => _registerAccountType = 'manufacturer_admin'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formRegister,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameRegister,
                    decoration: const InputDecoration(labelText: 'Nome completo', isDense: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailRegister,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail', isDense: true),
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
                    decoration: const InputDecoration(
                      labelText: 'Senha (mín. 8 caracteres)',
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) return 'Mínimo 8 caracteres.';
                      return null;
                    },
                  ),
                  if (_registerAccountType == 'manufacturer_admin') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mfgNameRegister,
                      decoration: const InputDecoration(
                        labelText: 'Nome da empresa',
                        isDense: true,
                      ),
                      validator: (v) {
                        if (_registerAccountType != 'manufacturer_admin') return null;
                        if (v == null || v.trim().isEmpty) return 'Informe o nome da empresa.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mfgCnpjRegister,
                      decoration: const InputDecoration(
                        labelText: 'CNPJ (opcional)',
                        isDense: true,
                      ),
                    ),
                  ],
                  if (_errorRegister != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorRegister!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
                  ],
                  if (_errorRegisterManufacturer != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorRegisterManufacturer!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadingRegister ? null : _submitRegister,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF00677D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loadingRegister
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Concluir cadastro'),
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

Widget _primaryButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

/// Chip compacto em linha (scroll horizontal) para perfil Google.
class _GoogleRoleChip extends StatelessWidget {
  const _GoogleRoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00677D);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F4F7) : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE0E4E8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? accent : const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? const Color(0xFF0D3D47) : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeMiniCard extends StatelessWidget {
  const _AccountTypeMiniCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00677D);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F4F7) : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE0E4E8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? accent : const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? const Color(0xFF0D3D47) : const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

