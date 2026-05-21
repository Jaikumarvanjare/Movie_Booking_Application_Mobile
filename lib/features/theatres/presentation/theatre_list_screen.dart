import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../movies/data/movie.dart';
import '../../shows/presentation/show_list_screen.dart';
import '../data/theatre.dart';
import '../data/theatre_repository.dart';

class TheatreListScreen extends StatefulWidget {
  const TheatreListScreen({required this.movie, super.key});

  final Movie movie;

  @override
  State<TheatreListScreen> createState() => _TheatreListScreenState();
}

class _TheatreListScreenState extends State<TheatreListScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  late Future<List<Theatre>> _theatresFuture;

  @override
  void initState() {
    super.initState();
    _theatresFuture = context.read<TheatreRepository>().fetchTheatres(
      movieId: widget.movie.id,
    );
  }

  void _reload() {
    setState(() {
      _theatresFuture = context.read<TheatreRepository>().fetchTheatres(
        movieId: widget.movie.id,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        pincode: int.tryParse(_pincodeController.text.trim()),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
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
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: _TheatreHeader(movie: widget.movie, theme: theme),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: _TheatreFilterCard(
                        nameController: _nameController,
                        cityController: _cityController,
                        pincodeController: _pincodeController,
                        onApply: _reload,
                        onClear: () {
                          _nameController.clear();
                          _cityController.clear();
                          _pincodeController.clear();
                          _reload();
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverToBoxAdapter(
                      child: _buildBody(snapshot, theme),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Theatre>> snapshot, ThemeData theme) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return _InfoCard(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load theatres',
        message: '${snapshot.error}',
        actionLabel: 'Retry',
        onPressed: _reload,
      );
    }

    final theatres = snapshot.data ?? const <Theatre>[];
    if (theatres.isEmpty) {
      return _InfoCard(
        icon: Icons.theaters_outlined,
        title: 'No theatres found',
        message:
            'The backend did not return theatres for ${widget.movie.name}.',
        actionLabel: 'Retry',
        onPressed: _reload,
      );
    }

    return Column(
      children: [
        for (final theatre in theatres) ...[
          _TheatreCard(
            theatre: theatre,
            theme: theme,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ShowListScreen(movie: widget.movie, theatre: theatre),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _TheatreFilterCard extends StatelessWidget {
  const _TheatreFilterCard({
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

class _TheatreHeader extends StatelessWidget {
  const _TheatreHeader({required this.movie, required this.theme});

  final Movie movie;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 28),
        Text(
          'Choose theatre',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF2A2118),
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Available theatres for ${movie.name}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5C4630),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _TheatreCard extends StatelessWidget {
  const _TheatreCard({
    required this.theatre,
    required this.theme,
    required this.onPressed,
  });

  final Theatre theatre;
  final ThemeData theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
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
                          theatre.city,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              if ((theatre.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  theatre.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C4630),
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _theatreAddress(theatre),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _theatreAddress(Theatre theatre) {
  final address = (theatre.address ?? '').trim();
  if (address.isEmpty) {
    return 'Pincode ${theatre.pincode}';
  }
  return '$address - ${theatre.pincode}';
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
