import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shatbha/core/core.dart';
import '../cubit/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/home');
        if (state is AuthGuest) context.go('/login');
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const BrandLockup(
                size: BrandSize.large,
                slogan: 'المساعد لأنظمة المحاسبة وإدارة الأعمال',
              ),
              const SizedBox(height: 16),
              Text(
                'VERSION 1.0',
                style: GoogleFonts.cinzel(
                  color: c.brass,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'admin@shatbha.test');
  final _password = TextEditingController(text: 'password');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) context.go('/home');
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              children: [
                const BrandLockup(size: BrandSize.medium),
                const SizedBox(height: 36),
                const FieldLabel('اسم المستخدم'),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: c.stone, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: c.ivory,
                    prefixIcon: Icon(Icons.person_outline, color: c.stone),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.brass, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const FieldLabel('كلمة المرور'),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: c.brass),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: c.ivoryMuted,
                      ),
                    ),
                  ),
                ),
                if (state is AuthGuest && state.message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    state.message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.terracotta, height: 1.4),
                  ),
                ],
                const SizedBox(height: 28),
                AtelierButton(
                  label: state is AuthLoading ? 'جاري الدخول…' : 'دخول',
                  kind: AtelierButtonKind.terracotta,
                  onPressed: state is AuthLoading
                      ? null
                      : () => context.read<AuthBloc>().add(
                            AuthLoginRequested(_email.text.trim(), _password.text),
                          ),
                ),
                const SizedBox(height: 20),
                Text(
                  'نسخة تجريبية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.brass,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'admin@shatbha.test  ·  clerk@shatbha.test\n'
                  'contractor@market.test  ·  supplier@market.test\n'
                  'password',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
