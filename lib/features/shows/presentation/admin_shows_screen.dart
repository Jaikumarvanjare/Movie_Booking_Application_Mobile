import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../movies/data/movie.dart';
import '../../movies/data/movie_repository.dart';
import '../../theatres/data/theatre.dart';
import '../../theatres/data/theatre_repository.dart';
import '../data/movie_show.dart';
import '../data/show_repository.dart';

class AdminShowsScreen extends StatefulWidget {
  const AdminShowsScreen({super.key});

  @override
  State<AdminShowsScreen> createState() => _AdminShowsScreenState();
}

class _AdminShowsScreenState extends State<AdminShowsScreen> {
  late Future<_AdminShowListData> _dataFuture;
  String? _busyShowId;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_AdminShowListData> _loadData() async {
    final results = await Future.wait([
      context.read<ShowRepository>().fetchShows(),
      context.read<MovieRepository>().fetchMovies(),
      context.read<TheatreRepository>().fetchTheatres(),
    ]);

    return _AdminShowListData(
      shows: results[0] as List<MovieShow>,
      movies: results[1] as List<Movie>,
      theatres: results[2] as List<Theatre>,
    );
  }

  Future<void> _refreshData() async {
    final future = _loadData();
    setState(() {
      _dataFuture = future;
    });
    await future;
  }

  Future<void> _openShowForm([
    MovieShow? show,
    _AdminShowListData? listData,
  ]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _AdminShowFormScreen(show: show, initialData: listData),
      ),
    );

    if (changed == true && mounted) {
      await _refreshData();
    }
  }

  Future<void> _confirmDelete(MovieShow show) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete show?'),
          content: const Text(
            'Delete this show schedule? This action cannot be undone.',
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
      await _deleteShow(show);
    }
  }

  Future<void> _deleteShow(MovieShow show) async {
    setState(() {
      _busyShowId = show.id;
    });

    try {
      await context.read<ShowRepository>().deleteShow(show.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Show deleted successfully.')),
      );
      await _refreshData();
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
          _busyShowId = null;
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
          child: FutureBuilder<_AdminShowListData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState != ConnectionState.done;

              if (isLoading && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && !snapshot.hasData) {
                return _AdminShowMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load shows',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: _refreshData,
                );
              }

              final data =
                  snapshot.data ??
                  const _AdminShowListData(
                    shows: <MovieShow>[],
                    movies: <Movie>[],
                    theatres: <Theatre>[],
                  );
              final movieNames = {
                for (final movie in data.movies) movie.id: movie.name,
              };
              final theatreNames = {
                for (final theatre in data.theatres) theatre.id: theatre.name,
              };

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 96),
                  itemCount: data.shows.length + 1,
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
                                      'Admin Shows',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFFE2E8F0),
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Review schedules, pricing, and seat capacity.',
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
                                tooltip: 'Add show',
                                onPressed: () => _openShowForm(null, data),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                          if (data.shows.isEmpty) ...[
                            const SizedBox(height: 90),
                            const _EmptyAdminShowsState(),
                          ],
                        ],
                      );
                    }

                    final show = data.shows[index - 1];
                    return _AdminShowCard(
                      show: show,
                      movieName: movieNames[show.movieId] ?? show.movieId,
                      theatreName:
                          theatreNames[show.theatreId] ?? show.theatreId,
                      isBusy: _busyShowId == show.id,
                      onEdit: () => _openShowForm(show, data),
                      onDelete: () => _confirmDelete(show),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openShowForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Show'),
      ),
    );
  }
}

class _AdminShowFormScreen extends StatefulWidget {
  const _AdminShowFormScreen({this.show, this.initialData});

  final MovieShow? show;
  final _AdminShowListData? initialData;

  @override
  State<_AdminShowFormScreen> createState() => _AdminShowFormScreenState();
}

class _AdminShowFormScreenState extends State<_AdminShowFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _timingController;
  late final TextEditingController _noOfSeatsController;
  late final TextEditingController _priceController;
  late final TextEditingController _seatConfigController;
  String? _theatreId;
  String? _movieId;
  String _format = '2D';
  late Future<_AdminShowListData> _dataFuture;
  bool _isSaving = false;
  bool _isCheckingMapping = false;
  String? _mappingMessage;
  bool _mappingAllowed = true;

  bool get _isEditing => widget.show != null;

  @override
  void initState() {
    super.initState();
    final show = widget.show;
    _theatreId = show?.theatreId;
    _movieId = show?.movieId;
    _format = show?.format ?? '2D';
    _timingController = TextEditingController(
      text: show == null ? '' : _formatDateTimeLocal(show.timing),
    );
    _noOfSeatsController = TextEditingController(
      text: show == null ? '120' : '${show.noOfSeats}',
    );
    _priceController = TextEditingController(
      text: show == null ? '' : show.price.toStringAsFixed(0),
    );
    _seatConfigController = TextEditingController(
      text: show?.seatConfiguration ?? '',
    );
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _timingController.dispose();
    _noOfSeatsController.dispose();
    _priceController.dispose();
    _seatConfigController.dispose();
    super.dispose();
  }

  Future<_AdminShowListData> _loadData() async {
    final initialData = widget.initialData;
    if (initialData != null &&
        initialData.movies.isNotEmpty &&
        initialData.theatres.isNotEmpty) {
      return initialData;
    }
    final results = await Future.wait([
      context.read<ShowRepository>().fetchShows(),
      context.read<MovieRepository>().fetchMovies(),
      context.read<TheatreRepository>().fetchTheatres(),
    ]);
    return _AdminShowListData(
      shows: results[0] as List<MovieShow>,
      movies: results[1] as List<Movie>,
      theatres: results[2] as List<Theatre>,
    );
  }

  Future<void> _validateMapping() async {
    final theatreId = _theatreId;
    final movieId = _movieId;
    if (theatreId == null || movieId == null) {
      setState(() {
        _mappingAllowed = true;
        _mappingMessage = null;
      });
      return;
    }

    setState(() {
      _isCheckingMapping = true;
      _mappingMessage = 'Checking theatre and movie mapping...';
    });

    try {
      final allowed = await context.read<TheatreRepository>().checkTheatreMovie(
        theatreId: theatreId,
        movieId: movieId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _mappingAllowed = allowed;
        _mappingMessage = allowed
            ? 'This movie is assigned to the selected theatre.'
            : 'Assign this movie to the theatre before creating a show.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mappingAllowed = false;
        _mappingMessage = 'Unable to validate theatre and movie mapping.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingMapping = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isEditing && !_mappingAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected movie is not assigned to this theatre.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = context.read<ShowRepository>();
      final timing = DateTime.parse(_timingController.text.trim());
      final noOfSeats = int.parse(_noOfSeatsController.text.trim());
      final price = double.parse(_priceController.text.trim());
      final seatConfiguration = _optionalText(_seatConfigController);

      if (_isEditing) {
        await repository.updateShow(
          widget.show!.id,
          timing: timing,
          noOfSeats: noOfSeats,
          price: price,
          seatConfiguration: seatConfiguration,
          format: _format,
        );
      } else {
        await repository.createShow(
          theatreId: _theatreId!,
          movieId: _movieId!,
          timing: timing,
          noOfSeats: noOfSeats,
          price: price,
          seatConfiguration: seatConfiguration,
          format: _format,
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Show updated successfully.'
                : 'Show created successfully.',
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
          child: FutureBuilder<_AdminShowListData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError && !snapshot.hasData) {
                return _AdminShowMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load form data',
                  message: snapshot.error.toString(),
                  actionLabel: 'Retry',
                  onPressed: () async {
                    setState(() {
                      _dataFuture = _loadData();
                    });
                    await _dataFuture;
                  },
                );
              }
              final data =
                  snapshot.data ??
                  const _AdminShowListData(
                    shows: <MovieShow>[],
                    movies: <Movie>[],
                    theatres: <Theatre>[],
                  );

              return Form(
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
                      _isEditing ? 'Edit Show' : 'Add Show',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFE2E8F0),
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Update timing, pricing, and seat information.'
                          : 'Schedule a show for an assigned theatre movie.',
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
                            DropdownButtonFormField<String>(
                              initialValue: _theatreId,
                              decoration: const InputDecoration(
                                labelText: 'Theatre',
                                prefixIcon: Icon(Icons.theaters_outlined),
                              ),
                              items: [
                                for (final theatre in data.theatres)
                                  DropdownMenuItem(
                                    value: theatre.id,
                                    child: Text(theatre.name),
                                  ),
                              ],
                              onChanged: _isEditing
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _theatreId = value;
                                      });
                                      _validateMapping();
                                    },
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _movieId,
                              decoration: const InputDecoration(
                                labelText: 'Movie',
                                prefixIcon: Icon(Icons.local_movies_outlined),
                              ),
                              items: [
                                for (final movie in data.movies)
                                  DropdownMenuItem(
                                    value: movie.id,
                                    child: Text(movie.name),
                                  ),
                              ],
                              onChanged: _isEditing
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _movieId = value;
                                      });
                                      _validateMapping();
                                    },
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                            if (!_isEditing && _mappingMessage != null) ...[
                              const SizedBox(height: 14),
                              _MappingMessage(
                                message: _mappingMessage!,
                                allowed: _mappingAllowed,
                                loading: _isCheckingMapping,
                              ),
                            ],
                            const SizedBox(height: 14),
                            _AdminShowTextField(
                              controller: _timingController,
                              label: 'Timing',
                              icon: Icons.schedule_outlined,
                              helperText: 'YYYY-MM-DD HH:MM',
                              validator: _validateDateTime,
                              onTap: _pickTiming,
                            ),
                            const SizedBox(height: 14),
                            _AdminShowTextField(
                              controller: _noOfSeatsController,
                              label: 'Number of seats',
                              icon: Icons.event_seat_outlined,
                              keyboardType: TextInputType.number,
                              validator: _validatePositiveInt,
                            ),
                            const SizedBox(height: 14),
                            _AdminShowTextField(
                              controller: _priceController,
                              label: 'Price',
                              icon: Icons.currency_rupee_rounded,
                              keyboardType: TextInputType.number,
                              validator: _validatePositiveNumber,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              initialValue: _format,
                              decoration: const InputDecoration(
                                labelText: 'Format',
                                prefixIcon: Icon(Icons.high_quality_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '2D',
                                  child: Text('2D'),
                                ),
                                DropdownMenuItem(
                                  value: '3D',
                                  child: Text('3D'),
                                ),
                                DropdownMenuItem(
                                  value: 'IMAX',
                                  child: Text('IMAX'),
                                ),
                                DropdownMenuItem(
                                  value: '4DX',
                                  child: Text('4DX'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _format = value;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            _AdminShowTextField(
                              controller: _seatConfigController,
                              label: 'Seat configuration',
                              icon: Icons.chair_outlined,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: FilledButton.icon(
          onPressed: _isSaving || _isCheckingMapping ? null : _submit,
          icon: Icon(_isEditing ? Icons.save_outlined : Icons.add_rounded),
          label: Text(
            _isSaving
                ? 'Saving...'
                : _isEditing
                ? 'Save show'
                : 'Create show',
          ),
        ),
      ),
    );
  }

  Future<void> _pickTiming() async {
    final current = DateTime.tryParse(_timingController.text.trim());
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(current),
    );
    if (time == null) {
      return;
    }
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    _timingController.text = _formatDateTimeLocal(value);
  }
}

class _AdminShowListData {
  const _AdminShowListData({
    required this.shows,
    required this.movies,
    required this.theatres,
  });

  final List<MovieShow> shows;
  final List<Movie> movies;
  final List<Theatre> theatres;
}

class _AdminShowCard extends StatelessWidget {
  const _AdminShowCard({
    required this.show,
    required this.movieName,
    required this.theatreName,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  final MovieShow show;
  final String movieName;
  final String theatreName;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE2E8F0),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theatreName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(show.formatLabel)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(show.dateLabel),
                ),
                Chip(
                  avatar: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(show.timeLabel),
                ),
                Chip(
                  avatar: const Icon(Icons.event_seat_rounded, size: 18),
                  label: Text('${show.noOfSeats} seats'),
                ),
                Chip(
                  avatar: const Icon(Icons.currency_rupee_rounded, size: 18),
                  label: Text(show.price.toStringAsFixed(0)),
                ),
              ],
            ),
            if ((show.seatConfiguration ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Seat configuration saved',
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

class _AdminShowTextField extends StatelessWidget {
  const _AdminShowTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.helperText,
    this.maxLines = 1,
    this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final String? helperText;
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

class _MappingMessage extends StatelessWidget {
  const _MappingMessage({
    required this.message,
    required this.allowed,
    required this.loading,
  });

  final String message;
  final bool allowed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final color = loading
        ? Theme.of(context).colorScheme.primary
        : allowed
        ? const Color(0xFF2F8F46)
        : const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
    );
  }
}

class _EmptyAdminShowsState extends StatelessWidget {
  const _EmptyAdminShowsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No shows scheduled',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create a show once a theatre has the movie assigned.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AdminShowMessageState extends StatelessWidget {
  const _AdminShowMessageState({
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

String? _validateDateTime(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'Required';
  }
  if (DateTime.tryParse(text) == null) {
    return 'Use YYYY-MM-DD HH:MM';
  }
  return null;
}

String? _validatePositiveInt(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Enter a positive number';
  }
  return null;
}

String? _validatePositiveNumber(String? value) {
  final parsed = double.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Enter a positive amount';
  }
  return null;
}

String _formatDateTimeLocal(DateTime value) {
  return DateFormat('yyyy-MM-dd HH:mm').format(value);
}
