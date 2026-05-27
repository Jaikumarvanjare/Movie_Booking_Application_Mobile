import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/movie.dart';
import '../data/movie_repository.dart';

class AdminMoviesScreen extends StatefulWidget {
  const AdminMoviesScreen({super.key});

  @override
  State<AdminMoviesScreen> createState() => _AdminMoviesScreenState();
}

class _AdminMoviesScreenState extends State<AdminMoviesScreen> {
  final _searchController = TextEditingController();
  late Future<List<Movie>> _moviesFuture;
  String? _busyMovieId;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Movie>> _loadMovies() {
    return context.read<MovieRepository>().fetchMovies(
      query: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  Future<void> _refreshMovies() async {
    final future = _loadMovies();
    setState(() {
      _moviesFuture = future;
    });
    await future;
  }

  Future<void> _openMovieForm([Movie? movie]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AdminMovieFormScreen(movie: movie),
      ),
    );

    if (changed == true && mounted) {
      await _refreshMovies();
    }
  }

  Future<void> _confirmDelete(Movie movie) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete movie?'),
          content: Text(
            'Delete ${movie.name} from the catalogue? This action cannot be undone.',
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
      await _deleteMovie(movie);
    }
  }

  Future<void> _deleteMovie(Movie movie) async {
    setState(() {
      _busyMovieId = movie.id;
    });

    try {
      await context.read<MovieRepository>().deleteMovie(movie.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully.')),
      );
      await _refreshMovies();
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
          _busyMovieId = null;
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
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;

              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && !snapshot.hasData) {
                return _AdminMovieMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load movies',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: _refreshMovies,
                );
              }

              final movies = snapshot.data ?? const <Movie>[];

              return RefreshIndicator(
                onRefresh: _refreshMovies,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 96),
                  itemCount: movies.length + 1,
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
                                      'Admin Movies',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFFE2E8F0),
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create, edit, search, and remove movie listings.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFF94A3B8),
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                tooltip: 'Add movie',
                                onPressed: () => _openMovieForm(),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search movies',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(
                                tooltip: 'Search',
                                onPressed: _refreshMovies,
                                icon: const Icon(Icons.travel_explore_rounded),
                              ),
                            ),
                            onSubmitted: (_) => _refreshMovies(),
                          ),
                          if (movies.isEmpty) ...[
                            const SizedBox(height: 80),
                            const _EmptyAdminMoviesState(),
                          ],
                        ],
                      );
                    }

                    final movie = movies[index - 1];
                    return _AdminMovieCard(
                      movie: movie,
                      isBusy: _busyMovieId == movie.id,
                      onEdit: () => _openMovieForm(movie),
                      onDelete: () => _confirmDelete(movie),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMovieForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Movie'),
      ),
    );
  }
}

class AdminMovieFormScreen extends StatefulWidget {
  const AdminMovieFormScreen({this.movie, super.key});

  final Movie? movie;

  @override
  State<AdminMovieFormScreen> createState() => _AdminMovieFormScreenState();
}

class _AdminMovieFormScreenState extends State<AdminMovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _castsController;
  late final TextEditingController _trailerUrlController;
  late final TextEditingController _languageController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _directorController;
  late final TextEditingController _posterController;
  String _releaseStatus = 'UPCOMING';
  bool _isSaving = false;

  bool get _isEditing => widget.movie != null;

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;
    _nameController = TextEditingController(text: movie?.name ?? '');
    _descriptionController = TextEditingController(
      text: movie?.description ?? '',
    );
    _castsController = TextEditingController(
      text: movie == null ? '' : movie.casts.join(', '),
    );
    _trailerUrlController = TextEditingController(
      text: movie?.trailerUrl ?? '',
    );
    _languageController = TextEditingController(
      text: movie?.language ?? 'English',
    );
    _releaseDateController = TextEditingController(
      text: movie?.releaseDate == null
          ? ''
          : DateFormat('yyyy-MM-dd').format(movie!.releaseDate!),
    );
    _directorController = TextEditingController(text: movie?.director ?? '');
    _posterController = TextEditingController(text: movie?.poster ?? '');
    _releaseStatus = movie?.releaseStatus ?? 'UPCOMING';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _castsController.dispose();
    _trailerUrlController.dispose();
    _languageController.dispose();
    _releaseDateController.dispose();
    _directorController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final releaseDate = DateTime.parse(_releaseDateController.text.trim());
    final casts = _castsController.text
        .split(',')
        .map((cast) => cast.trim())
        .where((cast) => cast.isNotEmpty)
        .toList(growable: false);

    try {
      final repository = context.read<MovieRepository>();
      if (_isEditing) {
        await repository.updateMovie(
          widget.movie!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          casts: casts,
          trailerUrl: _trailerUrlController.text.trim(),
          language: _languageController.text.trim(),
          releaseDate: releaseDate.toIso8601String(),
          director: _directorController.text.trim(),
          releaseStatus: _releaseStatus,
          poster: _posterController.text.trim(),
        );
      } else {
        await repository.createMovie(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          casts: casts,
          trailerUrl: _trailerUrlController.text.trim(),
          language: _languageController.text.trim(),
          releaseDate: releaseDate.toIso8601String(),
          director: _directorController.text.trim(),
          releaseStatus: _releaseStatus,
          poster: _posterController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Movie updated successfully.'
                : 'Movie created successfully.',
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
                  _isEditing ? 'Edit Movie' : 'Add Movie',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep catalogue details aligned with the web admin panel.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _AdminMovieTextField(
                          controller: _nameController,
                          label: 'Movie name',
                          icon: Icons.movie_creation_outlined,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _castsController,
                          label: 'Cast',
                          icon: Icons.groups_outlined,
                          helperText: 'Comma-separated names',
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _directorController,
                          label: 'Director',
                          icon: Icons.person_outline_rounded,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _languageController,
                          label: 'Language',
                          icon: Icons.language_rounded,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _releaseDateController,
                          label: 'Release date',
                          icon: Icons.calendar_month_outlined,
                          helperText: 'YYYY-MM-DD',
                          validator: _validateDate,
                          onTap: _pickReleaseDate,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _releaseStatus,
                          decoration: const InputDecoration(
                            labelText: 'Release status',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'UPCOMING',
                              child: Text('Upcoming'),
                            ),
                            DropdownMenuItem(
                              value: 'NOW_SHOWING',
                              child: Text('Now showing'),
                            ),
                            DropdownMenuItem(
                              value: 'RELEASED',
                              child: Text('Released'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _releaseStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _trailerUrlController,
                          label: 'Trailer URL',
                          icon: Icons.play_circle_outline_rounded,
                          keyboardType: TextInputType.url,
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 14),
                        _AdminMovieTextField(
                          controller: _posterController,
                          label: 'Poster URL',
                          icon: Icons.image_outlined,
                          keyboardType: TextInputType.url,
                          validator: _requiredText,
                        ),
                      ],
                    ),
                  ),
                ),
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
                ? 'Save movie'
                : 'Create movie',
          ),
        ),
      ),
    );
  }

  Future<void> _pickReleaseDate() async {
    final initial = DateTime.tryParse(_releaseDateController.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    _releaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
  }
}

class _AdminMovieCard extends StatelessWidget {
  const _AdminMovieCard({
    required this.movie,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  final Movie movie;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: movie.primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.local_movies_rounded,
                    color: movie.accentColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE2E8F0),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _AdminMovieChip(label: movie.releaseStatusLabel),
                          _AdminMovieChip(label: movie.language),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              movie.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF94A3B8),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Director: ${movie.director}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Release: ${movie.releaseDateLabel}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (movie.casts.isNotEmpty)
              Text(
                'Cast: ${movie.casts.join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
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

class _AdminMovieTextField extends StatelessWidget {
  const _AdminMovieTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.helperText,
    this.keyboardType,
    this.maxLines = 1,
    this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final String? helperText;
  final TextInputType? keyboardType;
  final int maxLines;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

class _AdminMovieChip extends StatelessWidget {
  const _AdminMovieChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class _EmptyAdminMoviesState extends StatelessWidget {
  const _EmptyAdminMoviesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No movies found',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create a movie or try a different search.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AdminMovieMessageState extends StatelessWidget {
  const _AdminMovieMessageState({
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

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _validateDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  if (DateTime.tryParse(value.trim()) == null) {
    return 'Use YYYY-MM-DD';
  }
  return null;
}
