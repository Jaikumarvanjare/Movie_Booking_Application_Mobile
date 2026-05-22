import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../movies/data/movie.dart';
import '../../movies/data/movie_repository.dart';
import '../data/theatre.dart';
import '../data/theatre_repository.dart';

class AdminTheatresScreen extends StatefulWidget {
  const AdminTheatresScreen({super.key});

  @override
  State<AdminTheatresScreen> createState() => _AdminTheatresScreenState();
}

class _AdminTheatresScreenState extends State<AdminTheatresScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  late Future<List<Theatre>> _theatresFuture;
  String? _busyTheatreId;

  @override
  void initState() {
    super.initState();
    _theatresFuture = _loadTheatres();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<List<Theatre>> _loadTheatres() {
    return context.read<TheatreRepository>().fetchTheatres(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      pincode: int.tryParse(_pincodeController.text.trim()),
    );
  }

  Future<void> _refreshTheatres() async {
    final future = _loadTheatres();
    setState(() {
      _theatresFuture = future;
    });
    await future;
  }

  Future<void> _openTheatreForm([Theatre? theatre]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AdminTheatreFormScreen(theatre: theatre),
      ),
    );

    if (changed == true && mounted) {
      await _refreshTheatres();
    }
  }

  Future<void> _confirmDelete(Theatre theatre) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete theatre?'),
          content: Text(
            'Delete ${theatre.name}? Shows linked to this theatre may also be affected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteTheatre(theatre);
    }
  }

  Future<void> _deleteTheatre(Theatre theatre) async {
    setState(() {
      _busyTheatreId = theatre.id;
    });

    try {
      await context.read<TheatreRepository>().deleteTheatre(theatre.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theatre deleted successfully.')),
      );
      await _refreshTheatres();
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
          _busyTheatreId = null;
        });
      }
    }
  }

  void _clearFilters() {
    _nameController.clear();
    _cityController.clear();
    _pincodeController.clear();
    _refreshTheatres();
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
          child: FutureBuilder<List<Theatre>>(
            future: _theatresFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;

              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && !snapshot.hasData) {
                return _AdminTheatreMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load theatres',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: _refreshTheatres,
                );
              }

              final theatres = snapshot.data ?? const <Theatre>[];

              return RefreshIndicator(
                onRefresh: _refreshTheatres,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 96),
                  itemCount: theatres.length + 1,
                  separatorBuilder: (_, index) => index == 0
                      ? const SizedBox(height: 18)
                      : const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Theatres',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFF2A2118),
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create venues, update details, and assign movies.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFF5C4630),
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                tooltip: 'Add theatre',
                                onPressed: () => _openTheatreForm(),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _AdminTheatreFilterCard(
                            nameController: _nameController,
                            cityController: _cityController,
                            pincodeController: _pincodeController,
                            onApply: _refreshTheatres,
                            onClear: _clearFilters,
                          ),
                          if (theatres.isEmpty) ...[
                            const SizedBox(height: 80),
                            const _EmptyAdminTheatresState(),
                          ],
                        ],
                      );
                    }

                    final theatre = theatres[index - 1];
                    return _AdminTheatreCard(
                      theatre: theatre,
                      isBusy: _busyTheatreId == theatre.id,
                      onEdit: () => _openTheatreForm(theatre),
                      onDelete: () => _confirmDelete(theatre),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTheatreForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Theatre'),
      ),
    );
  }
}

class AdminTheatreFormScreen extends StatefulWidget {
  const AdminTheatreFormScreen({this.theatre, super.key});

  final Theatre? theatre;

  @override
  State<AdminTheatreFormScreen> createState() => _AdminTheatreFormScreenState();
}

class _AdminTheatreFormScreenState extends State<AdminTheatreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _addressController;
  late Future<_TheatreMovieAssignmentData> _assignmentFuture;
  Set<String> _assignedMovieIds = const {};
  bool _isSaving = false;
  String? _togglingMovieId;

  bool get _isEditing => widget.theatre != null;

  @override
  void initState() {
    super.initState();
    final theatre = widget.theatre;
    _nameController = TextEditingController(text: theatre?.name ?? '');
    _descriptionController = TextEditingController(
      text: theatre?.description ?? '',
    );
    _cityController = TextEditingController(text: theatre?.city ?? '');
    _pincodeController = TextEditingController(
      text: theatre == null || theatre.pincode == 0 ? '' : '${theatre.pincode}',
    );
    _addressController = TextEditingController(text: theatre?.address ?? '');
    _assignmentFuture = _loadAssignmentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<_TheatreMovieAssignmentData> _loadAssignmentData() async {
    if (!_isEditing) {
      return const _TheatreMovieAssignmentData(
        movies: <Movie>[],
        assignedMovies: <Movie>[],
      );
    }

    final movieRepository = context.read<MovieRepository>();
    final theatreRepository = context.read<TheatreRepository>();
    final results = await Future.wait([
      movieRepository.fetchMovies(),
      theatreRepository.fetchTheatreMovies(widget.theatre!.id),
    ]);
    final movies = results[0];
    final assignedMovies = results[1];
    _assignedMovieIds = assignedMovies.map((movie) => movie.id).toSet();
    return _TheatreMovieAssignmentData(
      movies: movies,
      assignedMovies: assignedMovies,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = context.read<TheatreRepository>();
      final pincode = int.parse(_pincodeController.text.trim());
      if (_isEditing) {
        await repository.updateTheatre(
          widget.theatre!.id,
          name: _nameController.text.trim(),
          description: _optionalText(_descriptionController),
          city: _cityController.text.trim(),
          pincode: pincode,
          address: _optionalText(_addressController),
        );
      } else {
        await repository.createTheatre(
          name: _nameController.text.trim(),
          description: _optionalText(_descriptionController),
          city: _cityController.text.trim(),
          pincode: pincode,
          address: _optionalText(_addressController),
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Theatre updated successfully.'
                : 'Theatre created successfully.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
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

  Future<void> _toggleMovie(Movie movie) async {
    if (!_isEditing) {
      return;
    }

    final assigned = _assignedMovieIds.contains(movie.id);
    setState(() {
      _togglingMovieId = movie.id;
    });

    try {
      await context.read<TheatreRepository>().updateTheatreMovies(
        widget.theatre!.id,
        movieIds: [movie.id],
        insert: !assigned,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        final next = Set<String>.from(_assignedMovieIds);
        if (assigned) {
          next.remove(movie.id);
        } else {
          next.add(movie.id);
        }
        _assignedMovieIds = next;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            assigned
                ? 'Movie removed from theatre.'
                : 'Movie assigned to theatre.',
          ),
        ),
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
          _togglingMovieId = null;
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 120),
              children: [
                IconButton.filledTonal(
                  alignment: Alignment.centerLeft,
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 28),
                Text(
                  _isEditing ? 'Edit Theatre' : 'Add Theatre',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEditing
                      ? 'Update theatre details and assigned movies.'
                      : 'Register a new theatre for show scheduling.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5C4630),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _AdminTheatreTextField(
                          controller: _nameController,
                          label: 'Theatre name',
                          icon: Icons.theaters_outlined,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminTheatreTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _AdminTheatreTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_rounded,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminTheatreTextField(
                          controller: _pincodeController,
                          label: 'Pincode',
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          validator: _validatePincode,
                        ),
                        const SizedBox(height: 14),
                        _AdminTheatreTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.map_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 18),
                  _TheatreMovieAssignmentSection(
                    future: _assignmentFuture,
                    assignedMovieIds: _assignedMovieIds,
                    togglingMovieId: _togglingMovieId,
                    onToggleMovie: _toggleMovie,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: Icon(_isEditing ? Icons.save_outlined : Icons.add_rounded),
          label: Text(
            _isSaving
                ? 'Saving...'
                : _isEditing
                ? 'Save theatre'
                : 'Create theatre',
          ),
        ),
      ),
    );
  }
}

class _TheatreMovieAssignmentData {
  const _TheatreMovieAssignmentData({
    required this.movies,
    required this.assignedMovies,
  });

  final List<Movie> movies;
  final List<Movie> assignedMovies;
}

class _TheatreMovieAssignmentSection extends StatelessWidget {
  const _TheatreMovieAssignmentSection({
    required this.future,
    required this.assignedMovieIds,
    required this.togglingMovieId,
    required this.onToggleMovie,
  });

  final Future<_TheatreMovieAssignmentData> future;
  final Set<String> assignedMovieIds;
  final String? togglingMovieId;
  final ValueChanged<Movie> onToggleMovie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: FutureBuilder<_TheatreMovieAssignmentData>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError && !snapshot.hasData) {
              return Text(
                'Could not load movie assignments. ${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  height: 1.4,
                ),
              );
            }

            final movies = snapshot.data?.movies ?? const <Movie>[];
            if (movies.isEmpty) {
              return Text(
                'No movies are available for assignment yet.',
                style: theme.textTheme.bodyMedium,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theatre Movies',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2A2118),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Toggle movies available for show creation in this theatre.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C4630),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                for (final movie in movies) ...[
                  _MovieAssignmentTile(
                    movie: movie,
                    assigned: assignedMovieIds.contains(movie.id),
                    isBusy: togglingMovieId == movie.id,
                    onTap: () => onToggleMovie(movie),
                  ),
                  if (movie != movies.last) const Divider(height: 1),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MovieAssignmentTile extends StatelessWidget {
  const _MovieAssignmentTile({
    required this.movie,
    required this.assigned,
    required this.isBusy,
    required this.onTap,
  });

  final Movie movie;
  final bool assigned;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: assigned,
      onChanged: isBusy ? null : (_) => onTap(),
      title: Text(movie.name),
      subtitle: Text(movie.language),
      secondary: Icon(
        assigned ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
      ),
    );
  }
}

class _AdminTheatreCard extends StatelessWidget {
  const _AdminTheatreCard({
    required this.theatre,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  final Theatre theatre;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.theaters_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theatre.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2A2118),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${theatre.city} - ${theatre.pincode}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((theatre.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                theatre.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5C4630),
                  height: 1.45,
                ),
              ),
            ],
            if ((theatre.address ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                theatre.address!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(isBusy ? 'Deleting...' : 'Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTheatreFilterCard extends StatelessWidget {
  const _AdminTheatreFilterCard({
    required this.nameController,
    required this.cityController,
    required this.pincodeController,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController pincodeController;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Theatre name',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (_) => onApply(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_rounded),
                    ),
                    onSubmitted: (_) => onApply(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: pincodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                    ),
                    onSubmitted: (_) => onApply(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTheatreTextField extends StatelessWidget {
  const _AdminTheatreTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}

class _EmptyAdminTheatresState extends StatelessWidget {
  const _EmptyAdminTheatresState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.theaters_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No theatres found',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create a theatre or try different filters.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AdminTheatreMessageState extends StatelessWidget {
  const _AdminTheatreMessageState({
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
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

String? _optionalText(TextEditingController controller) {
  final text = controller.text.trim();
  return text.isEmpty ? null : text;
}

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _validatePincode(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Required';
  }
  if (int.tryParse(text) == null) {
    return 'Enter a valid pincode';
  }
  return null;
}
