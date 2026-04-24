import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_home.dart';
import '../../auth/presentation/session_controller.dart';
import '../../auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SessionController? _sessionController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<SessionController>();
    if (_sessionController == controller) {
      return;
    }
    _sessionController?.removeListener(_handleSessionChanged);
    _sessionController = controller;
    _sessionController?.addListener(_handleSessionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSessionChanged();
    });
  }

  @override
  void dispose() {
    _sessionController?.removeListener(_handleSessionChanged);
    super.dispose();
  }

  void _handleSessionChanged() {
    final controller = _sessionController;
    if (!mounted || controller == null) {
      return;
    }

    if (controller.status == SessionStatus.authenticated &&
        controller.user != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => buildHomeForUser(controller.user!),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sessionController = context.watch<SessionController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              const Color(0xFFFFF4E6),
              const Color(0xFFFFE0B8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'CineBook Mobile',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Book the next show without the desktop detour.',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: const Color(0xFF2A2118),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to browse the live catalogue, choose theatres and shows, and continue into booking and payment.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: const Color(0xFF5C4630),
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _StepTile(
                          title: 'Auth foundation',
                          subtitle: 'Secure login, signup, reset password',
                        ),
                        SizedBox(height: 14),
                        _StepTile(
                          title: 'Browse movies',
                          subtitle: 'Movie list, details, theatres, and shows',
                        ),
                        SizedBox(height: 14),
                        _StepTile(
                          title: 'Book tickets',
                          subtitle: 'Seats, booking summary, and payments',
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (sessionController.status == SessionStatus.checking)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        sessionController.status == SessionStatus.checking
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                    child: const Text('Continue to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.play_arrow_rounded, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
