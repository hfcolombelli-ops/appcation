import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/api_exception_localizations.dart';
import 'l10n/app_localizations.dart';
import 'app_navigator.dart';
import 'app_state.dart';
import 'app_version.dart';
import 'config.dart';
import 'theme/clinical_precision_tokens.dart';
import 'firebase_bootstrap.dart';
import 'services/api_client.dart';
import 'services/auth_session.dart';
import 'shell/instructor_shell.dart';
import 'shell/manufacturer_shell.dart';
import 'shell/profile_gate_screen.dart';
import 'shell/trainee_shell.dart';
import 'screens/invite_accept_screen.dart';
import 'screens/trainee_public_join_screen.dart';
import 'login/login_identity_parser.dart';
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
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('pt');
        for (final l in supported) {
          if (l.languageCode == locale.languageCode) {
            return l;
          }
        }
        return const Locale('pt');
      },
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
        fontFamilyFallback: [GoogleFonts.notoSans().fontFamily ?? 'sans-serif'],
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
        '/invite': (_) => const InviteAcceptScreen(),
        '/join-training': (_) => const TraineePublicJoinScreen(),
        '/role-home': (_) => const RoleHome(),
      },
      home: const _SessionGate(),
        );
      },
    );
  }
}

/// Escolhe ecrã inicial: rotas públicas Web (convite / inscrição por link) ou login / área autenticada.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final uri = Uri.base;
      final path = uri.path.toLowerCase();
      final frag = uri.fragment.toLowerCase();
      final onInvite = path.endsWith('/invite') || path.contains('/invite') || frag.contains('invite');
      if (onInvite) {
        return const InviteAcceptScreen();
      }
      final onJoinTraining = path.endsWith('/join-training') ||
          path.contains('join-training') ||
          frag.contains('join-training');
      if (onJoinTraining) {
        return const TraineePublicJoinScreen();
      }
    }
    if (appAuth.isAuthenticated) {
      return const RoleHome();
    }
    return const LoginUniversalScreen();
  }
}

/// Destino pós-login conforme perfil IAM da API.
/// Fluxograma: `docs/product/fluxo_app2cation.mermaid`. IDs de telas: `lib/product/screen_catalog_map.dart`.
class RoleHome extends StatelessWidget {
  const RoleHome({super.key});

  @override
  Widget build(BuildContext context) {
    if (appAuth.needsProfileGate) {
      return const ProfileGateScreen();
    }
    final role = appAuth.role?.trim();
    if (role == null || role.isEmpty) {
      return const ProfileGateScreen();
    }
    switch (role) {
      case 'trainee':
        return const TraineeShell();
      case 'manufacturer_admin':
        return const ManufacturerShell();
      case 'instructor':
      case 'institution_admin':
        return const InstructorShell();
      default:
        return const ProfileGateScreen();
    }
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.child,
    super.key,
    this.showAppBar = true,
    this.showVersionBadge = true,
  });

  final String title;
  final Widget child;
  final bool showAppBar;
  final bool showVersionBadge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Stack(
        children: [
          SafeArea(child: child),
          if (showVersionBadge) const Positioned(left: 16, bottom: 16, child: VersionBadge()),
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

/// Persona no ecrã de entrada: utilizador (treinando/instrutor/instituição) vs fabricante.
enum _LoginPersona { user, manufacturer }

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

  _AuthPhase _phase = _AuthPhase.entry;
  /// `trainee` | `instructor` | `manufacturer_admin`.
  String _registerAccountType = 'trainee';

  bool _loadingLogin = false;
  bool _loadingRegister = false;
  String? _errorLogin;
  String? _errorRegister;
  String? _errorRegisterManufacturer;

  bool _obscurePassword = true;
  LoginIdentityType _previewType = LoginIdentityType.unknown;
  _LoginPersona _loginPersona = _LoginPersona.user;
  /// Passo 1 do registo: escolha do perfil (pills); passo 2: formulário.
  bool _registerChoosingRole = true;

  @override
  void initState() {
    super.initState();
    _emailLogin.addListener(_onIdentifierChanged);
    _previewType = parseLoginIdentity(_emailLogin.text);
  }

  void _onIdentifierChanged() {
    final raw = _emailLogin.text;
    final normalized = normalizeIdentifierInput(raw);
    final next = normalized.contains('@') ? normalized : normalized.toUpperCase();
    if (next != raw) {
      _emailLogin.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
      return;
    }
    final parsed = parseLoginIdentity(next);
    if (parsed != _previewType && mounted) {
      setState(() => _previewType = parsed);
    }
  }

  @override
  void dispose() {
    _emailLogin.removeListener(_onIdentifierChanged);
    _emailLogin.dispose();
    _passwordLogin.dispose();
    _nameRegister.dispose();
    _emailRegister.dispose();
    _passwordRegister.dispose();
    _mfgNameRegister.dispose();
    _mfgCnpjRegister.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final s = AppLocalizations.of(context);
    final id = _emailLogin.text.trim();
    final pass = _passwordLogin.text;
    if (id.isEmpty || pass.isEmpty) {
      _snack(s.loginEmptyIdentifierPassword);
      return;
    }
    final typ = parseLoginIdentity(id);
    if (typ == LoginIdentityType.unknown) {
      _snack(s.loginIdentifierInvalidClient);
      return;
    }
    if (_loginPersona == _LoginPersona.user) {
      if (typ != LoginIdentityType.email) {
        _snack(s.loginPasswordRequiresEmail);
        return;
      }
    } else {
      if (typ != LoginIdentityType.email && typ != LoginIdentityType.institutionCnpj) {
        _snack(s.loginPasswordRequiresEmailOrMfgCnpj);
        return;
      }
    }
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
    });
    if (!(_formLogin.currentState?.validate() ?? false)) return;
    setState(() => _loadingLogin = true);
    try {
      await appAuth.login(id, pass);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorLogin = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorLogin = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loadingLogin = false);
    }
  }

  void _openRegisterCard() {
    setState(() {
      _phase = _AuthPhase.register;
      _registerChoosingRole = true;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
      if (_loginPersona == _LoginPersona.manufacturer) {
        _registerAccountType = 'manufacturer_admin';
      } else {
        if (_registerAccountType == 'manufacturer_admin') {
          _registerAccountType = 'trainee';
        }
      }
    });
  }

  void _pickRegisterRole(String role) {
    setState(() {
      _registerChoosingRole = false;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
      if (role == 'manufacturer_admin') {
        _registerAccountType = 'manufacturer_admin';
      } else {
        _registerAccountType = role;
      }
    });
  }

  void _backToEntry() {
    setState(() {
      _phase = _AuthPhase.entry;
      _registerChoosingRole = true;
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
    setState(() => _loadingRegister = true);
    try {
      if (_registerAccountType == 'trainee') {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'trainee',
          establishSession: false,
        );
      } else if (_registerAccountType == 'instructor') {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'instructor',
          establishSession: false,
        );
      } else {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'manufacturer_admin',
          manufacturerName:
              _mfgNameRegister.text.trim().isEmpty ? null : _mfgNameRegister.text.trim(),
          manufacturerCnpj: _mfgCnpjRegister.text.trim().isEmpty ? null : _mfgCnpjRegister.text.trim(),
          establishSession: false,
        );
      }
      if (!mounted) return;
      final s = AppLocalizations.of(context);
      final email = _emailRegister.text.trim();
      setState(() {
        _phase = _AuthPhase.entry;
        _errorRegister = null;
        _errorRegisterManufacturer = null;
        _emailLogin.text = email;
        _passwordLogin.clear();
        _passwordRegister.clear();
      });
      _snack(s.registerSuccessNowSignIn);
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = localizedApiMessage(AppLocalizations.of(context), e);
      if (_registerAccountType == 'manufacturer_admin') {
        setState(() => _errorRegisterManufacturer = msg);
      } else {
        setState(() => _errorRegister = msg);
      }
    } catch (_) {
      if (!mounted) return;
      if (_registerAccountType == 'manufacturer_admin') {
        setState(() => _errorRegisterManufacturer = AppLocalizations.of(context).errApiConnection);
      } else {
        setState(() => _errorRegister = AppLocalizations.of(context).errApiConnection);
      }
    } finally {
      if (mounted) setState(() => _loadingRegister = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildLoginTopBar(AppLocalizations s) {
    return Material(
      color: ClinicalPrecisionColors.surfaceContainerLowest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.shield_outlined, size: 22, color: ClinicalPrecisionColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s.loginBrandTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.6,
                      color: ClinicalPrecisionColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (_phase == _AuthPhase.entry) ...[
                    TextButton(
                      onPressed: () => _snack(s.loginFooterSoon),
                      child: Text(s.loginNavQuestions, style: const TextStyle(color: ClinicalPrecisionColors.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      onPressed: _openRegisterCard,
                      style: FilledButton.styleFrom(
                        backgroundColor: ClinicalPrecisionColors.secondary,
                        foregroundColor: ClinicalPrecisionColors.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.button)),
                      ),
                      child: Text(s.loginNavStartNow),
                    ),
                  ] else
                    TextButton(
                      onPressed: _backToEntry,
                      child: Text(s.loginNavHaveAccount, style: const TextStyle(color: ClinicalPrecisionColors.secondary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFooter(AppLocalizations s) {
    void stub(String _) => _snack(s.loginFooterSoon);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: ClinicalPrecisionColors.surface,
        border: Border(top: BorderSide(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.35))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(s.loginFooterSupportPrefix, style: const TextStyle(fontSize: 13, color: ClinicalPrecisionColors.onSurfaceVariant)),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: ClinicalPrecisionColors.secondary,
                    ),
                    onPressed: () => _snack(s.loginFooterSoon),
                    child: Text(s.loginFooterSupportLink, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(onPressed: () => stub('terms'), child: Text(s.loginFooterTerms)),
                  TextButton(onPressed: () => stub('privacy'), child: Text(s.loginFooterPrivacy)),
                  TextButton(onPressed: () => stub('cookies'), child: Text(s.loginFooterCookies)),
                  TextButton(onPressed: () => stub('help'), child: Text(s.loginFooterHelp)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ClinicalPrecisionColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${AppVersion.current} · ${s.loginFooterSystemsOk}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ClinicalPrecisionColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context);

    return AppShell(
      key: const ValueKey('login-universal'),
      title: s.loginShellTitle,
      showAppBar: false,
      showVersionBadge: false,
      child: ColoredBox(
        color: ClinicalPrecisionColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_phase == _AuthPhase.register) _buildLoginTopBar(s),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: _phase == _AuthPhase.entry
                    ? _buildSplitLoginLayout(context, tt, s, key: const ValueKey('login-entry'))
                    : _buildRegisterCard(context, tt, s, key: const ValueKey('card-register')),
              ),
            ),
            _buildLoginFooter(s),
          ],
        ),
      ),
    );
  }

  static const _loginSplitBreakpoint = 600.0;
  static const _loginHeroDeep = Color(0xFF0E1524);
  static const _loginHeroMid = ClinicalPrecisionColors.primaryContainer;
  static const _loginMutedOnNavy = ClinicalPrecisionColors.onPrimaryContainer;

  String _loginIdentityPreviewLabel(AppLocalizations s) {
    return switch (_previewType) {
      LoginIdentityType.patientCpf => s.loginIdentityPatient,
      LoginIdentityType.institutionCnpj => s.loginIdentityInstitution,
      LoginIdentityType.doctorCrm => s.loginIdentityDoctor,
      LoginIdentityType.systemAccount => s.loginIdentitySystem,
      LoginIdentityType.email => s.loginIdentityEmail,
      LoginIdentityType.unknown => s.loginIdentityUnknown,
    };
  }

  String _loginIdentifierFieldLabel(AppLocalizations s) {
    return _loginPersona == _LoginPersona.user
        ? s.loginIdentifierLabelUser
        : s.loginIdentifierLabelManufacturer;
  }

  Widget _loginShieldMark({required double size}) {
    final accent = ClinicalPrecisionColors.secondary;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size * 0.92,
              height: size * 0.92,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
            Icon(Icons.shield_outlined, size: size * 0.44, color: Colors.white),
            Positioned(
              right: size * 0.02,
              bottom: size * 0.02,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: const BoxDecoration(
                  color: ClinicalPrecisionColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.add, size: size * 0.16, color: ClinicalPrecisionColors.secondaryFixedDim),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginBrandingBlock(AppLocalizations s, TextTheme tt, {required bool compact}) {
    final iconBox = compact ? 72.0 : 96.0;
    final titleStyle = (compact ? tt.headlineSmall : tt.headlineMedium)?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.12,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 320 : 380),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _loginShieldMark(size: iconBox),
          SizedBox(height: compact ? 18 : 28),
          Text(s.loginBrandTitle, textAlign: TextAlign.center, style: titleStyle),
          SizedBox(height: compact ? 12 : 16),
          Text(
            s.loginBrandHeroTagline,
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(
              color: _loginMutedOnNavy,
              height: 1.5,
              fontWeight: FontWeight.w500,
              fontSize: compact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Selector compacto (Material 3): ícone + rótulo curto; descrição numa linha por baixo.
  Widget _buildLoginPersonaSelector(BuildContext context, TextTheme tt, AppLocalizations s) {
    final track = ClinicalPrecisionColors.surfaceContainerLow;
    final selectedFill = ClinicalPrecisionColors.surfaceContainerLowest;
    final outline = ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.65);
    final segStyle = SegmentedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      side: BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: track,
      foregroundColor: ClinicalPrecisionColors.onSurfaceVariant,
      selectedForegroundColor: ClinicalPrecisionColors.secondary,
      selectedBackgroundColor: selectedFill,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.loginPersonaPickerLabel,
          style: tt.labelMedium?.copyWith(
            color: ClinicalPrecisionColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          container: true,
          label: s.loginPersonaPickerLabel,
          child: SegmentedButton<_LoginPersona>(
            showSelectedIcon: false,
            style: segStyle,
            segments: [
              ButtonSegment<_LoginPersona>(
                value: _LoginPersona.user,
                label: Text(s.loginPersonaUserTitle),
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                tooltip: s.loginPersonaUserSubtitle,
              ),
              ButtonSegment<_LoginPersona>(
                value: _LoginPersona.manufacturer,
                label: Text(s.loginPersonaManufacturerTitle),
                icon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                tooltip: s.loginPersonaManufacturerSubtitle,
              ),
            ],
            selected: {_loginPersona},
            onSelectionChanged: (Set<_LoginPersona> next) {
              if (next.isEmpty) return;
              setState(() => _loginPersona = next.first);
            },
            multiSelectionEnabled: false,
            emptySelectionAllowed: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFormBody(BuildContext context, TextTheme tt, AppLocalizations s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.loginWelcomeBackTitle,
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: ClinicalPrecisionColors.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          s.loginWelcomeBackSubtitle,
          style: tt.bodyMedium?.copyWith(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 16),
        _buildLoginPersonaSelector(context, tt, s),
        if (_loginPersona == _LoginPersona.manufacturer) ...[
          const SizedBox(height: 10),
          Text(
            s.loginPersonaManufacturerPasswordHint,
            style: tt.bodySmall?.copyWith(
              color: ClinicalPrecisionColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Form(
          key: _formLogin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailLogin,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(
                  labelText: _loginIdentifierFieldLabel(s),
                  hintText: s.loginFieldIdentifierHint,
                  helperText: _loginIdentityPreviewLabel(s),
                  helperMaxLines: 2,
                  helperStyle: tt.bodySmall?.copyWith(
                    color: ClinicalPrecisionColors.onSurfaceVariant,
                    height: 1.25,
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 22),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return s.valEmailRequired;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordLogin,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: s.fieldPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? s.loginShowPassword : s.loginHidePassword,
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return s.valPasswordRequired;
                  return null;
                },
              ),
              if (_errorLogin != null) ...[
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorLogin!,
                            style: tt.bodyMedium?.copyWith(
                              color: const Color(0xFF991B1B),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: ClinicalPrecisionColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _snack(s.loginFooterSoon),
                    child: Text(s.loginForgotPassword, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              FilledButton(
                key: const ValueKey('login-submit'),
                onPressed: _loadingLogin ? null : _submitLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: ClinicalPrecisionColors.secondary,
                  foregroundColor: ClinicalPrecisionColors.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loadingLogin
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(s.loginEnterSystem),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.loginOrgHint,
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(
            color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.85),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          runSpacing: 8,
          children: [
            Text(s.loginNewUserLead, style: tt.bodyMedium?.copyWith(color: ClinicalPrecisionColors.onSurfaceVariant)),
            TextButton(
              onPressed: _openRegisterCard,
              style: TextButton.styleFrom(
                foregroundColor: ClinicalPrecisionColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(s.loginNoAccountAction, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Text('·', style: TextStyle(color: ClinicalPrecisionColors.outlineVariant)),
            TextButton(
              onPressed: () => _snack(s.loginFooterSoon),
              style: TextButton.styleFrom(foregroundColor: ClinicalPrecisionColors.onSurfaceVariant),
              child: Text(s.loginNavQuestions, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 16),
          Text(
            s.loginDebugApiLine(AppConfig.apiBaseUrl),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ],
    );
  }

  /// Fundo do painel esquerdo / topo móvel: gradiente + halos suaves (menos «vazio» que navy liso).
  Widget _loginBrandHeroPanel({
    required AppLocalizations s,
    required TextTheme tt,
    required bool compact,
    required bool mobileHeader,
  }) {
    final scroll = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: mobileHeader ? 24 : 36,
          vertical: mobileHeader ? 28 : 40,
        ),
        child: _buildLoginBrandingBlock(s, tt, compact: compact),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _loginHeroDeep,
                  _loginHeroMid,
                  const Color(0xFF1A2638),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -36,
          right: -28,
          child: IgnorePointer(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClinicalPrecisionColors.secondary.withValues(alpha: 0.13),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: compact ? -24 : 48,
          left: -56,
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
        ),
        if (mobileHeader)
          SafeArea(bottom: false, child: scroll)
        else
          SafeArea(child: scroll),
      ],
    );
  }

  Widget _loginFormCard({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ClinicalPrecisionColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.42),
        ),
        boxShadow: ClinicalPrecisionShadows.loginCard,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
        child: child,
      ),
    );
  }

  /// Login em duas colunas: painel de marca (App²cation) + formulário.
  Widget _buildSplitLoginLayout(BuildContext context, TextTheme tt, AppLocalizations s, {Key? key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < _loginSplitBreakpoint;
        if (mobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: _loginBrandHeroPanel(s: s, tt: tt, compact: true, mobileHeader: true),
              ),
              Expanded(
                flex: 5,
                child: ColoredBox(
                  color: ClinicalPrecisionColors.surface,
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: _loginFormCard(child: _buildLoginFormBody(context, tt, s)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _loginBrandHeroPanel(s: s, tt: tt, compact: false, mobileHeader: false),
            ),
            Expanded(
              child: ColoredBox(
                color: ClinicalPrecisionColors.surface,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _loginFormCard(child: _buildLoginFormBody(context, tt, s)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegisterCard(BuildContext context, TextTheme tt, AppLocalizations s, {Key? key}) {
    return Align(
      key: key,
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: ClinicalPrecisionColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: ClinicalPrecisionShadows.ambientCard,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('register-back'),
                    onPressed: () {
                      if (_registerChoosingRole) {
                        _backToEntry();
                      } else {
                        setState(() => _registerChoosingRole = true);
                      }
                    },
                    style: IconButton.styleFrom(foregroundColor: ClinicalPrecisionColors.onSurfaceVariant),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: s.actionBack,
                  ),
                  Expanded(
                    child: Text(
                      s.actionCreateAccount,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ClinicalPrecisionColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              if (_registerChoosingRole) ...[
                const SizedBox(height: 4),
                Text(
                  s.registerPickLead,
                  style: tt.bodyMedium?.copyWith(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 20),
                _RegisterRolePill(
                  title: s.registerPillTraineeTitle,
                  subtitle: s.registerPillTraineeSub,
                  icon: Icons.school_outlined,
                  onTap: () => _pickRegisterRole('trainee'),
                ),
                const SizedBox(height: 10),
                _RegisterRolePill(
                  title: s.registerPillInstructorTitle,
                  subtitle: s.registerPillInstructorSub,
                  icon: Icons.verified_user_outlined,
                  onTap: () => _pickRegisterRole('instructor'),
                ),
                const SizedBox(height: 10),
                _RegisterRolePill(
                  title: s.registerPillManufacturerTitle,
                  subtitle: s.registerPillManufacturerSub,
                  icon: Icons.precision_manufacturing_outlined,
                  onTap: () => _pickRegisterRole('manufacturer_admin'),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _backToEntry,
                    style: TextButton.styleFrom(foregroundColor: ClinicalPrecisionColors.secondary),
                    child: Text(s.registerBackToLogin, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  s.registerFormLead,
                  style: tt.bodySmall?.copyWith(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formRegister,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameRegister,
                        decoration: InputDecoration(labelText: s.fieldFullName, isDense: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return s.valNameRequired;
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailRegister,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: s.fieldEmail, isDense: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return s.valEmailRequired;
                          if (!v.contains('@')) return s.valEmailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordRegister,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: s.fieldPasswordRegister,
                          isDense: true,
                        ),
                        validator: (v) {
                          if (v == null || v.length < 8) return s.valPasswordMin8;
                          return null;
                        },
                      ),
                      if (_registerAccountType == 'manufacturer_admin') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _mfgNameRegister,
                          decoration: InputDecoration(
                            labelText: s.fieldCompanyName,
                            helperText: s.registerMfgCompanyOptionalDomain,
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _mfgCnpjRegister,
                          decoration: InputDecoration(
                            labelText: s.mfgCnpjOptionalLabel,
                            isDense: true,
                          ),
                        ),
                      ],
                      if (_errorRegister != null) ...[
                        const SizedBox(height: 12),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C), size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorRegister!,
                                    style: tt.bodyMedium?.copyWith(
                                      color: const Color(0xFF991B1B),
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_errorRegisterManufacturer != null) ...[
                        const SizedBox(height: 12),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C), size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorRegisterManufacturer!,
                                    style: tt.bodyMedium?.copyWith(
                                      color: const Color(0xFF991B1B),
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadingRegister ? null : _submitRegister,
                        style: FilledButton.styleFrom(
                          backgroundColor: ClinicalPrecisionColors.secondary,
                          foregroundColor: ClinicalPrecisionColors.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loadingRegister
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(s.actionCompleteRegistration),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterRolePill extends StatelessWidget {
  const _RegisterRolePill({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: ClinicalPrecisionColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.65)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 26, color: ClinicalPrecisionColors.secondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ClinicalPrecisionColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: ClinicalPrecisionColors.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: ClinicalPrecisionColors.onSurfaceVariant.withValues(alpha: 0.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

