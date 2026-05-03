import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/api_exception_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/google_sign_in_localizations.dart';
import 'services/google_sign_in_errors.dart';
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
import 'widgets/official_google_login_slot.dart';
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
/// Fluxograma: `docs/product/fluxo_app2cation.mermaid`. IDs de telas: `lib/product/screen_catalog_map.dart`.
class RoleHome extends StatelessWidget {
  const RoleHome({super.key});

  @override
  Widget build(BuildContext context) {
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

/// Fluxo de cadastro/login: pessoa física (CPF) vs empresa (CNPJ / fabricante).
enum _AuthDocumentTrack { cpf, cnpj }

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
  _AuthDocumentTrack _authTrack = _AuthDocumentTrack.cpf;
  /// `trainee` | `instructor` (CPF) ou `manufacturer_admin` (CNPJ).
  String _registerAccountType = 'trainee';

  bool _loadingLogin = false;
  bool _loadingRegister = false;
  bool _loadingGoogle = false;
  String? _errorLogin;
  String? _errorRegister;
  String? _errorRegisterManufacturer;

  @override
  void dispose() {
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
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
    });
    if (!(_formLogin.currentState?.validate() ?? false)) return;
    setState(() => _loadingLogin = true);
    try {
      await appAuth.login(_emailLogin.text, _passwordLogin.text);
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
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
  }

  void _setAuthTrack(_AuthDocumentTrack track) {
    setState(() {
      _authTrack = track;
      if (track == _AuthDocumentTrack.cnpj) {
        _registerAccountType = 'manufacturer_admin';
      } else {
        if (_registerAccountType == 'manufacturer_admin') {
          _registerAccountType = 'trainee';
        }
      }
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
    setState(() => _loadingRegister = true);
    try {
      if (_registerAccountType == 'trainee') {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'trainee',
        );
      } else if (_registerAccountType == 'instructor') {
        await appAuth.register(
          name: _nameRegister.text,
          email: _emailRegister.text,
          password: _passwordRegister.text,
          role: 'instructor',
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
        );
      }
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

  Future<void> _submitGoogle() async {
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
    final s = AppLocalizations.of(context);
    if (AppConfig.googleWebClientId.trim().isEmpty) {
      _snack(s.errGoogleClientId);
      return;
    }
    setState(() => _loadingGoogle = true);
    try {
      await appAuth.loginWithGoogle(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorLogin = localizedApiMessage(AppLocalizations.of(context), e));
    } on GoogleSignInFailure catch (e) {
      if (!mounted) return;
      _snack(localizedGoogleSignInFailure(AppLocalizations.of(context), e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorLogin = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  /// Web: token vindo do botão GIS oficial (sem `authenticate`).
  Future<void> _onWebGoogleIdToken(String idToken) async {
    if (!mounted) return;
    final s = AppLocalizations.of(context);
    setState(() {
      _errorLogin = null;
      _errorRegister = null;
      _errorRegisterManufacturer = null;
    });
    if (AppConfig.googleWebClientId.trim().isEmpty) {
      _snack(s.errGoogleClientId);
      return;
    }
    setState(() => _loadingGoogle = true);
    try {
      await appAuth.loginWithGoogleIdToken(idToken);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorLogin = localizedApiMessage(AppLocalizations.of(context), e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorLogin = AppLocalizations.of(context).errApiConnection);
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static const _loginLogoUrl =
      'https://lh3.googleusercontent.com/aida/ADBb0uiBfLRiTNXO08j1P2IZWvshAg7Z9Cov-vEofM75n72DNP2GySWtw6G4jCFgDxrk5P41_SrvHlHfRfnovqLb-MHUJek6pEbWNdhDTeFq1SRfs8CEhqWds7APs33Meva5ib0gL8d5XtzADnwgs_bNsz2_fuLC1XlMqg9jWCaREZBjWGWMDmFajYRN3L4QAeEcmGKaWH1438zk9Q2hfrdT4lEzD7poZuProyJ_AJgjV1loVF22d9PH2WVm';

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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _loginLogoUrl,
                      height: 40,
                      errorBuilder: (_, _, _) => const Icon(Icons.medical_services_rounded, size: 36, color: ClinicalPrecisionColors.secondary),
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
      child: ColoredBox(
        color: ClinicalPrecisionColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLoginTopBar(s),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                        ? _buildEntryCard(context, tt, s, key: const ValueKey('card-entry'))
                        : _buildRegisterCard(context, tt, s, key: const ValueKey('card-register')),
                  ),
                ),
              ),
            ),
            _buildLoginFooter(s),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, TextTheme tt, AppLocalizations s, {Key? key}) {
    final heroTitleStyle = tt.headlineMedium?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.15,
      color: ClinicalPrecisionColors.primaryContainer,
    );
    final heroSubStyle = tt.bodyLarge?.copyWith(
      fontSize: 17,
      height: 1.45,
      color: ClinicalPrecisionColors.onPrimaryContainer,
    );

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(s.loginAccessHeroTitle, textAlign: TextAlign.center, style: heroTitleStyle),
        const SizedBox(height: 10),
        Text(s.loginAccessHeroSubtitle, textAlign: TextAlign.center, style: heroSubStyle),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            TextButton(
              onPressed: _loadingGoogle
                  ? null
                  : () {
                      setState(() {
                        _setAuthTrack(_AuthDocumentTrack.cnpj);
                      });
                    },
              child: Text(s.loginIamManufacturer),
            ),
            Text('·', style: TextStyle(color: Colors.blueGrey.shade400)),
            TextButton(
              onPressed: _loadingGoogle ? null : () => _snack(s.loginInstitutionFootnote),
              child: Text(s.loginIamInstitution),
            ),
            Text('·', style: TextStyle(color: Colors.blueGrey.shade400)),
            TextButton(
              onPressed: _loadingGoogle
                  ? null
                  : () {
                      setState(() {
                        _setAuthTrack(_AuthDocumentTrack.cpf);
                        _registerAccountType = 'instructor';
                      });
                    },
              child: Text(s.loginIamInstructorLink),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: ClinicalPrecisionColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.cardHero),
            border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.35)),
            boxShadow: ClinicalPrecisionShadows.loginCard,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            SegmentedButton<_AuthDocumentTrack>(
              segments: [
                ButtonSegment<_AuthDocumentTrack>(
                  value: _AuthDocumentTrack.cpf,
                  label: Text(s.authTrackCpfLabel),
                  icon: const Icon(Icons.person_outline, size: 18),
                ),
                ButtonSegment<_AuthDocumentTrack>(
                  value: _AuthDocumentTrack.cnpj,
                  label: Text(s.authTrackCnpjLabel),
                  icon: const Icon(Icons.business_outlined, size: 18),
                ),
              ],
              selected: {_authTrack},
              onSelectionChanged: (Set<_AuthDocumentTrack> next) {
                if (next.isEmpty) return;
                _setAuthTrack(next.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              s.authTrackSegmentSubtitle,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
            ),
            const SizedBox(height: 16),
            Text(
              s.loginGoogleTriageHint,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.4),
            ),
            const SizedBox(height: 14),
            OfficialGoogleLoginSlot(
              loading: _loadingGoogle,
              onWebGoogleToken: _onWebGoogleIdToken,
              fallback: _primaryButton(
                context,
                label: _loadingGoogle ? s.googleConnecting : s.googleContinue,
                icon: Icons.login_rounded,
                onPressed: _loadingGoogle ? null : _submitGoogle,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: Divider(height: 1, color: Color(0xFFDCE0E5))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(s.loginOrEmail, style: tt.labelMedium?.copyWith(color: const Color(0xFF76777D))),
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
                    decoration: InputDecoration(
                      labelText: s.fieldEmail,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return s.valEmailRequired;
                      if (!v.contains('@')) return s.valEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordLogin,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: s.fieldPassword,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return s.valPasswordRequired;
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
                        : Text(s.actionSignIn),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.loginOrgHint,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: const Color(0xFF8E9099), height: 1.35),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _openRegisterCard,
              icon: const Icon(Icons.person_add_outlined, size: 20),
              label: Text(s.actionCreateAccount),
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
                s.loginDebugApiLine(AppConfig.apiBaseUrl),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(BuildContext context, TextTheme tt, AppLocalizations s, {Key? key}) {
    final heroTitleStyle = tt.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: ClinicalPrecisionColors.primaryContainer,
    );
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(s.actionCreateAccount, textAlign: TextAlign.center, style: heroTitleStyle),
        const SizedBox(height: 8),
        Text(
          s.registerSubtitle,
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: ClinicalPrecisionColors.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 560),
          decoration: BoxDecoration(
            color: ClinicalPrecisionColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(ClinicalPrecisionRadii.cardHero),
            border: Border.all(color: ClinicalPrecisionColors.outlineVariant.withValues(alpha: 0.35)),
            boxShadow: ClinicalPrecisionShadows.loginCard,
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
                  tooltip: s.actionBack,
                ),
                Expanded(
                  child: Text(
                    s.actionCreateAccount,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: ClinicalPrecisionColors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<_AuthDocumentTrack>(
              segments: [
                ButtonSegment<_AuthDocumentTrack>(
                  value: _AuthDocumentTrack.cpf,
                  label: Text(s.authTrackCpfLabel),
                  icon: const Icon(Icons.person_outline, size: 18),
                ),
                ButtonSegment<_AuthDocumentTrack>(
                  value: _AuthDocumentTrack.cnpj,
                  label: Text(s.authTrackCnpjLabel),
                  icon: const Icon(Icons.business_outlined, size: 18),
                ),
              ],
              selected: {_authTrack},
              onSelectionChanged: (Set<_AuthDocumentTrack> next) {
                if (next.isEmpty) return;
                _setAuthTrack(next.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              s.authTrackSegmentSubtitle,
              style: tt.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
            ),
            const SizedBox(height: 16),
            if (_authTrack == _AuthDocumentTrack.cpf) ...[
              Text(
                s.registerAccountTypeTitleCpf,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _AccountTypeMiniCard(
                      label: s.googleRoleTrainee,
                      icon: Icons.school_outlined,
                      selected: _registerAccountType == 'trainee',
                      onTap: () => setState(() => _registerAccountType = 'trainee'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AccountTypeMiniCard(
                      label: s.googleRoleInstructor,
                      icon: Icons.verified_user_outlined,
                      selected: _registerAccountType == 'instructor',
                      onTap: () => setState(() => _registerAccountType = 'instructor'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Color(0xFF00677D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.registerManagerInviteHint,
                      style: tt.bodySmall?.copyWith(color: const Color(0xFF5C5E66), height: 1.35),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                s.registerAccountTypeTitleCnpj,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                s.mfgCompanyLabel,
                style: tt.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
              ),
            ],
            const SizedBox(height: 20),
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
                        : Text(s.actionCompleteRegistration),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ],
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

