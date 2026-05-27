import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        builder: (_) => EditProfileScreen(initialUser: user),
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
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
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
                    _ProfileHero(
                      user: user,
                      onEditProfile: () => _openEditProfile(user),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(title: 'Account', subtitle: user.email),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.lock_reset_rounded),
                            title: const Text('Change password'),
                            subtitle: const Text(
                              'Use current password or email OTP',
                            ),
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
  const EditProfileScreen({required this.initialUser, super.key});

  final AppUser initialUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _photoUrlController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.name);
    _aboutController = TextEditingController(text: widget.initialUser.about);
    _photoUrlController = TextEditingController(
      text: widget.initialUser.profilePhotoUrl,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _photoUrlController.dispose();
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
        about: _aboutController.text.trim(),
        profilePhotoUrl: _photoUrlController.text.trim(),
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

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 78,
      maxWidth: 900,
    );
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';
    setState(() {
      _photoUrlController.text = 'data:$mimeType;base64,${base64Encode(bytes)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileFormScaffold(
      title: 'Edit profile',
      subtitle: 'Update the profile details shown across your account.',
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
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aboutController,
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'About',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: _validateAbout,
            ),
            const SizedBox(height: 16),
            _PhotoPickerSection(
              image: _imageProviderForValue(_photoUrlController.text),
              onGalleryPressed: () => _pickPhoto(ImageSource.gallery),
              onCameraPressed: () => _pickPhoto(ImageSource.camera),
              onRemovePressed: () {
                setState(() {
                  _photoUrlController.clear();
                });
              },
            ),
            TextFormField(
              controller: _photoUrlController,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 0, height: 0),
              validator: _validateOptionalImageValue,
            ),
            const SizedBox(height: 4),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Use image link instead'),
              children: [
                TextFormField(
                  controller: _photoUrlController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    helperText: 'Optional http or https image link',
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Clear image',
                      onPressed: () {
                        setState(() {
                          _photoUrlController.clear();
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  validator: _validateOptionalImageValue,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

class _PhotoPickerSection extends StatelessWidget {
  const _PhotoPickerSection({
    required this.image,
    required this.onGalleryPressed,
    required this.onCameraPressed,
    required this.onRemovePressed,
  });

  final ImageProvider? image;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF020617).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                backgroundImage: image,
                child: image == null
                    ? const Icon(Icons.person_rounded, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile photo',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text('Choose from gallery or take a new photo.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onGalleryPressed,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
              OutlinedButton.icon(
                onPressed: onCameraPressed,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
              TextButton.icon(
                onPressed: onRemovePressed,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF020617).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Forgot current password?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reset with an OTP sent to your email.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.password_rounded),
                    label: const Text('Reset with OTP'),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.onEditProfile});

  final AppUser user;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileImage = _profileImageFor(user);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF0F172A), Color(0xFF2A0F1D)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
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
                backgroundColor: colorScheme.primary.withValues(alpha: 0.22),
                backgroundImage: profileImage,
                child: profileImage == null
                    ? Text(
                        _initialsForName(user.name),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
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
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit profile'),
            ),
          ),
        ],
      ),
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
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF94A3B8),
            height: 1.45,
          ),
        ),
      ],
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
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
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
                    color: const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF94A3B8),
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

ImageProvider? _profileImageFor(AppUser user) {
  return _imageProviderForValue(user.profilePhotoUrl);
}

ImageProvider? _imageProviderForValue(String value) {
  final imageValue = value.trim();
  if (imageValue.startsWith('data:image/')) {
    final commaIndex = imageValue.indexOf(',');
    if (commaIndex == -1) {
      return null;
    }
    try {
      return MemoryImage(base64Decode(imageValue.substring(commaIndex + 1)));
    } catch (_) {
      return null;
    }
  }

  final uri = Uri.tryParse(imageValue);
  if (imageValue.isEmpty ||
      uri == null ||
      !uri.isAbsolute ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return null;
  }
  return NetworkImage(imageValue);
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

String? _validateAbout(String? value) {
  if ((value ?? '').length > 500) {
    return 'About must be 500 characters or fewer';
  }
  return null;
}

String? _validateOptionalImageValue(String? value) {
  final imageValue = value?.trim() ?? '';
  if (imageValue.isEmpty) {
    return null;
  }

  if (imageValue.startsWith('data:image/')) {
    return imageValue.contains(',') ? null : 'Choose a valid image file';
  }

  final uri = Uri.tryParse(imageValue);
  if (uri == null || !uri.isAbsolute) {
    return 'Enter a valid image URL';
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'Use an http or https image URL';
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
