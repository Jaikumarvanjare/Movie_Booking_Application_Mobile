import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/data/auth_session.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/session_controller.dart';
import '../../payments/presentation/payment_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void>? _profileFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _profileFuture = _loadProfile();
  }

  Future<void> _loadProfile() {
    return context.read<SessionController>().refreshProfile();
  }

  Future<void> _retryLoadProfile() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  Future<void> _openEditProfile(AppUser user) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => EditProfileScreen(initialName: user.name),
      ),
    );

    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openChangePassword() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const ChangePasswordScreen()),
    );

    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPaymentHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PaymentHistoryScreen()),
    );
  }

  Future<void> _openInfoScreen({
    required String title,
    required String content,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileInfoScreen(title: title, content: content),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'You will need to sign in again to continue booking tickets.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    try {
      await context.read<SessionController>().signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(context, error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = context.watch<SessionController>();
    final user = sessionController.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B8), Color(0xFFFFF4E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<void>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && user == null) {
                return _ProfileMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load your profile',
                  message: _messageForError(context, snapshot.error),
                  actionLabel: 'Retry',
                  onPressed: _retryLoadProfile,
                );
              }

              if (user == null) {
                return _ProfileMessageState(
                  icon: Icons.person_off_rounded,
                  title: 'Profile is unavailable',
                  message: 'Sign in again to load your account details.',
                  actionLabel: 'Retry',
                  onPressed: _retryLoadProfile,
                );
              }

              return RefreshIndicator(
                onRefresh: _retryLoadProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  children: [
                    _ProfileHero(user: user),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: 'Account',
                      subtitle: 'Manage your details and sign-in preferences.',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_outlined),
                            title: const Text('Edit profile'),
                            subtitle: const Text('Update your display name'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _openEditProfile(user),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.lock_reset_rounded),
                            title: const Text('Change password'),
                            subtitle: const Text('Update your login password'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: _openChangePassword,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.payments_outlined),
                            title: const Text('Payment history'),
                            subtitle: const Text('View checkout transactions'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: _openPaymentHistory,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: 'Settings',
                      subtitle: 'Helpful info and policies for CineBook.',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          _ProfileMenuTile(
                            icon: Icons.movie_filter_outlined,
                            title: 'About CineBook',
                            subtitle: 'Learn what the mobile app is built for',
                            onTap: () => _openInfoScreen(
                              title: 'About CineBook',
                              content:
                                  'CineBook helps customers discover movies, choose theatres and shows, pick seats, and complete ticket payments from mobile.',
                            ),
                          ),
                          const Divider(height: 1),
                          _ProfileMenuTile(
                            icon: Icons.support_agent_rounded,
                            title: 'Help & support',
                            subtitle: 'Troubleshooting and assistance guidance',
                            onTap: () => _openInfoScreen(
                              title: 'Help & support',
                              content:
                                  'If something goes wrong while booking, start by retrying the request and checking your internet connection. For payment issues, keep your booking and payment IDs handy. For account issues, use the forgot-password flow from the login screen.',
                            ),
                          ),
                          const Divider(height: 1),
                          _ProfileMenuTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy policy',
                            subtitle: 'How account and booking data is handled',
                            onTap: () => _openInfoScreen(
                              title: 'Privacy policy',
                              content:
                                  'CineBook stores the account information required to sign you in and personalize your bookings. Payment secrets stay on the backend, and the mobile app keeps only the user data needed for the signed-in experience.',
                            ),
                          ),
                          const Divider(height: 1),
                          _ProfileMenuTile(
                            icon: Icons.description_outlined,
                            title: 'Terms & conditions',
                            subtitle: 'Basic usage and booking expectations',
                            onTap: () => _openInfoScreen(
                              title: 'Terms & conditions',
                              content:
                                  'Bookings depend on seat availability, theatre schedules, and successful payment verification. Account credentials should be kept secure, and misuse of the application may lead to restricted access.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Log out',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text('Sign out of this device'),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onTap: _logout,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.initialName, super.key});

  final String initialName;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<SessionController>().updateProfile(
        name: _nameController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop('Profile updated successfully');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(context, error))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileFormScaffold(
      title: 'Edit profile',
      subtitle: 'Update the name shown across your signed-in experience.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('editProfileNameField'),
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: _validateProfileName,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: Text(_isSaving ? 'Saving...' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final message = await context.read<SessionController>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(context, error))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileFormScaffold(
      title: 'Change password',
      subtitle: 'Use your current password before setting a new one.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('changeCurrentPasswordField'),
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Current password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscureCurrentPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: _validateRequiredPassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('changeNewPasswordField'),
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscureNewPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: _validateNewPassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('changeConfirmPasswordField'),
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  tooltip: _obscureConfirmPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                final passwordValidation = _validateNewPassword(value);
                if (passwordValidation != null) {
                  return passwordValidation;
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: Text(
                _isSaving ? 'Updating password...' : 'Update password',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B8), Color(0xFFFFF4E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5C4630),
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final memberSince = user.createdAt == null
        ? null
        : DateFormat.yMMMd().format(user.createdAt!);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  _initialsForName(user.name),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ProfileBadge(label: _roleLabel(user.role)),
              _ProfileBadge(label: _labelize(user.status)),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white.withValues(alpha: 0.92),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _ProfileDetailRow(label: 'Name', value: user.name),
                  const Divider(height: 20),
                  _ProfileDetailRow(label: 'Email', value: user.email),
                  const Divider(height: 20),
                  _ProfileDetailRow(
                    label: 'Role',
                    value: _roleLabel(user.role),
                  ),
                  const Divider(height: 20),
                  _ProfileDetailRow(
                    label: 'Status',
                    value: _labelize(user.status),
                  ),
                  if (memberSince != null) ...[
                    const Divider(height: 20),
                    _ProfileDetailRow(
                      label: 'Member since',
                      value: memberSince,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2A2118),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _ProfileFormScaffold extends StatelessWidget {
  const _ProfileFormScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B8), Color(0xFFFFF4E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5C4630),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
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

class _ProfileMessageState extends StatelessWidget {
  const _ProfileMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => onPressed(),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) {
    return 'CB';
  }

  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _roleLabel(AppUserRole role) {
  switch (role) {
    case AppUserRole.customer:
      return 'Customer';
    case AppUserRole.client:
      return 'Client';
    case AppUserRole.admin:
      return 'Admin';
  }
}

String _labelize(String value) {
  return value
      .trim()
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) {
        final lowercase = part.toLowerCase();
        return '${lowercase[0].toUpperCase()}${lowercase.substring(1)}';
      })
      .join(' ');
}

String _messageForError(BuildContext context, Object? error) {
  final controller = context.read<SessionController>();
  return controller.lastErrorMessage ??
      error?.toString() ??
      'Something went wrong.';
}

String? _validateProfileName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Enter your full name';
  }
  if (name.length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

String? _validateRequiredPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter your current password';
  }
  return null;
}

String? _validateNewPassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
