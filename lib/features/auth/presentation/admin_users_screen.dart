import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../data/auth_session.dart';
import 'login_screen.dart';
import 'session_controller.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _userIdController = TextEditingController();
  Future<List<AppUser>>? _usersFuture;
  AppUserRole _selectedRole = AppUserRole.customer;
  String _selectedStatus = 'APPROVED';
  bool _isSaving = false;
  bool _hasSearched = false;
  AppUser? _selectedUser;
  AppUser? _updatedUser;

  @override
  void dispose() {
    _searchController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _searchUsers() {
    setState(() {
      _hasSearched = true;
      _usersFuture = context.read<AuthRepository>().fetchUsers(
        search: _searchController.text.trim(),
      );
    });
  }

  void _selectUser(AppUser user) {
    setState(() {
      _selectedUser = user;
      _updatedUser = null;
      _userIdController.text = user.id ?? '';
      _selectedRole = user.role;
      _selectedStatus = user.status.toUpperCase();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _updatedUser = null;
    });

    try {
      final updatedUser = await context.read<AuthRepository>().updateUser(
        _userIdController.text.trim(),
        role: _selectedRole,
        status: _selectedStatus,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _updatedUser = updatedUser;
        _selectedUser = updatedUser;
        if (updatedUser.id != null) {
          _userIdController.text = updatedUser.id!;
        }
      });
      if (_hasSearched) {
        _searchUsers();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            children: [
              Text(
                'Admin Users',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2A2118),
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search by name, email, or user ID, then choose the right account to update.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5C4630),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _UserSearchCard(
                controller: _searchController,
                hasSearched: _hasSearched,
                usersFuture: _usersFuture,
                selectedUser: _selectedUser,
                onSearch: _searchUsers,
                onSelectUser: _selectUser,
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userIdController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            helperText:
                                'Select from search or paste the backend user id',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: _validateUserId,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<AppUserRole>(
                          key: ValueKey(_selectedRole),
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'User role',
                            prefixIcon: Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppUserRole.customer,
                              child: Text('Customer'),
                            ),
                            DropdownMenuItem(
                              value: AppUserRole.client,
                              child: Text('Client'),
                            ),
                            DropdownMenuItem(
                              value: AppUserRole.admin,
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_selectedStatus),
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'User status',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'APPROVED',
                              child: Text('Approved'),
                            ),
                            DropdownMenuItem(
                              value: 'PENDING',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'REJECTED',
                              child: Text('Rejected'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _submit,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(
                              _isSaving ? 'Updating...' : 'Update user',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_updatedUser != null) ...[
                const SizedBox(height: 18),
                _UpdatedUserCard(user: _updatedUser!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UserSearchCard extends StatelessWidget {
  const _UserSearchCard({
    required this.controller,
    required this.hasSearched,
    required this.usersFuture,
    required this.selectedUser,
    required this.onSearch,
    required this.onSelectUser,
  });

  final TextEditingController controller;
  final bool hasSearched;
  final Future<List<AppUser>>? usersFuture;
  final AppUser? selectedUser;
  final VoidCallback onSearch;
  final ValueChanged<AppUser> onSelectUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find user',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2A2118),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                labelText: 'Name, email, or user ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search users',
                  onPressed: onSearch,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (!hasSearched)
              Text(
                'Search to show matching users here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              FutureBuilder<List<AppUser>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _SearchErrorState(
                      message: snapshot.error.toString(),
                    );
                  }

                  final users = snapshot.data ?? const <AppUser>[];
                  if (users.isEmpty) {
                    return Text(
                      'No users found. You can still paste a user ID below.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${users.length} result${users.length == 1 ? '' : 's'} found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isSelected = selectedUser?.id == user.id;
                            return _UserResultTile(
                              user: user,
                              isSelected: isSelected,
                              onTap: () => onSelectUser(user),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  const _UserResultTile({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final AppUser user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2A2118),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(label: _labelize(user.status)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ID: ${user.id ?? 'Not available'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message});

  final String message;

  bool get _isAuthError {
    final normalized = message.toLowerCase();
    return normalized.contains('token') ||
        normalized.contains('unauthorized') ||
        normalized.contains('sign in');
  }

  Future<void> _signInAgain(BuildContext context) async {
    await context.read<SessionController>().signOut();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isAuthError
              ? 'Your session expired or the token is missing.'
              : message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (_isAuthError) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _signInAgain(context),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign in again'),
            ),
          ),
        ],
      ],
    );
  }
}

class _UpdatedUserCard extends StatelessWidget {
  const _UpdatedUserCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Updated user',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2A2118),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _UserDetailRow(label: 'Name', value: user.name),
            const Divider(height: 20),
            _UserDetailRow(label: 'Email', value: user.email),
            const Divider(height: 20),
            _UserDetailRow(label: 'Role', value: _roleLabel(user.role)),
            const Divider(height: 20),
            _UserDetailRow(label: 'Status', value: _labelize(user.status)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _UserDetailRow extends StatelessWidget {
  const _UserDetailRow({required this.label, required this.value});

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

String? _validateUserId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a user ID';
  }
  if (value.trim().length < 6) {
    return 'Enter a valid user ID';
  }
  return null;
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
